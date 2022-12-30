from graphviz import Digraph

from securify.grammar import Grammar
from securify.solidity.v_0_5_x import solidity_grammar


def render_grammar(grammar: Grammar):
    g = Digraph('production_hierarchy')

    for production, children in grammar.productions.items():
        color = ["black", "red"][grammar.is_abstract_production(production)]
        color = [color, "purple"][hasattr(production, "__is_generated")]

        production_name = production.__name__

        g.node(name=production_name,
               label=production_name,
               color=color,
               shape="hexagon")

        for child_name, child_info in children.items():
            g.node(name=production_name + child_name,
                   label=str(child_info.symbol[0].__name__) + "\n" + child_name,
                   color=color,
                   shape="box")

            g.edge(production_name,
                   production_name + child_name)

    for sub_production, super_productions in grammar.symbol_supertypes.items():
        for super_production in super_productions[:1]:
            g.edge(super_production.__name__,
                   sub_production.__name__, constraint='true')

    return g


if __name__ == '__main__':
    grammar = Grammar.from_modules(solidity_grammar)

    g = render_grammar(grammar)

    g.format = "png"
    g.render("test", cleanup=True)
