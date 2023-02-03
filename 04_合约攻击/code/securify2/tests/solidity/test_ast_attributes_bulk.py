import importlib
import inspect
import os
import pkgutil
import unittest
from types import ModuleType

from securify.solidity.solidity_cfg_compiler import compile_attributed_ast


def make_test_case(test_module: ModuleType):
    def test_case(self):
        sol_code = test_module.__doc__
        sol_file = test_module.__name__ + "_tmp.sol"

        with open(sol_file, "w") as file:
            print(sol_code, file=file)

        compile_output = compile_attributed_ast(sol_file)

        os.remove(sol_file)

        # Test files must define the function validate_attributed_ast
        test_function = getattr(test_module, "validate_attributed_ast")
        test_function(self, compile_output)

    return test_case


class TestCfgCompilation(unittest.TestCase):
    test_directory = os.path.dirname(os.path.abspath(__file__)) + "/test_cases"

    frame = inspect.currentframe()
    for test_case in pkgutil.iter_modules([test_directory]):
        if __package__ is None or __package__ == "":
            module = importlib.import_module(f"test_cases.{test_case.name}")
        else:
            module = importlib.import_module(f"{__package__}.test_cases.{test_case.name}")

        frame.f_locals[f'test_{test_case.name}'] = make_test_case(module)
