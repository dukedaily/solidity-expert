import unittest

from securify.grammar import Grammar, GrammarError
from tests.grammar.grammars import arithmetic
from tests.grammar.grammars.arithmetic import *


class UnrelatedClass:
    pass


class GrammarValidationTest(unittest.TestCase):
    grammar = Grammar.from_modules(arithmetic)

    def test_invalid_trees(self):
        with self.assertRaisesRegex(GrammarError, "Expected child.*Optional"):
            self.grammar.validate_tree(Addition(Addition(Constant(1)), Constant(1)))

        with self.assertRaisesRegex(GrammarError, "Expected child of type.*"):
            self.grammar.validate_tree(Addition(UnrelatedClass(), Constant(1)))

        with self.assertRaisesRegex(GrammarError, "Unexpected sequence-like.*"):
            self.grammar.validate_tree(Addition([Constant(1), Constant(2)], Constant(1)))

        with self.assertRaisesRegex(GrammarError, "Expected sequence.*"):
            s = Sum()
            s.addends = Constant(1)
            self.grammar.validate_tree(s)

    def test_valid_trees(self):
        valid_trees = [arithmetic.parse_rpn(t) for t in [
            "1 2 + 2.5 * 2 5 SUM",
            "1 2 3 SUM 4 5 SUM 6 7 SUM",
            "1 2 3 SUM 4 5 SUM 6 7 SUM 8.5 *"
        ]]

        for valid_tree in valid_trees:
            self.assertTrue(self.grammar.validate_tree(valid_tree))
