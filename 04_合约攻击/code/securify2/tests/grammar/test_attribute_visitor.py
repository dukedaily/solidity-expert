import unittest

from securify.grammar.attributes import AttributeGrammar
from securify.grammar.attributes.annotations3 import Parser
from securify.grammar.attributes.evaluators import DemandDrivenRecursive
from tests.grammar.grammars import arithmetic


class AttributeVisitorTest(unittest.TestCase):
    grammar = AttributeGrammar.from_modules(arithmetic, rule_extractor=Parser())
    visitor = grammar.attribute_visitor()

    def test_attribute_visitor(self):
        tree = arithmetic.parse_rpn("1 2 + 2.5 * 2 5 SUM")

        tree.depth = 0
        tree.index = None

        tree = DemandDrivenRecursive(self.grammar).for_tree(tree)

        def print_attribute(node, attribute):
            getattr(node, attribute)

        self.visitor.visit(tree, print_attribute)

