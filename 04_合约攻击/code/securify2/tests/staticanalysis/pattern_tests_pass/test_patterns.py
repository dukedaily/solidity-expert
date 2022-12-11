import glob
import inspect
import logging
import os
import unittest
from pathlib import Path

from securify.solidity import compile_cfg
from securify.staticanalysis import static_analysis


def make_test_case(path_src):
    def test_case(self: unittest.TestCase):
        cfg, ast, *_ = compile_cfg(path_src)
        result = static_analysis.analyze_cfg(cfg, logger=logging).facts_out

        compliant_output = result["patternCompliance"]
        violation_output = result["patternViolation"]
        conflict_output = result["patternConflict"]

        def exists(actual, e):
            actual = {a[2] for a in actual if a[0].strip() == "PASS"}

            self.assertTrue(len(actual) > 0, e)

        def not_exists(actual, e):
            actual = {a[2] for a in actual if a[0].strip() == "PASS"}
            self.assertTrue(len(actual) == 0, e)

        if "unsafe" in path_src:
            exists(violation_output, "Violations")
            not_exists(conflict_output, "Conflict")
        else:
            exists(compliant_output, "Compliance")
            not_exists(violation_output, "Compliance")
            not_exists(conflict_output, "Conflict")

    return test_case


class TestPatternsPass(unittest.TestCase):
    base_path = os.path.dirname(os.path.abspath(__file__)) + "**/"

    frame = inspect.currentframe()
    for filename in glob.iglob(f'{base_path}**/*.sol', recursive=True):
        path = Path(filename)
        test_name = str(path.relative_to(Path(os.path.abspath(__file__)).parent)) \
            .replace(".sol", "") \
            .replace("\\", ".") \
            .replace("/", ".")

        frame.f_locals[f'test_{test_name}'] = make_test_case(str(path))
