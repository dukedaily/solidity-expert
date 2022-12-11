from graphviz import Digraph

from .ast_visualizer import ASTVisualiser
from .cfg_visualizer import CFGVisualiser


def draw_ast(root, file='ast', reduced=False, format='svg', highlight=None, view=False):
    dot = ASTVisualiser(root).start(combined=False, reduced=reduced, highlight=highlight)
    dot.format = format
    dot.render(view=view, cleanup=True, filename=file)


def draw_cfg(root, file='cfg', only_blocks=False, format='svg', view=False):
    dot = CFGVisualiser(root).start(only_blocks, combined=False)
    dot.format = format
    dot.render(view=view, cleanup=True, filename=file)


def draw_combined(ast_root, cfg_root, reduced=True, only_blocks=False, format='png', highlight=None):
    ast_dot = ASTVisualiser(ast_root).start(combined=True, reduced=reduced, highlight=highlight)
    cfg_dot = CFGVisualiser(cfg_root).start(only_blocks=only_blocks, combined=True)

    dot = Digraph(strict=True)
    dot.attr('graph', fontname='helvetica')
    dot.attr('graph', splines='polyline')
    dot.attr('graph', compound='true')

    dot.attr('node', fontname='helvetica')
    dot.attr('node', style='filled', fillcolor='white')

    dot.attr('edge', fontname='helvetica')
    dot.subgraph(ast_dot)
    dot.subgraph(cfg_dot)
    dot.format = format
    dot.engine = 'dot'
    dot.render(view=True, cleanup=True, filename='Combined')
