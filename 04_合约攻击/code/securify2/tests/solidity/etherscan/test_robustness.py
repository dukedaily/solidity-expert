import inspect
import sys
import unittest

from securify.__main__ import fix_pragma
from securify.analyses.analysis import AnalysisConfiguration, AnalysisContext
from securify.solidity import solidity_ast_compiler, solidity_cfg_compiler
from securify.utils.ethereum_blockchain import get_contract_from_blockchain


def contract_generator():
    with open("etherscan_contracts", "r") as f:
        for l in f.readlines():
            contract_address = l.split()[0]
            yield contract_address

def make_testcase(contract_address):

    def test_robustness(self):

        contract = get_contract_from_blockchain(contract_address, "../../../api_key.txt")
        contract = fix_pragma(contract)

        config = AnalysisConfiguration(
            # TODO: this returns only the dict ast, but should return the object representation
            ast_compiler=lambda t: solidity_ast_compiler.compile_ast(t.source_file),
            cfg_compiler=lambda t: solidity_cfg_compiler.compile_cfg(t.ast).cfg,
        )

        context = AnalysisContext(
            config=config,
            source_file=contract
        )

        cfg = context.cfg
        assert(cfg)

    return test_robustness



class TestRobustness(unittest.TestCase):

    frame = inspect.currentframe()
    sys.setrecursionlimit(1500)
    for contract_address in contract_generator():
        frame.f_locals[f'test_{contract_address}'] = make_testcase(contract_address)
