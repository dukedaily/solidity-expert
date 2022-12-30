from __future__ import annotations

import unittest

from securify.grammar.attributes import AttributeGrammar
from securify.grammar.attributes.annotations3 import Parser
from securify.grammar.attributes.evaluators import StaticEvaluator, DemandDrivenRecursive
from tests.grammar.grammars import scopes, scopes_parser, arithmetic
from tests.grammar.test_evaluator_test_cases import EvaluatorTestCases


class EvaluatorConsistencyTest(unittest.TestCase, EvaluatorTestCases):
    grammar_scopes = AttributeGrammar.from_modules(scopes, rule_extractor=Parser())
    grammar_arithmetic = AttributeGrammar.from_modules(arithmetic, rule_extractor=Parser())

    evaluator_scopes_1 = StaticEvaluator(grammar_scopes)
    evaluator_arithmetic_1 = StaticEvaluator(grammar_arithmetic)

    evaluator_scopes_2 = DemandDrivenRecursive(grammar_scopes)
    evaluator_arithmetic_2 = DemandDrivenRecursive(grammar_arithmetic)

    def test_arithmetic(self):
        for e, r, t, d in self.expressions:
            ast = arithmetic.parse_rpn(e)
            ast.depth = 0
            ast.index = None

            self.mark_nodes(self.grammar_arithmetic, ast)
            self.same_evaluations(ast,
                                  self.evaluator_arithmetic_1,
                                  self.evaluator_arithmetic_2)

    def test_scopes(self):
        for e in self.ok:
            ast = scopes_parser.parse(e)
            ast.same = []
            ast.env = {}

            self.mark_nodes(self.grammar_scopes, ast)
            self.same_evaluations(ast,
                                  self.evaluator_scopes_1,
                                  self.evaluator_scopes_2)

        for e in self.not_ok:
            ast = scopes_parser.parse(e)
            ast.same = []
            ast.env = {}

            self.mark_nodes(self.grammar_scopes, ast)
            self.same_evaluations(ast,
                                  self.evaluator_scopes_1,
                                  self.evaluator_scopes_2)

    def same_evaluations(self, tree, evaluator1, evaluator2):
        evaluated1 = evaluator1.for_tree(tree)
        evaluated2 = evaluator2.for_tree(tree)
        d1 = self.attribute_dict(evaluator1.grammar, evaluated1)
        d2 = self.attribute_dict(evaluator2.grammar, evaluated2)

        self.assertEqual(d1, d2)

    @staticmethod
    def mark_nodes(grammar, tree):
        # Required bc. node ids change after being passed through evaluators
        grammar.traverse(tree, lambda n, c, a: setattr(n, "node_id", id(n)))

    @staticmethod
    def attribute_dict(grammar, tree):
        result = {}

        def fill_dict(node, attribute):
            result[(node.node_id, attribute)] = getattr(node, attribute)

        grammar.attribute_visitor().visit(tree, fill_dict)

        return result
