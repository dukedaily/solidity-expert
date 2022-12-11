import glob
import inspect
import os
import unittest
from pathlib import Path

from tests.solidity.test_utils import compile_cached


def make_test_case(path_src):
    def test_case(self):
        compile_cached(path_src)

    return test_case


class TestCfgCompilation(unittest.TestCase):
    test_paths = [
        "/test_feature_contracts",
        "/test_real_contracts",
        "/public_contracts",
    ]

    frame = inspect.currentframe()

    for test_path in test_paths:
        base_path = os.path.dirname(os.path.abspath(__file__)) + test_path

        for filename in glob.iglob(f'{base_path}/*.sol', recursive=True):
            path = Path(filename)
            frame.f_locals[f'test_{path.stem}'] = make_test_case(str(path))
