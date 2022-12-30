# import unittest
#
# from securify.grammar.attributes import AttributeGrammar
# from securify.grammar.attributes.annotations3 import Parser
# from securify.grammar.attributes.evaluators import DemandDriven
# from tests.grammar.grammars.typed_semantic_rules import Parent, ChildBase, Child1, Child2
# from tests.grammar.grammars import typed_semantic_rules
#
#
# class TypedSemanticRulesTest(unittest.TestCase):
#     grammar = AttributeGrammar.from_modules(
#         typed_semantic_rules,
#         rule_extractor=Parser())
#
#     grammar.validate_grammar()
#
#     def test(self):
#         evaluator = DemandDriven(self.grammar)
#         eval = evaluator.for_tree
#
#         self.assertEqual(eval(Parent(ChildBase())).child_attribute, "DefaultRule")
#         self.assertEqual(eval(Parent(Child1())).child_attribute, "Child1 says hello")
#         self.assertEqual(eval(Parent(Child2("bye"))).child_attribute, "Child2 says bye")
#
#         self.assertEqual(eval(Parent(ChildBase(), None)).optional_attribute, "Explicit None Behaviour")
#         self.assertEqual(eval(Parent(ChildBase(), Child2("Child2"))).optional_attribute, "Default Behaviour")
