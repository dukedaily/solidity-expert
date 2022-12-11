import colorsys
import random
from collections import defaultdict

from graphviz import Digraph, nohtml

from securify.grammar.attributes import AttributeGrammar, AttributedTree
from securify.grammar.attributes.dependencies import DependenceRelation


class AttributeGrammarRenderer:
    def __init__(self, grammar):
        self.grammar = grammar

    def render_tree(self, tree, node_and_attribute, only_loop=False, filter=None):
        attributed_tree = AttributedTree(self.grammar, tree)
        self.filter = filter or []

        g = Digraph('rules', node_attr={'shape': 'none', 'height': '.1'})

        g.attr("graph", splines="polyline")
        g.attr("graph", fontname="Lato Light")
        g.attr("node", fontname="Lato Light")
        g.attr("edge", fontname="Lato Light")

        node_attributes = defaultdict(lambda: set())
        node_dependencies = set()
        seen = set()

        def find_relevant_attributes(node_and_attribute, required_by=None):
            node, attribute = node_and_attribute
            node_attributes[node].add(attribute)

            if required_by is not None:
                node_dependencies.add((node_and_attribute, required_by))

            if node_and_attribute in seen:
                print(f"Attribute '{attribute}' of symbol '{type(node).__name__}' "
                      f"referenced circularly for computing attribute "
                      f"'{required_by[1]}' on '{type(required_by[0]).__name__}'.")
                return

            seen.add(node_and_attribute)

            rule = attributed_tree[node].resolve_rule(attribute)
            dependencies = rule.attribute_dependencies if rule else []

            for dependency in dependencies:
                find_relevant_attributes(dependency, required_by=(node, attribute))

        find_relevant_attributes(node_and_attribute)

        if only_loop:
            dependencies = DependenceRelation(node_dependencies).transitive_closure()

        def add_nodes(node, ancestor, _):
            s = type(node)
            print(s)
            if isinstance(self.grammar, AttributeGrammar):
                dark, light1, light2 = get_colors(node)
                syn = self.grammar.synthesized_attributes[s]
                inh = self.grammar.inherited_attributes[s]

                syn &= node_attributes[node]
                inh &= node_attributes[node]

                syn = [f'<TD BGCOLOR="{light1}" PORT="{a}"> {a}</TD>' for a in syn if not filter or any([x in a for x in filter])]
                inh = [f'<TD BGCOLOR="{light2}" PORT="{a}"> {a}</TD>' for a in inh if not filter or any([x in a for x in filter])]
                plc = [f'<TD></TD>']
                elements = plc + inh + [f'<TD BGCOLOR="{dark}" PORT="node"><FONT COLOR="white">{s.__name__.upper()}</FONT></TD>'] + syn + plc
                elements_joined = ''.join(elements)
                label = f'<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0"><TR>{elements_joined}</TR></TABLE>>'
                g.node(str(id(node)), (f'{label}'))

                if ancestor:
                    g.edge(str(id(ancestor)) + ":node",
                           str(id(node)) + ":node")

            else:
                g.node(str(id(node)), nohtml(s.__name__))
                if ancestor:
                    g.edge(str(id(ancestor)), str(id(node)))

        self.grammar.traverse(tree, add_nodes)

        for ((tn, ta), (sn, sa)) in node_dependencies:
            if sa in self.grammar.inherited_attributes[type(sn)]:
                color = "blue"
                style = "dashed"
            else:
                color = "red"
                style = "dashed"

            if only_loop:
                style = 'invis'

            if only_loop:
                if ((tn, ta), (sn, sa)) in dependencies and ((sn, sa), (tn, ta)) in dependencies:
                    color = "#39FF14"
                    style = "solid"

            if not filter or all([any([f_w in attr for f_w in filter]) for attr in [sa, ta]]):
                g.edge(str(id(sn)) + ":" + sa,
                       str(id(tn)) + ":" + ta, color=color, style=style, constraint='false')

        return g


def get_colors(node):
    h = random.random()

    dark = f'{h}, 1, 0.6'
    light1 = f'{h}, 0.2, 0.8'
    light2 = f'{h}, 0.2, 0.8'
    return dark, light1, light2


