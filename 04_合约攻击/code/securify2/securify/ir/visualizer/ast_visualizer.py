import html
import pprint

from graphviz import Digraph

import securify.solidity.v_0_5_x.solidity_grammar as ast
from securify.grammar.attributes import AttributeGrammarError
from securify.ir.visualizer import utils


class ASTVisualiser:
    def __init__(self, root):
        self.root = root

    def handle_child(self, dot_id, dot, child, child_attr, children, children_ids):
        if isinstance(child_attr, (dict, int, str)) and '__' not in child and not child.startswith("_"):
            child_attr = pprint.pformat(child_attr, width=50) if isinstance(child_attr, dict) else str(child_attr)
            child_attr = html.escape(child_attr, quote=False)[:43]

            child_label = f'<TR><TD ALIGN="LEFT">{child}</TD><TD ALIGN="LEFT">{child_attr}</TD></TR>'

            if not self.reduced:
                children.append(child_label)

        else:
            child_id = self.draw_node(child_attr, dot)

            if child_id:
                child_type = type(child_attr).__name__
                children_ids.add(child_id)
                children.append(
                    f'<TR>'
                    f'  <TD ALIGN="LEFT">{child}</TD>'
                    f'  <TD PORT="{child_id}" ALIGN="LEFT">{child_type} {child_attr.id}</TD>'
                    f'</TR>')
                dot.edge(f'{dot_id}:{child_id}', child_id)

    def draw_node(self, node, dot):
        if not isinstance(node, ast.AstNode):
            return False
        dot_id = utils.node_id(node)
        children = []
        children_ids = set()
        for child in dir(node):
            if child == 'original':
                continue

            if child.startswith("_"):
                continue

            try:
                if getattr(node.__class__, child, None) is not None:
                    continue

                child_attr = getattr(node, child)

            except AttributeGrammarError:
                continue

            if isinstance(child_attr, list):
                for i, child_attr_member in enumerate(child_attr):
                    self.handle_child(dot_id, dot, f'{child}{i}', child_attr_member, children, children_ids)
            else:
                self.handle_child(dot_id, dot, child, child_attr, children, children_ids)

        children_label = ''.join(children)
        bg_color = utils.AST_HEADER_COLOR
        font_color = 'white'
        if any([hl in type(node).__name__ for hl in self.highlight]):
            bg_color = utils.AST_HL_COLOR
            font_color = 'black'
        node_label = f'<TR><TD COLSPAN="2" BGCOLOR="{bg_color}"><FONT COLOR="{font_color}">{type(node).__name__} {node.id}</FONT></TD></TR>'
        label = f'<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">{node_label}{children_label}</TABLE>>'
        dot.node(dot_id, label=label, shape='none')

        with dot.subgraph() as s:
            s.attr(rank='same')
            for n in children_ids:
                s.node(n)

        return dot_id

    def start(self, combined=False, reduced=True, highlight=None):
        self.combined = combined
        self.reduced = reduced
        self.highlight = highlight if highlight is not None else []

        name = 'cluster_AST' if self.combined else 'AST'
        dot = Digraph(name=name)
        if not self.combined:
            dot.attr('graph', fontname='consolas')
            dot.attr('node', fontname='consolas')
            dot.attr('edge', fontname='consolas')
        self.draw_node(self.root, dot)

        return dot
