import json
import os
from pprint import pprint

from securify.ir import visualizer
from securify.solidity import compile_cfg

if __name__ == '__main__':
    compile_output = compile_cfg(os.getcwd() + '/contract0.sol')

    cfg, ast, ast_dict, ast_attr = compile_output

    pprint(ast_dict)

    compile_output.compilation_stats.pprint()

    visualizer.draw_ast(ast, format='pdf', highlight=['FunctionCall'])
    # pprint(grammar.grammar_info())

    # q = AttributeGrammarRenderer(grammar).render_tree(ast.nodes[1].nodes[0],
    #                             (ast.nodes[1].nodes[0], 'cfg'), True, None)
    # q.format = 'pdf'
    # q.render('test', view=True, cleanup=True)

    # ast.nodes[2].nodes[1].cfg.cfg.visualize_and_display()

    # ast_attr.nodes[2].cfg_state_init.graph.pprint()
    # ast_attr.nodes[2].cfg_state_init.visualize_and_display(name="init")

    visualizer.draw_cfg([cfg], only_blocks=True, view=False, format='svg')
    # visualizer.draw_combined(ast_root, cfg, only_blocks=True)
