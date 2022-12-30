import configparser
import glob
import inspect
import logging
import os
import unittest
from itertools import takewhile, dropwhile
from pathlib import Path
from typing import List

from securify.analyses.analysis import AnalysisConfiguration, AnalysisContext, discover_patterns
from securify.analyses.patterns.abstract_pattern import PatternMatch, MatchType, MatchSourceLocation
from securify.solidity import solidity_cfg_compiler, solidity_ast_compiler
from securify.staticanalysis import static_analysis


def make_test_case(path_src, logger):
    def read_test_info():
        with open(path_src, 'r') as f:
            src_lines = f.readlines()

        lines = dropwhile(lambda l: "/**" not in l, src_lines)
        lines = takewhile(lambda l: "*/" not in l, lines)
        lines = (l.strip() for l in lines)
        lines = list(lines)[1:]

        config = configparser.ConfigParser()
        config.read_string("\n".join(lines))

        comments = [(i, l) for i, l in enumerate(src_lines) if "//" in l]

        def find_annotations(keyword):
            return [(i + 1, c) for i, c in comments if keyword in c]

        annotation_labels = {
            "compliant",
            "violation",
            "warning",
        }

        annotations = {e: find_annotations(e) for e in annotation_labels}

        return config["TestInfo"], annotations

    def test_case(self: unittest.TestCase):
        config = AnalysisConfiguration(
            # TODO: this returns only the dict ast, but should return the object representation
            ast_compiler=lambda t: solidity_ast_compiler.compile_ast(t.source_file),
            cfg_compiler=lambda t: solidity_cfg_compiler.compile_cfg(t.ast).cfg,
            static_analysis=lambda t: static_analysis.analyze_cfg(t.cfg),
        )

        context = AnalysisContext(
            config=config,
            source_file=path_src
        )

        test_info, annotations = read_test_info()

        patterns = TestPatterns.patterns
        patterns = [p for p in patterns if p.__name__ == test_info["pattern"]]

        assert len(patterns) == 1, len(patterns)

        matches: List[PatternMatch] = []

        for pattern in patterns:
            matches += pattern(context).find_matches()

        self.assertFalse([m for m in matches if not isinstance(m, PatternMatch)], "Result must be a PatternMatch")
        self.assertFalse([m for m in matches if m.type == MatchType.CONFLICT], "Conflicts must not happen")

        compliant = [next(m.find_info(MatchSourceLocation)).line for m in matches if m.type == MatchType.COMPLIANT]
        violation = [next(m.find_info(MatchSourceLocation)).line for m in matches if m.type == MatchType.VIOLATION]
        warning = [next(m.find_info(MatchSourceLocation)).line for m in matches if m.type == MatchType.WARNING]

        def compare(expected, actual, e):
            try:
                self.assertSetEqual(set(expected), set(actual), e)
            except AssertionError as e:  # Fix ambiguous error messages
                msg = e.args[0]
                msg = msg.replace("Items in the first set but not the second",
                                  "Items expected but not reported")

                msg = msg.replace("Items in the second set but not the first",
                                  "Items incorrectly reported")

                raise AssertionError(msg) from None


        compare([t[0] for t in annotations["compliant"]], compliant, "Compliant")
        compare([t[0] for t in annotations["violation"]], violation, "Violation")
        compare([t[0] for t in annotations["warning"]], warning, "Warnings")

    return test_case


class TestPatterns(unittest.TestCase):
    base_path = os.path.dirname(os.path.abspath(__file__)) + "/"
    frame = inspect.currentframe()

    patterns = discover_patterns()

    for filename in glob.iglob(f'{base_path}**/*.sol', recursive=True):
        path = Path(filename)
        test_name = str(path.relative_to(Path(os.path.abspath(__file__)).parent)) \
            .replace(".sol", "") \
            .replace("\\", ".") \
            .replace("/", ".")

        frame.f_locals[f'test_{test_name}'] = make_test_case(str(path), logging)
