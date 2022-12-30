from __future__ import annotations

import unittest

from securify.grammar.attributes import AttributeGrammar
from securify.grammar.attributes.annotations3 import Parser
from securify.grammar.attributes.evaluators import DemandDrivenRecursive
from tests.grammar.grammars import scopes, scopes_parser, arithmetic
from tests.grammar.test_evaluator_test_cases import EvaluatorTestCases


class EvaluatorDemandDrivenTest(unittest.TestCase, EvaluatorTestCases):
    grammar_scopes = AttributeGrammar.from_modules(scopes, rule_extractor=Parser())
    grammar_arithmetic = AttributeGrammar.from_modules(arithmetic, rule_extractor=Parser())

    evaluator_scopes = DemandDrivenRecursive(grammar_scopes)
    evaluator_arithmetic = DemandDrivenRecursive(grammar_arithmetic)

    def test_arithmetic(self):
        for e, r, t, d in self.expressions:
            ast = arithmetic.parse_rpn(e)
            ast.depth = 0
            ast.index = None
            ast = self.evaluator_arithmetic.for_tree(ast).content
            self.assertEqual(ast.value, r)
            self.assertEqual(ast.type, t)
            self.assertEqual(ast.subtree_depth, d)

    def test_scopes(self):
        for e in self.ok:
            ast = scopes_parser.parse(e)
            ast.same = []
            ast.env = {}

            self.assertTrue(self.evaluator_scopes.for_tree(ast).ok)

        for e in self.not_ok:
            ast = scopes_parser.parse(e)
            ast.same = []
            ast.env = {}

            self.assertFalse(self.evaluator_scopes.for_tree(ast).ok, e)
