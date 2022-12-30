import glob
import inspect
import os
import unittest
from pathlib import Path

from securify.solidity.solidity_cfg_compiler import compile_evaluable_ast
from securify.solidity.v_0_5_x.solidity_grammar import ModifierInvocation, ModifierDefinition, \
    ContractDefinition


def make_test_case(path_src):
    def test_case(self):
        ast, ast_dict, _, grammar = compile_evaluable_ast(path_src)

        visitor = grammar.visitor()

        modifiers = visitor.find_descendants_of_type(ast, ModifierInvocation)
        modifiers = [m for m in modifiers if m.arguments]

        if not modifiers:
            return

        nm = len(modifiers)
        nc = 0

        m: ModifierInvocation
        for m in modifiers:
            t = ast._ast_nodes_by_id[m.modifier_name.referenced_declaration]
            if isinstance(t, ContractDefinition):
                nc += 1
            elif isinstance(t, ModifierDefinition):
                pass
            else:
                raise Exception(type(t))

        print((nm, nc))

    return test_case


class TestCfgCompilation(unittest.TestCase):
    base_path = os.path.dirname(os.path.abspath(__file__)) + "/test_real_contracts"

    frame = inspect.currentframe()
    for filename in glob.iglob(f'{base_path}/*.sol', recursive=True):
        path = Path(filename)
        frame.f_locals[f'test_{path.stem}'] = make_test_case(str(path))
