import unittest
from securify.__main__ import get_list_of_patterns, fix_pragma
from securify.analyses.analysis import discover_patterns, AnalysisContext, AnalysisConfiguration, print_pattern_matches


class TestCLI(unittest.TestCase):
    def test_get_list_of_patterns_default(self):
        patterns_discovered = discover_patterns()
        patterns_filtered = get_list_of_patterns()
        self.assertEqual(len(patterns_discovered), len(patterns_filtered))

    def test_get_list_of_patterns_severity_include(self):
        patterns_filtered = get_list_of_patterns(severity_inc=['CRITICAL'])
        for p in patterns_filtered:
            self.assertEqual(p.severity.name, 'CRITICAL')

    def test_get_list_of_patterns_severity_exclude(self):
        patterns_filtered = get_list_of_patterns(severity_exc=['CRITICAL'])
        for p in patterns_filtered:
            self.assertNotEqual(p.severity.name, 'CRITICAL')

class TestFixPragma(unittest.TestCase):

    def test_fix_pragma(self):
        new_contract = fix_pragma('FixPragma.sol')
        with open(new_contract) as f:
            source = f.read()
            assert('pragma solidity 0.5.8' in source)

    def test_not_fix_pragma(self):

        old_contract = 'NoFixPragma.sol'
        new_contract = fix_pragma(old_contract)
        with open(new_contract) as f:
            new_source = f.read()

        with open(old_contract) as f:
            old_source = f.read()

        assert (old_source == new_source)

    def test_no_pragma(self):
        old_contract = 'NoPragma.sol'
        new_contract = fix_pragma(old_contract)
        with open(new_contract) as f:
            new_source = f.read()

        with open(old_contract) as f:
            old_source = f.read()

        assert (old_source == new_source)



if __name__ == '__main__':
    unittest.main()
