from __future__ import annotations

from securify.grammar import production
from securify.grammar.attributes import AttributeGrammar
from securify.grammar.attributes.annotations3 import synthesized, Parser
from securify.grammar.attributes.evaluators import DemandDrivenRecursive


@production
class Test:
    print = synthesized()
    test = synthesized()

    @synthesized
    def print(self):
        print("this should be printed once!")
        return 0

    @synthesized
    def test(self: {Test.print}):
        return "this should be printed after the above string"


grammar = AttributeGrammar([Test], Parser())

root = DemandDrivenRecursive(grammar).for_tree(Test())

print(root.test)
print(root.print)
