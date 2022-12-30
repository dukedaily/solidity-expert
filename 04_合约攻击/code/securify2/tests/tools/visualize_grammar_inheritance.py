from graphviz import Digraph

from securify.grammar import Grammar
from securify.solidity.v_0_5_x import solidity_grammar


def render_grammar(grammar: Grammar):
    g = Digraph('production_hierarchy')

    for production in grammar.symbols:
        color = ["black", "red"][grammar.is_abstract_production(production)]
        color = [color, "purple"][hasattr(production, "__is_generated")]

        g.node(name=production.__name__,
               label=production.__name__,
               color=color,
               shape="box")

    for sub_production, super_productions in grammar.symbol_supertypes.items():
        for super_production in super_productions[:1]:
            g.edge(super_production.__name__,
                   sub_production.__name__)

    return g


if __name__ == '__main__':
    grammar = Grammar.from_modules(solidity_grammar)

    g = render_grammar(grammar)

    g.format = "png"
    g.render("test", cleanup=True)
