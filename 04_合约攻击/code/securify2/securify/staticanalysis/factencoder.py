import collections
from collections import defaultdict
from functools import singledispatch

from securify.ir import cfg_ir as ir, visualizer
from securify.solidity.v_0_5_x import solidity_grammar as ast
from securify.solidity.solidity_cfg_compiler import compile_attributed_ast_from_string, compile_cfg_from_string
from securify.staticanalysis.souffle.factformatter import format_facts_as_code, format_facts_as_csv
from securify.staticanalysis.facts import *
from securify.solidity.v_0_5_x import solidity_builtins

__all__ = ["encode"]


def traverse_cfg(cfg):
    traversed_blocks = set()

    @singledispatch
    def traverse_element(_):
        raise NotImplementedError(type(_))

    @traverse_element.register
    def traverse_transfer(transfer: ir.Transfer):
        yield transfer

        if isinstance(transfer, ir.Goto):
            yield from traverse_block(transfer.block)
        elif isinstance(transfer, ir.Branch):
            yield from traverse_block(transfer.true_block)
            yield from traverse_block(transfer.false_block)
        elif isinstance(transfer, ir.Jump):
            yield from traverse_block(transfer.continuation)
            yield from traverse_block(transfer.dst.cfg)  # TODO: Traverse funciton instead?
        elif isinstance(transfer, ir.Call):
            yield from traverse_block(transfer.continuation)
        elif isinstance(transfer, ir.Return):
            pass
        elif isinstance(transfer, ir.Halt):
            pass
        else:
            raise NotImplementedError()

    @traverse_element.register
    def traverse_block(block: ir.Block):
        if block in traversed_blocks:
            return

        yield block

        for arg in block.args:
            yield arg

        traversed_blocks.add(block)

        for stmt in block.stmts:
            yield stmt

        yield from traverse_transfer(block.transfer)

    @traverse_element.register
    def traverse_function(function: ir.Function):
        yield function
        yield from traverse_block(function.cfg)

    @traverse_element.register
    def traverse_state_variable(var: ir.StateVariable):
        yield var

    @traverse_element.register
    def traverse_contract(contract: ir.Contract):
        yield contract
        for f in contract.functions.values():
            yield from traverse_function(f)

        for v in contract.variables.values():
            yield from traverse_element(v)

    @traverse_element.register
    def traverse_source_unit(source_unit: ir.SourceUnit):
        # yield source_unit
        for c in source_unit.contracts:
            yield from traverse_contract(c)

    yield from traverse_element(cfg)


class IdentifierMapping(collections.abc.Mapping):
    ignored_node_types = (ir.Comment, ir.MarkerNode, ir.IgnoredNode)

    prefix_map = {
        "B": ir.Block,
        "A": ir.Argument,
        "S": ir.Statement,
        "T": ir.Transfer,
        "C": ir.Contract,
        "V": ir.StateVariable,
        "F": ir.Function,

        # Ignored elements
        ...: ignored_node_types
    }

    def __init__(self, cfg):
        all_ids = defaultdict(lambda: {})

        def assign_id(obj):
            obj_id = id(obj)

            # Find correct prefix for object
            pfx_iter = (b for b, a in self.prefix_map.items() if isinstance(obj, a))
            pfx = next(pfx_iter, None)

            if pfx is ...:
                return None

            if pfx is None:
                raise NotImplementedError("Unexpected CFG element", obj)

            ids: dict = all_ids[pfx]

            if obj_id not in ids:
                padded_length = str(len(ids)).rjust(2, "0")
                ids[obj_id] = f"{pfx}{padded_length}"

            return ids[obj_id]

        elements = ((c, assign_id(c)) for c in traverse_cfg(cfg))
        elements = ((c, i) for (c, i) in elements if i is not None)
        elements = ((c, i) if not isinstance(c, ir.Statement) else (c.expr, i) for (c, i) in elements)
        elements = ((c, i) for (c, i) in elements if not isinstance(c, self.ignored_node_types))
        elements = list(elements)

        self.id_to_object = {id(e): e for e, _ in elements}
        self.id_to_identifier = {id(e): i for e, i in elements}

        assert len({id(e) for e in self.id_to_object.values()}) == len(self.id_to_object)

    def __getitem__(self, item):
        try:
            return self.id_to_identifier[id(item)]
        except KeyError:
            # This error may indicate that a node is referenced in an
            # expression value construct but is not part of the CFG
            raise KeyError(item) from None

    def __iter__(self):
        return iter(self.id_to_object.values())

    def __len__(self):
        return len(self.id_to_identifier)


def encode(cfg):
    result = []

    ids = IdentifierMapping(cfg)

    def ignored(node):
        return node not in ids

    # @singledispatch
    # def encode(_):
    #     raise NotImplementedError()

    # @encode.register
    def encode_expression(node: ir.Expression):
        nonlocal result

        if ignored(node):
            return

        if isinstance(node, ir.Assignment):
            if not isinstance(node.expr, solidity_builtins.BoundLowLevelValueCall):
                r = AssignFact(ids[node], ids[node.expr])
            else:
                r = AssignFact(ids[node], ids[node.expr.bound_expression])

        elif isinstance(node, ir.Const):
            r = ConstFact(ids[node], node.value)

        elif isinstance(node, ir.BinaryOp):
            r = BinaryOpFact(ids[node], ids[node.lhs], ids[node.rhs], node.op)

        elif isinstance(node, ir.UnaryOp):
            r = UnaryOpFact(ids[node], ids[node.sub], node.op)

        elif isinstance(node, ir.StateVariableLoad):
            r = LoadFact(ids[node], ids[node.variable])

        elif isinstance(node, ir.TypeRef):  # TODO: this is a hack
            r = ConstFact(ids[node], node.name)

        elif isinstance(node, ir.StateVariableStore):
            r = StoreFact(ids[node], ids[node.variable], ids[node.expr])

        elif isinstance(node, ir.ArrayLoad):
            r = ArrayLoadFact(ids[node], ids[node.base], ids[node.index])

        elif isinstance(node, ir.ArrayStore):
            r = ArrayStoreFact(ids[node], ids[node.base], ids[node.index], ids[node.expr])

        elif isinstance(node, ir.ArrayPush):
            r = ArrayPushFact(ids[node], ids[node.base], ids[node.expr])

        elif isinstance(node, ir.MappingLoad):
            r = MapLoadFact(ids[node], ids[node.mapping], ids[node.index])

        elif isinstance(node, ir.MappingStore):
            r = MapStoreFact(ids[node], ids[node.mapping], ids[node.index], ids[node.expr])

        elif isinstance(node, ir.MemberLoad):
            r = StructLoadFact(ids[node], ids[node.base], node.member)

        elif isinstance(node, ir.MemberStore):
            r = StructStoreFact(ids[node], ids[node.base], node.member, ids[node.expr])

        elif isinstance(node, ir.MagicVariable):
            r = BuiltinVariableFact(ids[node], node.variable)

        elif isinstance(node, ir.BuiltinFunction):
            for i, arg in enumerate(node.arguments):
                result.append(BuiltinFunctionFact(ids[node], node.name, ids[arg], i))
            r = None

        elif isinstance(node, ir.SelfDestruct):
            r = SelfDestructFact(ids[node], ids[node.address])

        elif isinstance(node, ir.Balance):
            r = BalanceFact(ids[node], ids[node.address])

        elif isinstance(node, ir.Emit):
            for i, arg in enumerate(node.arguments):
                result.append(EmitFact(ids[node], node.event_name, ids[arg], i))
            r = None

        elif isinstance(node, ir.Array):  # TODO: Implement
            r = ConstFact(ids[node], "ARRAY")

        elif isinstance(node, ir.Mapping):  # TODO: Implement
            r = ConstFact(ids[node], "MAPPING")

        else:
            raise NotImplementedError(type(node), node)

        if r is not None:
            result.append(r)

        result.append(StatementFact(ids[node]))

    # @encode.register
    def encode_block(block: ir.Block):
        nonlocal result
        id_block = ids[block]
        result.append(BlockFact(id_block))

        for i, arg in enumerate(block.args):
            result.append(ArgumentFact(ids[arg], id_block, i))

        block_stmts = [s.expr for s in block.stmts if not ignored(s.expr)]

        for s in block_stmts:
            result.append(BlockStmtFact(id_block, ids[s]))

        for n, p in zip(block_stmts[1:], block_stmts[:-1]):
            result.append(FollowsFact(ids[n], ids[p]))

    def encode_transfer(block: ir.Block):
        nonlocal result
        transfer = block.transfer
        id_from = ids[block]
        id_transfer = ids[transfer]

        def arg_facts(args, tid=None):
            return [TransferArgumentFact(tid or id_transfer, ids[v], i) for i, v in enumerate(args)]

        if isinstance(transfer, ir.Goto):
            result.append(GotoFact(id_transfer, id_from, ids[transfer.block]))
            result.extend(arg_facts(transfer.args))

        elif isinstance(transfer, ir.Branch):
            id_transfer_true = id_transfer + "_TRUE"
            id_transfer_false = id_transfer + "_FALSE"

            result.append(BranchFact(id_transfer_true,
                                     id_transfer_false,
                                     id_from,
                                     ids[transfer.true_block],
                                     ids[transfer.false_block],
                                     ids[transfer.cond]))

            result.extend(arg_facts(transfer.true_args, id_transfer_true))
            result.extend(arg_facts(transfer.false_args, id_transfer_false))

        elif isinstance(transfer, ir.Return):
            result.append(ReturnFact(id_transfer, id_from))
            result.extend(arg_facts(transfer.returns))

        elif isinstance(transfer, ir.Jump):
            id_dst = ids[transfer.dst.cfg]
            id_cont = ids[transfer.continuation]

            result.append(JumpFact(id_transfer, id_from, id_dst, id_cont))
            result.extend(arg_facts(transfer.args))

        elif isinstance(transfer, ir.Call):
            id_cont = ids[transfer.continuation]

            assert isinstance(transfer.dst, ir.CallTarget), "Illegal call destination found"

            result.append(CallFact(id_transfer, id_from, ids[transfer.dst.address], id_cont))

            if transfer.ether:
                result.append(CallValueFact(id_transfer, ids[transfer.ether]))
            if transfer.gas:
                result.append(CallGasFact(id_transfer, ids[transfer.gas]))

            result.append(CallInfoFact(id_transfer, ids[transfer.dst.address], transfer.kind))
            result.extend(arg_facts(transfer.args))

        elif isinstance(transfer, ir.Halt):
            if transfer.revert:
                result.append(RevertFact(id_transfer, id_from))
            else:
                result.append(StopFact(id_transfer, id_from))
            # result.extend(arg_facts(transfer.returns))

        else:
            raise NotImplementedError()

    def encode_function(function: ir.Function):
        nonlocal result
        function_id = ids[function.cfg]
        result.append(FunctionFact(function_id, node.name))
        result.append(AnnotationFact(function_id, "visibility", function.visibility))
        result.append(AnnotationFact(function_id, "isView", function.view))

        if function.payable:
            result.append(AnnotationFact(function_id, "payable", "payable"))

        if function.constructor:
            result.append(AnnotationFact(function_id, "solidityFunctionKind", "constructor"))

    def encode_contract(contract: ir.Contract):
        nonlocal result
        contract_id = ids[contract]
        result.append(ContractFact(contract_id, contract.name))
        result.append(AnnotationFact(contract_id, "solidityContractKind", contract.ast_node.contract_kind))

        for f in contract.functions.values():
            result.append(ContractFunctionFact(contract_id, ids[f.cfg]))

        for f in contract.variables.values():
            result.append(ContractStateVarFact(ids[f], contract_id))

    for node in traverse_cfg(cfg):
        if isinstance(node, ir.Statement):
            encode_expression(node.expr)
        elif isinstance(node, ir.Block):
            encode_block(node)
            encode_transfer(node)
        elif isinstance(node, ir.Function):
            encode_function(node)
        elif isinstance(node, ir.Argument):
            pass
        elif isinstance(node, ir.Transfer):
            pass
        elif isinstance(node, ir.StateVariable):
            pass
        elif isinstance(node, ir.Contract):
            encode_contract(node)
        else:
            raise NotImplementedError(type(node))

    for e, i in ids.items():
        if not e.ast_node:
            continue

        result.append(SourceInfoFact(i, "loc", e.ast_node.src))
        result.append(SourceInfoFact(i, "line", e.ast_node.src_line))
        result.append(SourceInfoFact(i, "contract", e.ast_node.src_contract))

        if hasattr(e.ast_node, "type_string"):
            result.append(AnnotationFact(i, "type", e.ast_node.type_string))

            if getattr(e.ast_node, "storage_location", None) == "storage":
                result.append(AnnotationFact(i, "solidityStorageLocation", "storage"))
            elif "storage ref" in e.ast_node.type_string or "storage pointer" in e.ast_node.type_string:
                result.append(AnnotationFact(i, "solidityStorageLocation", "storage"))
            else:
                result.append(AnnotationFact(i, "solidityStorageLocation", "memory"))

        for k, v in e.annotations.items():
            result.append(AnnotationFact(i, k, v))

    return result, {i: e for e, i in ids.items()}


if __name__ == '__main__':
    # language=Solidity
    test_program = """ 
        pragma solidity ^0.5.0;
    
        contract A {
            uint state = 0;
            
            function test(uint i) public returns (uint) {
                uint a = 4;
                
                if (a==4) {
                    a+=i++;
                } else {
                    //state += i;
                    //return i;
                }
            
                return test(a);
            }
        }
    """

    for f in fact_types:
        print(f.__name__)

    cfg: ir.SourceUnit = compile_cfg_from_string(test_program).cfg

    visualizer.draw_cfg([cfg], view=False)

    facts = encode(cfg)
    for k in sorted([str(k) for k in list(facts)]):
        print(k)

    from securify.staticanalysis.visualization import visualize

    print(format_facts_as_code(facts, fact_types))
    print(format_facts_as_csv(facts))

    visualize(facts).render("dl", format="png", cleanup=True)
