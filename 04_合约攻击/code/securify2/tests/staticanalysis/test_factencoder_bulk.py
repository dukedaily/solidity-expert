import glob
import inspect
import os
import unittest
from pathlib import Path

from securify.staticanalysis import factencoder
from tests.solidity.test_utils import compile_cached


def make_test_case(path_src):
    def test_case(self):
        c = compile_cached(path_src)
        factencoder.encode(c.cfg)

    return test_case


class TestCfgCompilation(unittest.TestCase):
    test_paths = [
        "/../solidity/test_feature_contracts",
        "/../solidity/test_real_contracts",
        "/../solidity/public_contracts",
    ]

    frame = inspect.currentframe()

    for test_path in test_paths:
        base_path = os.path.dirname(os.path.abspath(__file__)) + test_path

        for filename in glob.iglob(f'{base_path}/*.sol', recursive=True):
            path = Path(filename)
            frame.f_locals[f'test_{path.stem}'] = make_test_case(str(path))
