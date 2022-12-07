from functools import singledispatch, update_wrapper

from graphviz import Digraph

from securify.ir import cfg_ir
from securify.ir import cfg_ir as ir
from securify.ir.visualizer import utils
from securify.ir.visualizer.ast_visualizer import ASTVisualiser


def singledispatch_method(func):
    """Helper for supporting single dispatch with a self argument"""
    dispatcher = singledispatch(func)

    def wrapper(*args, **kw):
        return dispatcher.dispatch(args[1].__class__)(*args, **kw)

    wrapper.register = dispatcher.register
    update_wrapper(wrapper, func)
    return wrapper


class CFGVisualiser:
    def __init__(self, root):
        self.root = root
        self.draw_map = {'SourceUnit': self.draw_source_unit,
                         'Contract': self.draw_contract,
                         'Block': self.draw_block,
                         'Function': self.draw_function,
                         'Statement': self.draw_statement,
                         'Placeholder': self.draw_placeholder,
                         'Assignment': self.draw_assignment,
                         'ContractVariableAssignment': self.draw_assignment,
                         'Parameter': self.draw_parameter,
                         'Argument': self.draw_argument,
                         'Collection': self.draw_collection,
                         'IndexAccess': self.draw_index,
                         'BinaryOp': self.draw_binop,
                         'Emit': self.draw_emit,
                         'StateVariableLoad': self.draw_state_variable_load,
                         'StateVariableStore': self.draw_state_variable_store,
                         'Array': self.draw_array,
                         'ArrayLoad': self.draw_array_load,
                         'ArrayStore': self.draw_array_store,
                         'Mapping': self.draw_mapping,
                         'MappingLoad': self.draw_mapping_load,
                         'MappingStore': self.draw_mapping_store,
                         }

        self.function_map = {}
        self.missing_links = list()
        self.ast_visualizer = ASTVisualiser(None)

    @singledispatch_method
    def draw_node(self, node: ir.CFGNode, dot):
        impl = self.draw_map.get(type(node).__name__, None)

        if impl is None:
            return "-1"

        return impl(node, dot)

    def start(self, only_blocks=False, combined=False):
        self.only_blocks = only_blocks
        self.combined = combined
        name = 'cluster_CFG' if self.combined else 'CFG'
        dot = Digraph(name=name)
        if not self.combined:
            dot.attr('graph', fontname='helvetica')
            dot.attr('graph', splines='spline')
            dot.attr('graph', compound='true')

            dot.attr('node', fontname='helvetica')
            dot.attr('node', style='filled', fillcolor='white')

            dot.attr('edge', fontname='helvetica')

        for node in (self.root if isinstance(self.root, list) else [self.root]):
            subgraph = Digraph()
            self.draw(node, subgraph)
            dot.subgraph(subgraph)

        for link in self.missing_links:
            dot.edge(**link)

        return dot

    def draw(self, node, dot):
        if node is None:
            return '-1'

        if hasattr(node, 'drawn'):
            return utils.node_id(node)

        node.drawn = True
        node_id = self.draw_node(node, dot)

        if self.combined:
            dot.edge(node_id, utils.node_id(node.ast_node), style='solid', color=utils.AST_CFG_COLOR)
        return node_id

    @draw_node.register
    def draw_source_unit(self, node: ir.SourceUnit, dot):
        contracts = [self.draw(c, dot) for c in node.contracts if c.ast_node.contract_kind in {"library", "contract"}]
        # for a, b in zip(contracts[:-1], contracts[1:]):
        #     dot.edge(a, b)

        return 0

    def draw_contract(self, node, dot):
        _dot_id = utils.node_id(node)
        contract_dot = Digraph(name=f'cluster_{id(node)}')
        dot.node(_dot_id,
                 label=f'<<TABLE><TR><TD BGCOLOR="{utils.HEADER_COLOR}"><FONT COLOR="white">Contract {node.name}</FONT></TD></TR></TABLE>>',
                 shape='none')

        for _, function_node in node.functions.items():
            self.draw(function_node, contract_dot)

        # for _, variable in node.variables.items():
        #     self.draw(variable.value, contract_dot)

        dot.subgraph(contract_dot)

        return _dot_id

    def draw_function(self, node: ir.Function, dot):
        _dot_id = utils.node_id(node)
        function_dot = Digraph(name=f'cluster_{id(node)}')
        function_dot.attr('graph', style='filled', bgcolor='#DDDDDD')

        label = "Constructor" if node.constructor else "Function"
        label = f"{label} {node.name} \n ({node.visibility})"

        dot.node(_dot_id, label=label, style='filled',
                 fillcolor=utils.FUNCTION_COLOR,
                 shape='folder', fontcolor='white')
        body_id = self.draw(node.cfg, function_dot)
        dot.edge(_dot_id, body_id)
        dot.subgraph(function_dot)
        return _dot_id

    def draw_statement(self, node, dot):
        return self.draw(node.expr, dot)

    def draw_parameter(self, node, dot):
        _dot_id = utils.node_id(node)
        dot.node(_dot_id, label='Parameter %s' % node.name)
        return _dot_id

    def draw_argument(self, node, dot):
        _dot_id = utils.node_id(node)
        dot.node(_dot_id, label='Argument %s' % node.index)
        return _dot_id

    @draw_node.register
    def draw_const(self, node: ir.Const, dot):
        _dot_id = utils.node_id(node)
        dot.node(_dot_id, label='%s' % node.value, shape='ellipse', fillcolor=utils.CONST_COLOR)
        return _dot_id

    # def draw_magic_var(self, node: cfg_ir.Value, dot):
    #     _dot_id = utils.node_id(node)
    #     dot.node(_dot_id, label='%s' % node.variable, shape='circle')
    #     return _dot_id

    def draw_collection(self, node, dot):
        pass

    def draw_index(self, node, dot):
        pass

    @draw_node.register
    def draw_member_load(self, node: ir.MemberLoad, dot):
        _dot_id = utils.node_id(node)
        table_label = '<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">'
        name_label = f'<TR><TD>LOAD MEMBER {node.base}</TD></TR>'
        index_label = f'<TD PORT="{node.member}">{node.member}</TD>'
        label = f'<{table_label}{name_label}<TR>{index_label}</TR></TABLE>>'
        dot.node(_dot_id, label=label, shape="none")
        return _dot_id

    @draw_node.register
    def draw_member_store(self, node: ir.MemberStore, dot):
        _dot_id = utils.node_id(node)
        expr_id = self.draw(node.expr, dot)
        table_label = '<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">'
        name_label = f'<TR><TD COLSPAN="2">STORE MEMBER {node.base}</TD></TR>'
        index_label = f'<TD PORT="{node.member}">{node.member}</TD>'
        expr_label = f'<TD PORT="{expr_id}">Expression</TD>'
        label = f'<{table_label}{name_label}<TR>{index_label}{expr_label}</TR></TABLE>>'
        dot.edge(f'{_dot_id}:{expr_id}', expr_id, label='expression')
        dot.node(_dot_id, label=label, shape="none")
        return _dot_id

    def draw_binop(self, node, dot):
        _dot_id = utils.node_id(node)
        dot.node(_dot_id, label='%s' % node.op, shape='circle')
        lhs = self.draw(node.lhs, dot)
        rhs = self.draw(node.rhs, dot)
        dot.edge(_dot_id, lhs)
        dot.edge(_dot_id, rhs)
        return _dot_id

    @draw_node.register
    def draw_unop(self, node: ir.UnaryOp, dot):
        _dot_id = utils.node_id(node)
        dot.node(_dot_id, label=node.op, shape='ellipse')
        sub = self.draw(node.sub, dot)
        dot.edge(_dot_id, sub)
        return _dot_id

    @draw_node.register
    def draw_destruct(self, node: ir.SelfDestruct, dot):
        _dot_id = utils.node_id(node)
        dot.node(_dot_id, label="Address", shape='ellipse')
        sub = self.draw(node.address, dot)
        dot.edge(_dot_id, sub)
        return _dot_id

    def draw_emit(self, node, dot):
        # _dot_id = utils.node_id(node)
        # sub = self.draw(node, dot)
        return None

    def draw_state_variable_load(self, node, dot):
        _dot_id = utils.node_id(node)
        dot.node(_dot_id, label=str(node), shape='hexagon')
        return _dot_id

    def draw_state_variable_store(self, node, dot):
        _dot_id = utils.node_id(node)
        if self.only_blocks:
            label = str(node)
        else:
            label = f'STORE {node.name}'
            expr_id = self.draw(node.expr, dot)
            dot.edge(_dot_id, expr_id, label='stores')
        dot.node(_dot_id, label=label, shape='hexagon')
        return _dot_id

    def draw_array(self, node, dot):
        _dot_id = utils.node_id(node)
        dot.node(_dot_id, label=f'Array {node.name}', shape='note')
        if node.expressions:
            for e in node.expressions:
                dot.edge(_dot_id, self.draw(e, dot))

        return _dot_id

    def draw_array_load(self, node, dot):
        _dot_id = utils.node_id(node)
        base_id = self.draw(node.base, dot)
        index_id = self.draw(node.index, dot)
        table_label = '<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">'
        store_label = f'<TR><TD COLSPAN="2" >LOAD ARRAY</TD></TR>'
        base_label = f'<TD PORT="{base_id}">Base</TD>'
        index_label = f'<TD PORT="{index_id}">Index</TD>'
        label = f'<{table_label}{store_label}<TR>{base_label}{index_label}</TR></TABLE>>'
        dot.edge(f'{_dot_id}:{base_id}', base_id, label='base')
        dot.edge(f'{_dot_id}:{index_id}', index_id, label='index')
        dot.node(_dot_id, label=label, shape="none")
        return _dot_id

    def draw_array_store(self, node, dot):
        _dot_id = utils.node_id(node)
        if self.only_blocks:
            label = f'STORE ARRAY {node.base}[{node.index}] = {node.expr}'
        else:
            base_id = self.draw(node.base, dot)
            index_id = self.draw(node.index, dot)
            expr_id = self.draw(node.expr, dot)
            table_label = '<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">'
            store_label = f'<TR><TD COLSPAN="3" >STORE ARRAY</TD></TR>'
            base_label = f'<TD PORT="{base_id}">Base</TD>'
            index_label = f'<TD PORT="{index_id}">Index</TD>'
            expr_label = f'<TD PORT="{expr_id}">Expression</TD>'
            label = f'<{table_label}{store_label}<TR>{base_label}{index_label}{expr_label}</TR></TABLE>>'
            dot.edge(f'{_dot_id}:{base_id}', base_id, label='base')
            dot.edge(f'{_dot_id}:{index_id}', index_id, label='index')
            dot.edge(f'{_dot_id}:{expr_id}', expr_id, label='expression')
        dot.node(_dot_id, label=label, shape="none")
        return _dot_id

    def draw_mapping(self, node, dot):
        _dot_id = utils.node_id(node)
        dot.node(_dot_id, label=f'Mapping {node.name}', shape='square')
        return _dot_id

    def draw_mapping_load(self, node, dot):
        _dot_id = utils.node_id(node)
        index_id = self.draw(node.index, dot)
        table_label = '<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">'
        name_label = f'<TR><TD>LOAD MAPPING {node.mapping}</TD></TR>'
        index_label = f'<TD PORT="{index_id}">Index</TD>'
        label = f'<{table_label}{name_label}<TR>{index_label}</TR></TABLE>>'
        dot.edge(f'{_dot_id}:{index_id}', index_id, label='index')
        dot.node(_dot_id, label=label, shape="none")
        return _dot_id

    def draw_mapping_store(self, node, dot):
        _dot_id = utils.node_id(node)
        if self.only_blocks:
            label = f'STORE MAPPING{node.name}[{node.index}] = {node.expr}'
        else:
            index_id = self.draw(node.index, dot)
            expr_id = self.draw(node.expr, dot)
            table_label = '<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">'
            name_label = f'<TR><TD COLSPAN="2">STORE MAPPING {node.mapping}</TD></TR>'
            index_label = f'<TD PORT="{index_id}">Index</TD>'
            expr_label = f'<TD PORT="{expr_id}">Expression</TD>'
            label = f'<{table_label}{name_label}<TR>{index_label}{expr_label}</TR></TABLE>>'
            dot.edge(f'{_dot_id}:{index_id}', index_id, label='index')
            dot.edge(f'{_dot_id}:{expr_id}', expr_id, label='expression')
        dot.node(_dot_id, label=label, shape="none")
        return _dot_id

    @draw_node.register
    def draw_magic_variable(self, node: ir.MagicVariable, dot):
        _dot_id = utils.node_id(node)
        dot.node(_dot_id, label='%s' % node.variable, shape='ellipse')
        return _dot_id

    def draw_block(self, node, dot):
        _dot_id = utils.node_id(node)
        args = ', '.join(str(arg) for arg in node.args)
        if args == '':
            args = ' '
        if self.only_blocks:
            args_label = f'<TD COLSPAN="2" BGCOLOR="{utils.ARGS_COLOR}">{args}</TD>'
        else:
            args_label = f'<TD BGCOLOR="{utils.ARGS_COLOR}">{args}</TD>'
        stmts = []
        for stmt in node.stmts:
            stmt_id = utils.node_id(stmt)
            stmt_type = type(stmt.expr).__name__
            if self.only_blocks:
                if self.combined:
                    dot.edge(f'{_dot_id}:{stmt_id}', utils.node_id(stmt.ast_node), style='solid',
                             color=utils.AST_CFG_COLOR)
                stmts.append(f'<TR><TD>{stmt_type}</TD><TD PORT="{stmt_id}">{str(stmt.expr)}</TD></TR>')
            else:
                if isinstance(stmt.expr, cfg_ir.Comment):
                    stmts.append(
                        f'<TR><TD PORT="{stmt_id}" BGCOLOR="{utils.COMMENT_COLOR}"> # {stmt.expr.comment} # </TD></TR>')
                else:
                    stmts.append(f'<TR><TD PORT="{stmt_id}"> {stmt_type} {stmt.expr.info}</TD></TR>')
                    expr_id = self.draw(stmt, dot)
                    if expr_id is not None:
                        dot.edge(f'{_dot_id}:{stmt_id}', expr_id, color=utils.CFG_STMT_COLOR)

        stmts_label = ''.join(stmts)

        transfer_label = self.visit_transfer(node.transfer, dot, _dot_id)
        table_label = '<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" bgcolor="WHITE">'
        if self.only_blocks:
            block_label = f'<TD COLSPAN="2" BGCOLOR="{utils.HEADER_COLOR}"><FONT COLOR="white">{node.info or node.id}</FONT></TD>'
        else:
            block_label = f'<TD BGCOLOR="{utils.HEADER_COLOR}"><FONT COLOR="white">{node.info or node.id}</FONT></TD>'
        label = f'<{table_label}<TR>{block_label}</TR><TR>{args_label}</TR>{stmts_label}<TR>{transfer_label}</TR></TABLE>>'
        dot.node(_dot_id, label=label, shape='none', style="")

        return _dot_id

    def draw_assignment(self, node, dot):
        _dot_id = utils.node_id(node)
        label = f'{node.info}='
        dot.node(_dot_id, label, shape='box')
        expr = self.draw(node.expr, dot)
        dot.edge(_dot_id, expr)

        return _dot_id

    def draw_placeholder(self, node, dot):
        _dot_id = utils.node_id(node)
        label = f'PlaceholderResultExpr'
        dot.node(_dot_id, label, shape='box')

        return _dot_id

    def visit_transfer(self, node, dot, parent_id):
        visit_map = {'Jump': self.visit_jump,
                     'Return': self.visit_return,
                     'Halt': self.visit_halt,
                     'Call': self.visit_call,
                     'Branch': self.visit_branch,
                     'Goto': self.visit_goto}

        node_type = type(node).__name__
        visit_function = visit_map.get(node_type)
        if visit_function is None:
            if self.only_blocks:
                return f'<TD COLSPAN="2" BGCOLOR="#bc1f00">NO TRANSFER</TD>'
            else:
                return f'<TD BGCOLOR="#bc1f00">NO TRANSFER</TD>'
        return visit_function(node, dot, parent_id)

    def visit_return(self, node, dot, parent_id):
        _dot_id = utils.node_id(node)
        label = f'<TD COLSPAN="2" BGCOLOR="{utils.ARGS_COLOR}" PORT="{_dot_id}"> {str(node)}</TD>'
        if not self.only_blocks:
            label = f'<TD BGCOLOR="{utils.ARGS_COLOR}" PORT="{_dot_id}">Return</TD>'
            for ret in node.returns:
                returns_id = self.draw(ret, dot)
                dot.edge('%s:%s' % (parent_id, _dot_id), returns_id, label='returns', color=utils.CFG_STMT_COLOR)
        return label

    def visit_halt(self, node, dot, parent_id):
        _dot_id = utils.node_id(node)
        label = f'<TD COLSPAN="2" BGCOLOR="{utils.ARGS_COLOR}" PORT="{_dot_id}"> {str(node)}</TD>'
        if not self.only_blocks:
            label = f'<TD BGCOLOR="{utils.ARGS_COLOR}" PORT="{_dot_id}">{node}</TD>'

        return label

    def visit_jump(self, node, dot, parent_id):
        _dot_id = utils.node_id(node)
        if self.only_blocks:
            label = f'<TD COLSPAN="2" BGCOLOR="{utils.ARGS_COLOR}" PORT="{_dot_id}">Jump</TD>'
        else:
            label = f'<TD BGCOLOR="{utils.ARGS_COLOR}" PORT="{_dot_id}">Jump</TD>'

        dst_id = utils.node_id(node.dst)
        cont_id = self.draw(node.continuation, dot)
        edge_attributes = {'tail_name': f'{parent_id}:{_dot_id}',
                           'head_name': dst_id,
                           'label': ', '.join([f'{str(arg)}' for arg in node.args]),
                           'constraint': 'false',
                           'style': 'dashed',
                           'fontcolor': utils.JUMP_COLOR,
                           'color': utils.JUMP_COLOR}
        self.missing_links.append(edge_attributes)
        dot.edge('%s:%s' % (parent_id, _dot_id), cont_id, label=', '.join([f'{str(arg)}' for arg in node.continuation.args]),
                 fontcolor=utils.GOTO_COLOR, color=utils.GOTO_COLOR)
        return label

    def visit_call(self, node: ir.Call, dot, parent_id):
        _dot_id = utils.node_id(node)
        if self.only_blocks:
            label = f'<TD COLSPAN="2" BGCOLOR="{utils.ARGS_COLOR}" PORT="{_dot_id}">Call</TD>'
        else:
            label = f'<TD BGCOLOR="{utils.ARGS_COLOR}" PORT="{_dot_id}">Call</TD>'
        dst_id = utils.node_id(node.dst) + _dot_id
        dot.node(dst_id, label=f'Function {node.dst}', style='filled', fillcolor=utils.HEADER_COLOR,
                 shape='doubleoctagon', fontcolor='white')

        cont_id = self.draw(node.continuation, dot)
        edge_attributes = {'tail_name': f'{parent_id}:{_dot_id}',
                           'head_name': dst_id,
                           'label': ', '.join([f'{str(arg)}' for arg in node.args]),
                           'constraint': 'true',
                           'style': 'dashed',
                           'fontcolor': utils.CALL_COLOR,
                           'color': utils.CALL_COLOR}
        self.missing_links.append(edge_attributes)
        dot.edge('%s:%s' % (parent_id, _dot_id), cont_id, label=', '.join([f'{str(arg)}' for arg in node.continuation.args]),
                 fontcolor=utils.GOTO_COLOR, color=utils.GOTO_COLOR)
        return label

    def visit_branch(self, node, dot, parent_id):
        _dot_id = utils.node_id(node)
        label = f'<TD COLSPAN="2" BGCOLOR="{utils.ARGS_COLOR}" PORT="{_dot_id}">Branch {str(node.cond)}</TD>'
        true_id = self.draw(node.true_block, dot)
        false_id = self.draw(node.false_block, dot)
        if not self.only_blocks:
            label = f'<TD BGCOLOR="{utils.ARGS_COLOR}" PORT="{_dot_id}">Branch</TD>'
            cond_id = self.draw(node.cond, dot)
            dot.edge('%s:%s' % (parent_id, _dot_id), cond_id, label='condition', fontcolor=utils.CONDITION_COLOR,
                     color=utils.CONDITION_COLOR)
        true_args_string = ', '.join([f'{str(arg)}' for arg in node.true_args])
        false_args_string = ', '.join([f'{str(arg)}' for arg in node.false_args])

        if true_args_string.strip() != "":
            true_args_string = f"[{true_args_string}]"

        if false_args_string.strip() != "":
            false_args_string = f"[{false_args_string}]"

        dot.edge('%s:%s' % (parent_id, _dot_id), true_id, label=f'True {true_args_string}', fontcolor=utils.TRUE_COLOR,
                 color=utils.TRUE_COLOR)
        dot.edge('%s:%s' % (parent_id, _dot_id), false_id, label=f'False {false_args_string}',
                 fontcolor=utils.FALSE_COLOR, color=utils.FALSE_COLOR)
        return label

    def visit_goto(self, node, dot, parent_id):
        _dot_id = utils.node_id(node)
        if self.only_blocks:
            label = f'<TD COLSPAN="2" BGCOLOR="{utils.ARGS_COLOR}" PORT="{_dot_id}">Goto</TD>'
        else:
            label = f'<TD BGCOLOR="{utils.ARGS_COLOR}" PORT="{_dot_id}">Goto</TD>'
        block_id = self.draw(node.block, dot)
        dot.edge('%s:%s' % (parent_id, _dot_id), block_id, label=', '.join([f'{str(arg)}' for arg in node.args]),
                 fontcolor=utils.GOTO_COLOR, color=utils.GOTO_COLOR)
        return label

    def link_node(self, fcd_node, dot):
        dot.edge(fcd_node.dispatch_node, self.function_map.get(fcd_node.function_name).entry_node)
        dot.edge(self.function_map.get(fcd_node.function_name).exit_node, fcd_node.return_node)
