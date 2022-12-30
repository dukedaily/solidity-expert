from __future__ import annotations

from copy import deepcopy
from dataclasses import dataclass
from typing import List

from securify.ir import cfg_ir as ir, visualizer
from securify.ir.cfgutils import CfgSimple
from securify.solidity.utils import of_type, find, __, unzip2
from securify.solidity.v_0_5_x import solidity_grammar as ast
from securify.solidity.v_0_5_x.solidity_utils import deepcopy_with_mapping


@dataclass(eq=False)
class ProgramBlock:
    cfg: CfgSimple
    first: ir.Block
    last: ir.Goto


def join_returns(cfg, arg_names, function_ast=None):
    """Joins multiple returns in a CFG into a single block

    Given a CFG with multiple return statements, this function will replace the
    returns by gotos to a common join block.
    """
    join_args = [ir.Argument(function_ast, info=n, name=n) for n in arg_names]
    join = ir.Block(function_ast, join_args, info="MERGE RETURNS")

    returns = list(of_type[ir.Return](cfg.graph.nodes))

    if returns:
        cfg += CfgSimple.statement(join)

    # Replace returns with gotos to joining block
    for ret in returns:
        assert len(ret.returns) == len(arg_names), (ret.returns, arg_names)
        goto = ir.Goto(ret.ast_node, join, ret.returns)
        cfg = cfg.replace(ret, goto)
        cfg = cfg + (goto, join)

    return cfg, join_args


def modify_function_body(function_definition: ast.FunctionDefinition,
                         modifiers: List[ast.ModifierInvocation]):
    modifiers = [m for m in modifiers if not m.is_constructor]

    cfg = function_definition.cfg_body
    cfg = wrap_function(cfg,
                        function_definition.arguments,
                        function_definition.returns,
                        function_definition)

    for modifier in reversed(modifiers):
        modifier_arg_cfg: CfgSimple
        modifier_arg_cfg, modifier_arg_evs = modifier.modifier_arguments

        modifier_template, modifier_arguments_original = modifier.modifier_template
        modifier_arguments_original = [a for _, a in modifier_arguments_original]
        modifier_template = deepcopy_with_mapping(
            modifier_template, zip(modifier_arguments_original, modifier_arg_evs))

        cfg = splice_function(modifier_template, cfg)

        if modifier_arg_evs:
            cfg.cfg += modifier_arg_cfg
            cfg.cfg += (modifier_arg_cfg.last_appendable, cfg.first)
            cfg.first = modifier_arg_cfg.first

    last_goto = cfg.last
    if last_goto:
        args_return = last_goto.args[:len(function_definition.return_parameters.parameters)]
        cfg = cfg.cfg
        cfg = cfg.replace(last_goto, ir.Return(last_goto.ast_node, args_return, None))

    cfg_init = function_definition.cfg_return_inits
    cfg_init <<= ir.Block(function_definition,
                          list(map(__[1], function_definition.arguments)),
                          info="FUNCTION INIT")
    cfg_init >>= ir.Goto(function_definition, None,
                         list(map(__[1], function_definition.returns)) +
                         list(map(__[1], function_definition.arguments)))

    # cfg_init >>= ir.MarkerNode("FUNCTION_INIT", function_definition)

    return cfg_init >> cfg


def splice_function(modifier_template: ProgramBlock, inner: ProgramBlock):
    for placeholder in of_type[ir.Placeholder](modifier_template.cfg.graph.nodes):
        modifier_template.cfg = modifier_template.cfg.replace(placeholder, deepcopy(inner.cfg))

    return modifier_template


def wrap_modifier_args(arguments: List[ast.Expression],
                       updated_variables: List[ast.Expression],
                       function_args: List[ir.Argument]):
    arguments = arguments or []
    cfg = CfgSimple.concatenate(*(a.cfg for a in arguments))
    evs = [a.expression_value for a in arguments]

    new_args = [ir.Argument(a.ast_node, info=a.info, name=a.info) for a in function_args]

    cfg, evs, updated_variables = deepcopy_with_mapping(
        (cfg, evs, updated_variables), zip(function_args, new_args))

    cfg <<= ir.Block(None, new_args, info="MODIFIER ARGUMENTS")
    cfg >>= ir.Goto(None, None, args=updated_variables)

    return cfg, evs


def wrap_function(body_cfg: CfgSimple, input_args, return_inits, function_ast=None):
    input_arg_ids, input_args = unzip2(input_args)
    _, return_inits = unzip2(return_inits)

    args = list(return_inits) + list(input_args)
    args_new = [ir.Argument(a.ast_node, info=a.info, name=a.info) for a in args]

    body_cfg = deepcopy_with_mapping(body_cfg, zip(args, args_new))

    start = ir.Block(function_ast, args_new, info="WRAPPED FUNCTION")
    body_cfg <<= CfgSimple.statements(start, ir.Comment(function_ast, "FUNCTION START"))

    returns = list(of_type[ir.Return](body_cfg.graph.nodes))

    # Replace returns with gotos to modifier join
    for ret in returns:
        ret.returns = ret.returns + [ret.variable_map[a.id] for a in input_arg_ids]

    body_cfg, join_args = join_returns(body_cfg, [a.info for a in args])

    last = None
    if returns:
        last = ir.Goto(function_ast, None, join_args)
        body_cfg >>= ir.Comment(function_ast, "FUNCTION END")
        body_cfg >>= last

    return ProgramBlock(body_cfg, start, last)


def replace_with_list(array, element, new_list):
    i = array.index(element)
    return array[:i] + new_list + array[i + 1:]


def expand_placeholders(modifier_cfg, function_arguments, modifier_ast=None):
    # The modifier_cfg argument consists of three elements:
    #   1. The actual cfg without a prefixed block node (!)
    #   2. The list of the arguments that would go into its
    #      entry block node
    #   3. The initial placeholder value that is used to track
    #      the return value of this modifier
    modifier_cfg, modifier_arguments, initial_placeholder_arg = modifier_cfg
    arg_names = [a.info for a in function_arguments]

    def new_arg_set():
        return [ir.Argument(a.ast_node, info=a.info, name=a.info) for a in function_arguments]

    input_arguments = new_arg_set()

    cfg, modifier_arguments, init = deepcopy((modifier_cfg, modifier_arguments, initial_placeholder_arg))

    placeholder_deps = find_placeholder_dependencies(cfg)
    placeholder_deps[init] = init

    # Remove redundant argument assignments to placeholder variable
    # that are typically introduced after block nodes
    for assignment in of_type[ir.Assignment](cfg.graph.nodes):
        if assignment in placeholder_deps:
            cfg = cfg.remove_with_connection(assignment)

    placeholder_map = dict()
    placeholder_map[init] = input_arguments

    # Replace placeholder arguments
    for block in of_type[ir.Block](cfg.graph.nodes):
        placeholder_arg = find(block.args, lambda x: x in placeholder_deps)

        if placeholder_arg:
            args = new_arg_set()
            block.args = replace_with_list(block.args, placeholder_arg, args)
            placeholder_map[placeholder_arg] = args

    # Replace placeholder in transfers
    def replace_placeholder_args(transfer_args):
        ph_arg = find(transfer_args, lambda x: x in placeholder_deps)
        if ph_arg:
            expanded_args = placeholder_map[placeholder_deps[ph_arg]]
            transfer_args = replace_with_list(transfer_args, ph_arg, expanded_args)

        return transfer_args

    for goto in of_type[ir.Goto](cfg.graph.nodes):
        goto.args = replace_placeholder_args(goto.args)

    for branch in of_type[ir.Branch](cfg.graph.nodes):
        branch.true_args = replace_placeholder_args(branch.true_args)
        branch.false_args = replace_placeholder_args(branch.false_args)

    for ret in of_type[ir.Return](cfg.graph.nodes):
        ret.returns = replace_placeholder_args(ret.returns)

    start = ir.Block(modifier_ast, input_arguments, info=f"MODIFIER START {modifier_ast.modifier_name.name}")

    cfg <<= CfgSimple.statements(start, ir.Comment(modifier_ast, "MODIFIER START"))
    cfg, join_args = join_returns(cfg, arg_names, modifier_ast)
    last = ir.Goto(modifier_ast, None, join_args)
    cfg >>= ir.Comment(modifier_ast, "MODIFIER END")
    cfg >>= last

    return ProgramBlock(cfg, start, last), modifier_arguments


def find_placeholder_dependencies(cfg: CfgSimple):
    deps = dict()
    last_length = None

    while len(deps) != last_length:
        last_length = len(deps)

        for node in cfg.graph.nodes:
            if isinstance(node, ir.Block):
                for arg in node.args:
                    if isinstance(arg, ast.PlaceholderArg):
                        deps[arg] = arg

            if isinstance(node, ir.Assignment) and node.expr in deps:
                deps[node] = deps[node.expr]

    return deps


def main():
    from securify.solidity import compile_attributed_ast_from_string, get_solidity_grammar_instance

    # language=Solidity
    code = """
    contract Contract {
        modifier M(uint a) {
            a+=1;
            for(uint i=0;i < a;true) {
                _;
            }
        }
        
        function test(uint a) M(2) public returns(uint) {
            a += a;
            return 1;
        } 
    }
    """

    grammar = get_solidity_grammar_instance()

    root: ast.SourceUnit = compile_attributed_ast_from_string(code)
    ast_function: ast.FunctionDefinition = grammar.visitor().find_descendant_of_type(root, ast.FunctionDefinition)
    ast_modifier: ast.ModifierDefinition = grammar.visitor().find_descendant_of_type(root, ast.ModifierDefinition)

    ast_modifier.modifier_cfg[0].visualize_and_display(name="cfg_0_modifier")
    ast_function.cfg_unmodified.visualize_and_display(name="cfg_1_unmodified")
    ast_function.modifiers[0].modifier_template[0].cfg.visualize_and_display(name="cfg_2_mod_template")
    ast_function.modifiers[0].modifier_arguments[0].visualize_and_display(name="args")
    ast_function.cfg_modified.visualize_and_display(name="cfg_3_modified")

    visualizer.draw_cfg(root.cfg, "cfg_4_full", only_blocks=True)


if __name__ == '__main__':
    main()
