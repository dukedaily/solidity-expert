# from __future__ import annotations
#
# from dataclasses import dataclass, field
# from pprint import pprint
# from typing import Optional
#
# from securify.grammar import production, abstract_production
# from securify.grammar.attributes import AttributeGrammar
# from securify.grammar.attributes.annotations3 import Parser, synthesized
# from securify.grammar.attributes.evaluators import DemandDriven
#
#
# @production
# @dataclass(unsafe_hash=True)
# class Parent:
#     child: ChildBase
#     optional: Optional[Child2] = field(default=None)
#
#     child_attribute = synthesized()
#     optional_attribute = synthesized()
#
#     @synthesized
#     def child_attribute(self):
#         return "DefaultRule"
#
#     @synthesized
#     def child_attribute(self, child: Child1):
#         return child.attribute_child_1
#
#     @synthesized
#     def child_attribute(self, child: Child2):
#         return child.attribute_child_2
#
#     @synthesized
#     def optional_attribute(self):
#         return "Default Behaviour"
#
#     @synthesized
#     def optional_attribute(self, optional: None):
#         return "Explicit None Behaviour"
#
#
# @production
# class ChildBase:
#     pass
#
#
# @production
# class Child1(ChildBase):
#     attribute_child_1 = synthesized()
#
#     @synthesized
#     def attribute_child_1(self):
#         return "Child1 says hello"
#
#
# @dataclass(unsafe_hash=True)
# class Child2(ChildBase):
#     child_value: str
#
#     attribute_child_2 = synthesized()
#
#     @synthesized
#     def attribute_child_2(self):
#         this = self
#         return f"Child2 says {this.child_value}"
#
#
# def main():
#     grammar = AttributeGrammar([
#         Parent,
#         ChildBase,
#         Child1,
#         Child2
#     ], rule_extractor=Parser())
#
#     grammar.validate_grammar()
#     pprint(grammar.grammar_info())
#
#     evaluator = DemandDriven(grammar)
#
#     print(evaluator.for_tree(Parent(ChildBase())).child_attribute)
#     print(evaluator.for_tree(Parent(Child1())).child_attribute)
#     print(evaluator.for_tree(Parent(Child2("Child2"))).child_attribute)
#
#     print(evaluator.for_tree(Parent(ChildBase(), None)).optional_attribute)
#     print(evaluator.for_tree(Parent(ChildBase(), Child2("Child2"))).optional_attribute)
#
#
# if __name__ == '__main__':
#     main()
