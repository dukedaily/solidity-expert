import configparser
import glob
import inspect
import logging
import os
import pprint
import sys
import unittest
from itertools import takewhile, dropwhile
from pathlib import Path

from securify.solidity import compile_cfg
from securify.staticanalysis import static_analysis
from securify.__main__ import fix_pragma

USE_COMPILATION_CACHE = False


def make_test_case(path_src, logger):
    def test_case(self: unittest.TestCase):
        # if USE_COMPILATION_CACHE:
        #     cfg, ast, *_ = compile_cached(path_src)
        # else:
        #path_src = fix_pragma(path_src)
        new_src = fix_pragma(path_src)

        cfg, ast, *_ = compile_cfg(new_src)

        result = static_analysis.analyze_cfg(cfg, logger=logger).facts_out

        with open(path_src, 'r') as f:
            src_lines = f.readlines()

        lines = dropwhile(lambda l: "/**" not in l, src_lines)
        lines = takewhile(lambda l: "*/" not in l, lines)
        lines = list(lines)[1:]

        config = configparser.ConfigParser()
        config.read_string("".join(lines))

        specs = config["Specs"]
        pattern = specs["pattern"]

        compliant = [c.strip() for c in specs.get("compliant", "").split(",")]
        violation = [c.strip() for c in specs.get("violation", "").split(",")]

        compliant += [f"L{i + 1}" for i, l in enumerate(src_lines) if
                      "//" in l and "compliant" in l.split("//")[1].lower()]

        violation += [f"L{i + 1}" for i, l in enumerate(src_lines) if
                      "//" in l and "violation" in l.split("//")[1].lower()]

        compliant = [s.strip() for s in compliant if "" != s.strip()]
        violation = [s.strip() for s in violation if "" != s.strip()]

        pattern_matches = [t[1:] for t in result["patternMatch"] if t[0] == pattern]
        pattern_matches_lines = [t[1:] for t in result["patternMatchInfo"] if t[0] == pattern]
        pattern_matches_lines = {match: line for match, key, line in pattern_matches_lines if key == "line"}

        compliant_output = [pattern_matches_lines[m] for m, c in pattern_matches if c == "compliant"]
        violation_output = [pattern_matches_lines[m] for m, c in pattern_matches if c == "violation"]
        conflict_output = [pattern_matches_lines[m] for m, c in pattern_matches if c == "conflict"]

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

        if conflict_output:
            data = pprint.pformat(conflict_output)
            raise Exception("Conflict\n" + data)

        compare(compliant, compliant_output, "Compliance")
        compare(violation, violation_output, "Violations")

    return test_case


class TestPatterns(unittest.TestCase):
    base_path = os.path.dirname(os.path.abspath(__file__)) + "/"
    frame = inspect.currentframe()

    for filename in glob.iglob(f'{base_path}**/*.sol', recursive=True):
        path = Path(filename)
        test_name = str(path.relative_to(Path(os.path.abspath(__file__)).parent)) \
            .replace(".sol", "") \
            .replace("\\", ".") \
            .replace("/", ".")

        frame.f_locals[f'test_{test_name}'] = make_test_case(str(path), logging)
