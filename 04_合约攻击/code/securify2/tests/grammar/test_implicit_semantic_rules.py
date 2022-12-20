import unittest

from securify.grammar.attributes.evaluators import StaticEvaluator
from tests.grammar.grammars import implicit_attribute_passdown
from tests.grammar.grammars.implicit_attribute_passdown import *


class GrammarValidationTest(unittest.TestCase):
    def test_implicit_rule_inference(self):
        grammar = AttributeGrammar.from_modules(
            implicit_attribute_passdown, rule_extractor=Parser())

        # from pprint import pprint
        # pprint(grammar.grammar_info())

        tree = NodeA(NodeB(NodeC(NodeD())))
        tree.a = "some stuff"

        tree = StaticEvaluator(grammar).for_tree(tree)

        self.assertEqual(tree.node.node.node.test, ("changed", "some stuff"))
