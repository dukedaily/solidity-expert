import unittest
from pathlib import Path

from securify.staticanalysis.souffle import run_souffle


class SouffleOutputParserTest(unittest.TestCase):
    path = Path(__file__).parent

    def test(self):
        _, facts = run_souffle(str(self.path / "test_souffle_wrapper.dl"))

        print(facts)

        self.assertTrue(facts["output_0_a"])
        self.assertFalse(facts["output_0_b"])

        self.assertIn(("test",), facts["output_1"])
        self.assertIn(("a", ""), facts["output_2_a"])
        self.assertEqual([], facts["output_2_b"])
