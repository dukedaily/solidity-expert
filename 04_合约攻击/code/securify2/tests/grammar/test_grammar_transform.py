import unittest

from securify.grammar.attributes.evaluators import DemandDrivenRecursive
from tests.grammar.grammars import arithmetic
from tests.grammar.grammars.arithmetic import *


class GrammarTransformTest(unittest.TestCase):
    grammar = AttributeGrammar.from_modules(arithmetic, rule_extractor=Parser())

    def test_transformer1(self):
        def transformer(node, _):
            if isinstance(node, Sum):
                if len(node.addends) == 0:
                    return Constant(0)
                if len(node.addends) == 1:
                    return node.addends[0]

                head, *tail = node.addends

                return Addition(head, Sum(*tail))

        ast = Sum(
            Constant(1),
            Sum(
                Constant(10),
                Constant(20),
                Constant(30),
                Constant(40),
                Constant(50)),
            Constant(3),
            Constant(4),
            Constant(5)
        )

        ast2 = self.grammar.visitor().transform(ast, transformer)

        original_string = DemandDrivenRecursive(self.grammar).for_tree(ast2).string
        transformed_string = DemandDrivenRecursive(self.grammar).for_tree(ast2).string

        print("Original:", original_string)
        print("Transformed:", transformed_string)

        self.assertEqual(transformed_string,
                         "(1 + ((10 + (20 + (30 + (40 + 50)))) + (3 + (4 + 5))))")
