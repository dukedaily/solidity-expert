from __future__ import annotations

from abc import ABC
from dataclasses import dataclass
from typing import List, Type, Optional

from . import solidity_grammar as ast
from ...ir import cfg_ir as ir
from ...ir.cfgutils import CfgSimple


@dataclass
class FunctionCallInfo:
    ast_node: ast.FunctionCall
    arguments: List[ir.Expression]
    arguments_cfgs: List[CfgSimple]
    result_arity: int


class CallableImpl:
    def __init__(self):
        self.setup_called = False
        self.flattened_expression_values = []
        self.cfg = CfgSimple.empty()

    def setup(self, call_info: FunctionCallInfo):
        if self.setup_called:
            return

        self.setup_called = True
        self.setup_impl(call_info)

    def setup_impl(self, call_info: FunctionCallInfo):
        raise NotImplementedError()


class EventCallable(CallableImpl):
    def __init__(self, event_definition):
        super().__init__()
        self.event_definition = event_definition

    def setup_impl(self, call_info: FunctionCallInfo):
        node = ir.Emit(call_info.ast_node, self.event_definition.qualified_name, call_info.arguments)

        self.flattened_expression_values = []
        self.cfg = CfgSimple.statement(node)


class ExternalMemberAccess(CallableImpl):
    def __init__(self, member_load: ir.MemberLoad, member_load_cfg: CfgSimple):
        super().__init__()
        self.member_load = member_load
        self.member_load_cfg = member_load_cfg

    def setup_impl(self, call_info: FunctionCallInfo):
        num_arguments = len(call_info.arguments)

        assert num_arguments <= 1

        if num_arguments == 0:
            # Access to public non-mapping field via accessor
            self.flattened_expression_values = [self.member_load]
            self.cfg = [self.member_load_cfg]
        else:
            # Access to public mapping via accessor
            mapping_access = ir.MappingLoad(
                call_info.ast_node, self.member_load,
                call_info.arguments[0])

            self.flattened_expression_values = [mapping_access]
            self.cfg = self.member_load_cfg >> mapping_access


class BoundFunctionBase(ir.MemberLoad, CallableImpl, ABC):
    @property
    def dont_copy(self):
        return super().dont_copy + [
            "member_access",
            "bound_expression",
            "bound_cfg",
            "member_load_args"
        ]

    def __init__(self, member_access, bound_expression, bound_cfg, member_load_args):
        ir.MemberLoad.__init__(self, **member_load_args)
        CallableImpl.__init__(self)

        self.member_access = member_access
        self.bound_expression = bound_expression
        self.bound_cfg = bound_cfg

        self.value = None
        self.gas = None

    def get_gas(self, call_info):
        if self.gas:
            return self.gas, CfgSimple.empty()

        gas = ir.GasLeft(call_info.ast_node)

        return gas, CfgSimple.statement(gas)

    def get_value(self, call_info):
        if self.value:
            return self.value, CfgSimple.empty()

        value = ir.Const(call_info.ast_node, 0, "uint256")

        return value, CfgSimple.statement(value)


class BoundFunction(BoundFunctionBase):
    def setup_impl(self, call_info: FunctionCallInfo):
        returns = [ir.Argument(call_info.ast_node) for _ in range(call_info.result_arity)]
        continuation = ir.Block(call_info.ast_node, returns, info="CONTINUATION")

        destination = ir.CallTarget(self.member_access,
                                    self.member_access.expression_value,
                                    self.member_access.member_name)

        gas, gas_cfg = self.get_gas(call_info)
        val, val_cfg = self.get_value(call_info)

        transfer = ir.Call(call_info.ast_node,
                           destination,
                           continuation,
                           call_info.arguments,
                           call_info.ast_node.names,
                           val, gas)

        self.flattened_expression_values = returns
        # self.cfg = self.bound_cfg >> val_cfg >> gas_cfg >> transfer >> continuation
        self.cfg = self.member_access.cfg >> val_cfg >> gas_cfg >> transfer >> continuation


class BoundDelegateCallable(BoundFunctionBase):
    def setup_impl(self, call_info: FunctionCallInfo):
        assert call_info.result_arity == 2, f"Result must be a two tuple of (bool, bytes memory)" \
                                            f" for delegate call [{call_info.ast_node}]."

        returns = [ir.Argument(call_info.ast_node) for _ in range(2)]
        continuation = ir.Block(call_info.ast_node, returns, info="CONTINUATION")

        # TODO: identify target function if possible
        destination = ir.CallTarget(self.member_access,
                                    self.bound_expression,
                                    None)

        gas, gas_cfg = self.get_gas(call_info)

        transfer = ir.Call(call_info.ast_node,
                           destination,
                           continuation,
                           call_info.arguments,
                           call_info.ast_node.names,
                           None, gas, kind="delegatecall")

        self.flattened_expression_values = returns
        self.cfg = self.bound_cfg >> gas_cfg >> transfer >> continuation


class BoundSendLikeCallableBase(BoundFunctionBase):
    call_kind = None
    call_result_arity = None

    def setup_impl(self, call_info: FunctionCallInfo):
        assert self.call_kind is not None
        assert self.call_result_arity is not None

        assert self.call_result_arity == call_info.result_arity, \
            f"Result arity does not match for {self.call_kind}() call"

        returns = [ir.Argument(call_info.ast_node) for _ in range(self.call_result_arity)]
        continuation = ir.Block(call_info.ast_node, returns, info="CONTINUATION")

        # TODO: identify target function if possible
        destination = ir.CallTarget(self.member_access,
                                    self.bound_expression,
                                    ast.DEFAULT_FALLBACK_NAME)

        gas = ir.Const(call_info.ast_node, ast.SEND_TRANSFER_GAS, "uint256")

        transfer = ir.Call(call_info.ast_node,
                           destination,
                           continuation,
                           [], [],
                           call_info.arguments[0], gas,
                           kind=self.call_kind)

        self.flattened_expression_values = returns
        self.cfg = self.bound_cfg >> gas >> transfer >> continuation


class BoundSendCall(BoundSendLikeCallableBase):
    call_kind = "send"
    call_result_arity = 1


class BoundTransferCall(BoundSendLikeCallableBase):
    call_kind = "transfer"
    call_result_arity = 0


class BoundLowLevelValueCall(BoundSendLikeCallableBase):
    # This might be cause of bugs
    def setup_impl(self, call_info: FunctionCallInfo):
        returns = [ir.Argument(call_info.ast_node) for _ in range(call_info.result_arity)]
        continuation = ir.Block(call_info.ast_node, returns, info="CONTINUATION")

        destination = ir.CallTarget(self.member_access,
                                    # returns[0], # May we can do something with CfgSimple.statement
                                    self.bound_expression,
                                    None)

        gas, gas_cfg = self.get_gas(call_info)
        val, val_cfg = self.get_value(call_info)

        transfer = ir.Call(call_info.ast_node,
                           destination,
                           continuation,
                           call_info.arguments,
                           call_info.ast_node.names,
                           val, gas, kind="lowlevel")

        self.setup_called = False
        self.flattened_expression_values = [self]
        # We short-circuit flattened expressions here so (new A).value has a builtin as an expression value
        self.cfg = self.bound_expression >> self.bound_cfg >> val_cfg >> gas_cfg >> transfer >> continuation
        self.cfg.visualize_and_display("cfg")
        assert(True)


class BoundLowLevelCall(BoundSendLikeCallableBase):
    def setup_impl(self, call_info: FunctionCallInfo):
        returns = [ir.Argument(call_info.ast_node) for _ in range(call_info.result_arity)]
        continuation = ir.Block(call_info.ast_node, returns, info="CONTINUATION")

        destination = ir.CallTarget(self.member_access,
                                    self.bound_expression,
                                    None)

        gas, gas_cfg = self.get_gas(call_info)
        val, val_cfg = self.get_value(call_info)

        transfer = ir.Call(call_info.ast_node,
                           destination,
                           continuation,
                           call_info.arguments,
                           call_info.ast_node.names,
                           val, gas, kind="lowlevel")

        self.flattened_expression_values = returns
        self.cfg = self.bound_cfg >> val_cfg >> gas_cfg >> transfer >> continuation


class LibraryFunction(CallableImpl):
    def __init__(self, member_access):
        super().__init__()
        self.member_access = member_access

    def setup_impl(self, call_info: FunctionCallInfo):
        returns = [ir.Argument(call_info.ast_node) for _ in range(call_info.result_arity)]
        continuation = ir.Block(call_info.ast_node, returns, info="CONTINUATION")

        destination = ir.JumpDestination(self.member_access,
                                         self.member_access.referenced_declaration)

        implemented = call_info.ast_node.resolve_reference(self.member_access.referenced_declaration) is not None

        if implemented:
            arguments = call_info.arguments

            transfer = ir.Jump(call_info.ast_node,
                               destination,
                               continuation,
                               arguments,
                               call_info.ast_node.names)

            self.flattened_expression_values = returns
            self.cfg = CfgSimple.concatenate(transfer, continuation)
        else:
            pass


class BoundLibraryFunction(BoundFunctionBase):
    def setup_impl(self, call_info: FunctionCallInfo):
        returns = [ir.Argument(call_info.ast_node) for _ in range(call_info.result_arity)]
        continuation = ir.Block(call_info.ast_node, returns, info="CONTINUATION")

        destination = ir.JumpDestination(self.member_access,
                                         self.member_access.referenced_declaration)

        implemented = call_info.ast_node.resolve_reference(self.member_access.referenced_declaration) is not None

        if implemented:
            arguments = [self.bound_expression] + call_info.arguments

            transfer = ir.Jump(call_info.ast_node,
                               destination,
                               continuation,
                               arguments,
                               call_info.ast_node.names)

            self.flattened_expression_values = returns
            self.cfg = self.bound_cfg >> transfer >> continuation
        else:
            pass


class GasSpecifier(BoundFunctionBase):
    """
    Callable gas specifier (as in `this.my_func.gas(1 ether)()`)
    Note that the gas specifier is always called immediately,
    i.e. it is not possible to have a construct like
    `this.my_func.gas.gas(1 ether)(1 ether)()` which allows for a
    simpler implementation that does not need nesting of
    gas or value specifiers.
    """

    def setup_impl(self, call_info: FunctionCallInfo):
        # todo: consider deepcopy here
        old_callable: BoundFunctionBase = self.bound_expression
        new_callable: BoundFunctionBase = old_callable
        new_callable.gas = call_info.arguments[0]
        new_callable.bound_cfg >>= CfgSimple.concatenate(*call_info.arguments_cfgs)

        self.flattened_expression_values = [new_callable]
        self.cfg = CfgSimple.empty()


class ValueSpecifier(BoundFunctionBase):
    """
    Callable value specifier (as in `this.my_func.value(1 ether)()`)
    C.f. remarks for [[GasSpecifier]]
    """

    def setup_impl(self, call_info: FunctionCallInfo):
        # todo: consider deepcopy here
        old_callable: BoundFunctionBase = self.bound_expression
        new_callable: BoundFunctionBase = old_callable
        new_callable.value = call_info.arguments[0]
        new_callable.bound_cfg >>= CfgSimple.concatenate(*call_info.arguments_cfgs)

        self.flattened_expression_values = [new_callable]
        self.cfg = CfgSimple.empty()


class SolidityBuiltInFunction(CallableImpl, ABC):
    @staticmethod
    def new(name: str, arity: Optional[int], language_specific: bool) -> Type[SolidityBuiltInFunction]:
        def setup_impl(self, call_info: FunctionCallInfo):
            if arity is not None:
                assert len(call_info.arguments) == arity, name

            expression_value = ir.BuiltinFunction(
                call_info.ast_node, name,
                call_info.arguments)

            self.flattened_expression_values = [expression_value]
            self.cfg = CfgSimple.statement(expression_value)

        # noinspection PyTypeChecker
        return type(name, (SolidityBuiltInFunction,), {
            'setup_impl': setup_impl
        })


def hash_function(name: str):
    return SolidityBuiltInFunction.new(name, 1, language_specific=False)


Keccak256BuiltIn = hash_function("keccak256")
SHA256BuiltIn = hash_function("sha256")
RIPEMD160BuiltIn = hash_function("ripemd160")
BlockHashBuiltIn = hash_function("blockhash")

ECRecoverBuiltIn = SolidityBuiltInFunction.new("ecrecover", 4, language_specific=False)

AddMod = SolidityBuiltInFunction.new("addmod", 3, language_specific=False)
MulMod = SolidityBuiltInFunction.new("mulmod", 3, language_specific=False)


class GasLeftBuiltIn(SolidityBuiltInFunction):
    def setup_impl(self, call_info: FunctionCallInfo):
        assert len(call_info.arguments) == 0
        expression_value = ir.GasLeft(call_info.ast_node)

        self.flattened_expression_values = [expression_value]
        self.cfg = CfgSimple.statement(expression_value)


class SelfDestructBuiltIn(SolidityBuiltInFunction):
    def setup_impl(self, call_info: FunctionCallInfo):
        assert len(call_info.arguments) == 1

        destroy = ir.SelfDestruct(call_info.ast_node, call_info.arguments[0])
        halt = ir.Halt(call_info.ast_node, False)

        # TODO: Maybe set reachbility in function call statement
        self.cfg = CfgSimple.statements(destroy, halt).without_appendable(halt)


class RevertBuiltin(SolidityBuiltInFunction):
    def setup_impl(self, call_info: FunctionCallInfo):
        assert len(call_info.arguments) <= 1  # TODO: include arguments

        halt = ir.Halt(call_info.ast_node, True)

        # TODO: Maybe set reachbility in function call statement
        self.cfg = CfgSimple.statements(halt).without_appendable(halt)


class BalanceBuiltIn(SolidityBuiltInFunction):
    def setup_impl(self, call_info: FunctionCallInfo):
        assert len(call_info.arguments) == 0
        expression_value = ir.GasLeft(call_info.ast_node)

        self.flattened_expression_values = [expression_value]
        self.cfg = CfgSimple.statement(expression_value)


# class ConstructorCall(SolidityBuiltInFunction):
#     def setup(self, call_info: FunctionCallInfo):
#         assert len(call_info.arguments) <= 1  # TODO: include arguments
#
#         halt = ir.Halt(self, True)
#
#         # TODO: Maybe set reachbility in function call statement
#         self.cfg = CfgSimple.statements(halt).without_appendable(halt)


class PushBuiltin(SolidityBuiltInFunction):
    def __init__(self, array_expression_value, array_cfg):
        super().__init__()
        self.array_expression_value = array_expression_value
        self.array_cfg = array_cfg

    def setup_impl(self, call_info: FunctionCallInfo):
        assert len(call_info.arguments) == 1
        array = self.array_expression_value
        push = ir.ArrayPush(call_info.ast_node, array, call_info.arguments[0])
        length = ir.UnaryOp(call_info.ast_node, "length", array)

        self.flattened_expression_values = [length]
        self.cfg = self.array_cfg >> CfgSimple.statements(push, length)


class AssertBaseBuiltin(SolidityBuiltInFunction):
    def __init__(self, revert):
        super().__init__()
        self.revert = revert

    def setup(self, call_info: FunctionCallInfo):
        assert len(call_info.arguments) <= 2  # TODO: include arguments

        block_continue = ir.Block(call_info.ast_node, info="IF_TRUE")
        block_revert = ir.Block(call_info.ast_node, info="IF_FALSE")

        branch = ir.Branch(call_info.ast_node, call_info.arguments[0], block_continue, block_revert, [], [])

        halt = ir.Halt(call_info.ast_node, self.revert)
        cfg_continue = CfgSimple.statements(block_continue)
        cfg_revert = CfgSimple.statements(block_revert, halt).without_appendable(halt)

        cfg_builder = CfgSimple.statement(branch) >> (cfg_continue, cfg_revert)

        self.cfg = cfg_builder.without_appendable(halt)


class AssertBuiltin(AssertBaseBuiltin):
    def __init__(self):
        super().__init__(False)


class RequireBuiltin(AssertBaseBuiltin):
    def __init__(self):
        super().__init__(True)


builtin_map = {
    "selfdestruct": SelfDestructBuiltIn,
    "suicide": SelfDestructBuiltIn,

    "gasleft": GasLeftBuiltIn,

    "assert": AssertBuiltin,
    "revert": RevertBuiltin,
    "require": RequireBuiltin,

    "sha256": SHA256BuiltIn,
    "ripemd160": RIPEMD160BuiltIn,
    "keccak256": Keccak256BuiltIn,
    "sha3": Keccak256BuiltIn,
    "blockhash": BlockHashBuiltIn,

    "ecrecover": ECRecoverBuiltIn,
    "addmod": AddMod,
    "mulmod": MulMod,
}

builtin_map_nested = {
    "msg": {
        "sender": ir.Sender,
        "data": ir.Data, "sig": ir.Signature,
        "value": ir.Value, "gas": ir.GasLeft
    },
    "tx": {
        "gasprice": ir.GasPrice,
        "origin": ir.Origin
    },
    "block": {
        "coinbase": ir.Coinbase,
        "difficulty": ir.Difficulty, "gaslimit": ir.Signature,
        "number": ir.BlockNumber, "timestamp": ir.Timestamp
    },
    "abi": {
        "decode": SolidityBuiltInFunction.new("abi_decode", None, False),
        "encode": SolidityBuiltInFunction.new("abi_encode", None, False),
        "encodePacked": SolidityBuiltInFunction.new("abi_encodePacked", None, False),
        "encodeWithSelector": SolidityBuiltInFunction.new("abi_encodeWithSelector", None, False),
        "encodeWithSignature": SolidityBuiltInFunction.new("abi_encodeWithSignature", None, False),
    }
}
