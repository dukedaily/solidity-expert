# from __future__ import annotations
#
# import unittest
# from typing import Optional
#
# from securify.grammar import abstract_production, production
# from securify.grammar.attributes.annotations3 import synthesized, pushdown
#
#
# class AttributeGrammarValidation(unittest.TestCase):
#     # TODO enable somewhen
#     # def test_acyclicity_validation(self):
#     #     with self.assertRaisesRegex(AttributeGrammarValidationError, "cyclic"):
#     #         AttributeGrammar([self.CircularGrammar.Node,
#     #                           self.CircularGrammar.NodeA,
#     #                           self.CircularGrammar.NodeB])
#     #
#     # def test_completeness_validation_1(self):
#     #     with self.assertRaisesRegex(AttributeGrammarValidationError, "Attribute 'b' not available"):
#     #         AttributeGrammar([self.IncompleteGrammar1.Node,
#     #                           self.IncompleteGrammar1.NodeA,
#     #                           self.IncompleteGrammar1.NodeB])
#     #
#     # def test_completeness_validation_2(self):
#     #     with self.assertRaisesRegex(AttributeGrammarValidationError, "corresponding semantic rule could not be found"):
#     #         AttributeGrammar([self.IncompleteGrammar2.Node,
#     #                           self.IncompleteGrammar2.NodeA,
#     #                           self.IncompleteGrammar2.NodeB]).grammar_info()
#
#     class CircularGrammar:
#         @abstract_production
#         class Node:
#             pass
#
#         @production
#         class NodeA(Node):
#             child: Optional[AttributeGrammarValidation.CircularGrammar.Node]
#
#             @synthesized
#             def b(self: {a}):
#                 return self.a
#
#             @pushdown
#             def a_child(self: {}) -> {child: {a}}:
#                 return []
#
#         @production
#         class NodeB(Node):
#             child: Optional[AttributeGrammarValidation.CircularGrammar.Node]
#
#             @synthesized
#             def b(self: {}):
#                 return 1
#
#             @pushdown
#             def a_child(self: {}, child: {b}) -> {child: {a}}:
#                 return child.b
#
#     class IncompleteGrammar1:
#         @abstract_production
#         class Node:
#             pass
#
#         @production
#         class NodeA(Node):
#             child: Optional[AttributeGrammarValidation.IncompleteGrammar1.Node]
#
#         @production
#         class NodeB(Node):
#             child: Optional[AttributeGrammarValidation.IncompleteGrammar1.Node]
#
#             @pushdown
#             def a_child(self: {}, child: {b}) -> {child: {a}}:
#                 return child.b
#
#     class IncompleteGrammar2:
#         @abstract_production
#         class Node:
#             pass
#
#         @production
#         class NodeA(Node):
#             child: Optional[AttributeGrammarValidation.IncompleteGrammar2.Node]
#
#         @production
#         class NodeB(Node):
#             child: Optional[AttributeGrammarValidation.IncompleteGrammar2.Node]
#
#             @pushdown
#             def a_child(self: {}) -> {child: {a}}:
#                 return 1
