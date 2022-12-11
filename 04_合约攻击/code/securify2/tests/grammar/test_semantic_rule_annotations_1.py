from __future__ import annotations

import unittest
from typing import Optional

from securify.grammar import production
from securify.grammar.attributes import AttributeGrammar
from securify.grammar.attributes.annotations3 import synthesized, inherited, pushdown, Parser


@production
class SymbolRule:
    child: Optional[SymbolRule]
    node: Optional[SymbolRule]

    attr1 = synthesized()
    attr2 = synthesized()
    test_synthesized = synthesized()

    attr3 = inherited()

    @synthesized
    def attr1(self):
        pass

    @synthesized
    def attr2(self):
        pass

    @synthesized
    def test_synthesized(self, node):
        return node.attr1, node.attr2

    @pushdown
    def test_inheritable(self, node) -> SymbolRule.attr3 @ child:
        return node.attr1, node.attr2

    @pushdown
    def test_inheritable2(self) -> SymbolRule.attr3 @ node:
        pass


class AttributeDecoratorsTest(unittest.TestCase):
    grammar = AttributeGrammar([SymbolRule], rule_extractor=Parser())

    # pprint(grammar.grammar_info())

    def test(self):
        rules_i = self.grammar.inheritable_rules[SymbolRule]
        rules_s = self.grammar.synthesized_rules[SymbolRule]
        self.assertEqual(rules_i[("child", "attr3")][0].arguments[0].node, "self")
        self.assertEqual(rules_i[("child", "attr3")][0].arguments[1].node, "node")

        self.assertIn(("node", "attr1"), rules_i[("child", "attr3")][0].dependencies)
        self.assertIn(("node", "attr2"), rules_i[("child", "attr3")][0].dependencies)

        self.assertEqual(rules_i[("child", "attr3")][0].target, ("child", "attr3"))

        self.assertEqual(rules_s[("self", "test_synthesized")][0].arguments[0].node, "self")
        self.assertEqual(rules_s[("self", "test_synthesized")][0].arguments[1].node, "node")

        self.assertIn(("node", "attr1"), rules_s[("self", "test_synthesized")][0].dependencies)
        self.assertIn(("node", "attr2"), rules_s[("self", "test_synthesized")][0].dependencies)
