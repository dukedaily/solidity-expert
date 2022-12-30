import unittest
from pprint import pprint

from securify.grammar import Grammar
from securify.grammar.transformer import DictTransformer

from tests.grammar.grammars import simple


class DictTransformerTest(unittest.TestCase):
    grammar = Grammar.from_modules(simple)
    transformer = DictTransformer(
        grammar=grammar,
        class_identifier="type")

    pprint(grammar.grammar_info())

    def test(self):
        tree = {
            "type": "B",
            "seq": [{
                "type": "C",
                "single": {
                    "type": "B",
                    "seq": []
                }
            }, {
                "type": "A",
                "optional": {"type": "E"}
            }, {
                "type": "A",
                "optional": {"type": "A"}
            }, {"type": "A"}]
        }

        ast = self.transformer.transform(tree)

        self.assertEqual(ast.seq[0].single.seq, [])
        self.assertEqual(ast.seq[0].__class__, simple.C)
        self.assertEqual(ast.seq[1].__class__, simple.A)
        self.assertEqual(ast.seq[1].optional.__class__, simple.E)
