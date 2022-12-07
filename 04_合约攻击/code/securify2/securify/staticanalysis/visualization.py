import html
from itertools import groupby

from graphviz import Digraph

from securify.solidity.utils import of_type, __
from securify.staticanalysis.facts import *


def visualize(facts):
    graph = Digraph()
    graph.attr('graph', fontname='mono')
    graph.attr('node', fontname='mono')

    ignored_facts = (AnnotationFact, SourceInfoFact, StatementFact)
    stmt_map = {s[0]: s for s in facts if not isinstance(s, ignored_facts)}

    block_stmt_map = {b.id_block: [] for b in of_type[BlockFact](facts)}

    for block_stmt in of_type[BlockStmtFact](facts):
        block_stmt_map[block_stmt.id_block].append(block_stmt.id_stmt)

    predecessor_map = {f.id_next: f.id_prev for f in of_type[FollowsFact](facts)}

    for block in of_type[BlockFact](facts):
        def follows_depth(e):
            depth = 0
            while e in predecessor_map:
                e = predecessor_map[e]
                depth += 1

            return depth

        block_stmts = block_stmt_map[block.id_block]
        block_stmts = sorted(block_stmts, key=follows_depth)

        rows = []

        for block_stmt in block_stmts:
            stmt = stmt_map.get(block_stmt)

            if isinstance(stmt, AssignFact):
                rows.append([stmt.id, f" = {stmt.var_id}"])
            elif isinstance(stmt, ConstFact):
                rows.append([stmt.id, f" = {stmt.value}"])
            elif isinstance(stmt, UnaryOpFact):
                rows.append([stmt.id, f" = {stmt.op} {stmt.id_var}"])
            elif isinstance(stmt, BinaryOpFact):
                rows.append([stmt.id, f" = {stmt.id_lhs} {stmt.op} {stmt.id_rhs}"])
            elif isinstance(stmt, StoreFact):
                rows.append([stmt.id, f" = STORE {stmt.field} = {stmt.var_id}"])
            elif isinstance(stmt, LoadFact):
                rows.append([stmt.id, f" = LOAD {stmt.field}"])
            elif isinstance(stmt, MapStoreFact):
                rows.append([stmt.id, f" = MAPSTORE {stmt.id_map}[{stmt.id_key} = {stmt.id_var}"])
            elif isinstance(stmt, MapLoadFact):
                rows.append([stmt.id, f" = MAPLOAD {stmt.id_map}[{stmt.id_key}]"])
            elif isinstance(stmt, ArrayStoreFact):
                rows.append([stmt.id, f" = ARRSTORE {stmt.id_array}[{stmt.id_index}] = {stmt.id_var}"])
            elif isinstance(stmt, ArrayPushFact):
                rows.append([stmt.id, f" = ARRPUSH {stmt.id_array} += [{stmt.id_var}]"])
            elif isinstance(stmt, ArrayLoadFact):
                rows.append([stmt.id, f" = ARRLOAD {stmt.id_array}[{stmt.id_index}]"])
            elif isinstance(stmt, StructStoreFact):
                rows.append([stmt.id, f" = {stmt.id_struct} -> {stmt.field} = {stmt.id_var}"])
            elif isinstance(stmt, StructLoadFact):
                rows.append([stmt.id, f" = {stmt.id_struct} -> {stmt.field}"])
            elif isinstance(stmt, BuiltinVariableFact):
                rows.append([stmt.id, f" = {stmt.name}"])
            elif isinstance(stmt, SelfDestructFact):
                rows.append([stmt.id, f" = SELFDESTRUCT({stmt.id_address})"])
            elif isinstance(stmt, EmitFact):
                rows.append([stmt.id, f" = EMIT({stmt})"])
            elif isinstance(stmt, BalanceFact):
                rows.append([stmt.id, f" = BALANCE({stmt.id_address})"])
            elif isinstance(stmt, BuiltinFunctionFact):
                rows.append([stmt.id, f" = {stmt.name} ({stmt.arg})"])
            else:
                raise NotImplementedError(stmt, block_stmt)

        def render_row(row):
            tds = [f"<TD ALIGN='left'> {html.escape(r)} </TD>" for r in row]
            # print(tds)
            return f"<TR> {' '.join(tds)} </TR>"

        rows.insert(0, ["BLOCK", block.id_block])

        trs = [render_row(r) for r in rows]

        branch = [t for t in of_type[BranchFact](facts) if t.id_block_from == block.id_block]
        goto = [t for t in of_type[GotoFact](facts) if t.id_block_from == block.id_block]
        jump = [t for t in of_type[JumpFact](facts) if t.id_block_from == block.id_block]
        call = [t for t in of_type[CallFact](facts) if t.id_block_from == block.id_block]
        ret = [t for t in of_type[ReturnFact](facts) if t.id_block_from == block.id_block]
        revert = [t for t in of_type[RevertFact](facts) if t.id_block_from == block.id_block]
        stop = [t for t in of_type[StopFact](facts) if t.id_block_from == block.id_block]

        trs.append(
            render_row([goto[0].id_transfer, "GOTO"]) if goto else
            render_row([jump[0].id_transfer, "JUMP " + jump[0].id_block_to]) if jump else
            render_row([call[0].id_transfer, "CALL"]) if call else
            render_row([ret[0].id_transfer, "RETURN"]) if ret else
            render_row([revert[0].id_transfer, "REVERT"]) if revert else
            render_row([stop[0].id_transfer, "STOP"]) if stop else
            render_row([branch[0].id_transfer_true.split("_")[0], ":: " + branch[0].var_cond_id]) if branch else
            render_row(["TXX", "N/A"])
        )

        # language=HTML
        label = f"""
        <TABLE>
            {' '.join(trs)} 
        </TABLE>
        """

        graph.node(block.id_block, label=f"<{label}>", shape='none')

    block_graph_map = {f.id_block: Digraph() for f in of_type[BlockFact](facts)}

    for sg in block_graph_map.values():
        graph.subgraph(sg)

    transfer_map = {k: list(v) for k, v in groupby(of_type[TransferArgumentFact](facts), __.id_transfer)}

    for transfer in of_type[BranchFact](facts):
        s = transfer.id_block_from
        t = transfer.id_block_true
        f = transfer.id_block_false

        tt = (sorted(transfer_map.get(transfer.id_transfer_true, []), key=__.index))
        tf = (sorted(transfer_map.get(transfer.id_transfer_false, []), key=__.index))

        tt = [t.id_argument_value for t in tt]
        tf = [t.id_argument_value for t in tf]

        graph.edge(s, t, label=" " + ", ".join(tt))
        graph.edge(s, f, label=" " + ", ".join(tf))

    for transfer in of_type[GotoFact](facts):
        s = transfer.id_block_from
        t = transfer.id_block_to

        tt = (sorted(transfer_map.get(transfer.id_transfer, []), key=__.index))
        tt = [t.id_argument_value for t in tt]

        graph.edge(s, t, label=" " + ", ".join(tt))

    for transfer in of_type[(JumpFact, CallFact)](facts):
        s = transfer.id_block_from
        t = transfer.id_continuation

        tt = (sorted(transfer_map.get(transfer.id_transfer, []), key=__.index))
        tt = [t.id_argument_value for t in tt]

        graph.edge(s, t, label=" " + ", ".join(tt))

    return graph


def visualize2(facts):
    graph = Digraph()
    graph.attr('graph', fontname='mono')
    graph.attr('node', fontname='mono')

    stmt_block_map = {f.id_stmt: f.id_block for f in facts if isinstance(f, BlockStmtFact)}

    block_graph_map = {f.id_block: Digraph() for f in facts if isinstance(f, BlockFact)}

    for fact in facts:
        if not isinstance(fact, statement_facts):
            continue

        g: Digraph = block_graph_map[stmt_block_map[fact.id]]

        kw_args_node = {'shape': 'box'}

        if isinstance(fact, AssignFact):
            g.node(fact.id, f"{fact.id} = {fact.var_id}", **kw_args_node)
        elif isinstance(fact, ConstFact):
            g.node(fact.id, f"{fact.id} = {fact.value}", **kw_args_node)
        elif isinstance(fact, BinaryOpFact):
            g.node(fact.id, f"{fact.id} = {fact.id_lhs} {fact.op} {fact.id_rhs}", **kw_args_node)
        else:
            raise NotImplementedError(fact)

    for fact in facts:
        if not isinstance(fact, FollowsFact):
            continue

        g: Digraph = block_graph_map[stmt_block_map[fact.id_next]]
        g.edge(fact.id_next, fact.id_prev)

    for sg in block_graph_map.values():
        graph.subgraph(sg)

    return graph
