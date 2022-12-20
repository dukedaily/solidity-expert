from __future__ import annotations

from securify.grammar import abstract_production, production
from securify.grammar.attributes import AttributeGrammar
from securify.grammar.attributes.annotations3 import synthesized, pushdown, Parser, inherited


@abstract_production
class NodeBase:
    a: str = inherited(implicit_pushdown=True)


@production
class NodeA(NodeBase):
    node: NodeBase

    def __init__(self, node):
        self.node = node

    @pushdown
    def explicit_a(self) -> NodeBase.a @ node:
        return "changed", self.a


@production
class NodeB(NodeBase):
    node: NodeC

    def __init__(self, node):
        self.node = node


@production
class NodeC(NodeBase):
    node: NodeD

    def __init__(self, node):
        self.node = node


@production
class NodeD(NodeBase):
    test = synthesized()
    @synthesized
    def test(self):
        return self.a


def main():
    grammar = AttributeGrammar([
        NodeBase,
        NodeA,
        NodeB,
        NodeC,
        NodeD
    ], Parser())

    from pprint import pprint
    pprint(grammar.grammar_info())


if __name__ == '__main__':
    main()
