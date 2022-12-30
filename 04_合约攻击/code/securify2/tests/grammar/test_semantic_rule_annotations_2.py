from __future__ import annotations

import unittest
from typing import Optional

from securify.grammar import production
from securify.grammar.attributes import AttributeGrammar
from securify.grammar.attributes.annotations3 import synthesized, inherited, pushdown, Parser


@production
class Rule:
    child: Optional[Rule]
    node: Optional[Child]

    attr1 = synthesized()
    attr2 = synthesized()
    attr3 = synthesized()
    attr4 = synthesized()

    @synthesized
    def attr1(self):
        return object()

    @synthesized
    def attr2(self):
        return self.attr1.__class__

    @synthesized
    def attr3(self):
        return [self.attr2(type)]

    @synthesized
    def attr4(self, child, node):
        print(self.child)
        print(self.node)

        print(child.child)
        print(child.node)

        return str(self.attr3[0]) + node.some_attribute


@production
class Child:
    some_attribute = synthesized()

    @synthesized
    def some_attribute(self):
        pass


class AttributeDecoratorsTest(unittest.TestCase):
    grammar = AttributeGrammar([Rule, Child], rule_extractor=Parser())

    # pprint(grammar.grammar_info())

    def test(self):
        rules_s = self.grammar.synthesized_rules[Rule]

        self.assertEqual(rules_s[("self", "attr1")][0].arguments[0].node, "self")
        self.assertEqual(rules_s[("self", "attr2")][0].arguments[0].node, "self")
        self.assertEqual(rules_s[("self", "attr3")][0].arguments[0].node, "self")
        self.assertEqual(rules_s[("self", "attr4")][0].arguments[0].node, "self")

        self.assertIn(("self", "attr1"), rules_s[("self", "attr2")][0].dependencies)
        self.assertIn(("self", "attr2"), rules_s[("self", "attr3")][0].dependencies)
        self.assertIn(("self", "attr3"), rules_s[("self", "attr4")][0].dependencies)

        self.assertEqual(len(rules_s[("self", "attr4")][0].arguments), 3)
        self.assertEqual(len(rules_s[("self", "attr4")][0].dependencies), 2)
        self.assertIn(("self", "attr3"), rules_s[("self", "attr4")][0].dependencies)
        self.assertIn(("node", "some_attribute"), rules_s[("self", "attr4")][0].dependencies)
