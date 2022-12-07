from __future__ import annotations

import unittest

from securify.grammar.attributes import AttributeGrammar
from securify.grammar.attributes.annotations3 import Parser
from securify.grammar.attributes.evaluators import StaticEvaluator
from tests.grammar.grammars import defaults
from tests.grammar.grammars.defaults import Parent, ChildA, ChildB
from tests.grammar.test_evaluator_test_cases import EvaluatorTestCases


class DefaultAttributesTest(unittest.TestCase, EvaluatorTestCases):
    grammar = AttributeGrammar.from_modules(defaults, rule_extractor=Parser())

    def test(self):
        ast = Parent(ChildA(ChildB()), ChildA(None))
        ast = StaticEvaluator(self.grammar).for_tree(ast)

        self.assertEqual(ast.default, "Default Synth")

        self.assertEqual(ast.child1.attr, "Success")
        self.assertEqual(ast.child1.child.attr, "Success")

        # ast.child1.listA.append(1)
        # ast.child1.listB.append(1)
        # self.assertEqual(ast.child1.listA, ast.child1.listB)
        # self.assertEqual(ast.child2.listA, ast.child2.listB)

