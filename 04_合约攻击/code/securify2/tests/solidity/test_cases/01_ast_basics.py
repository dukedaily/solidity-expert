# language=Solidity
"""
pragma solidity ^0.5.0;

contract A {
    uint i;
    function foo(uint a) public {
        i += 1;
    }
}
"""
import unittest

from securify.solidity.v_0_5_x import solidity_grammar as ast


def validate_attributed_ast(test: unittest.TestCase, source_unit: ast.SourceUnit):
    test.assertIsInstance(source_unit.nodes[1], ast.ContractDefinition)
    test.assertIsInstance(source_unit.nodes[1].nodes[0], ast.VariableDeclaration)
    test.assertIsInstance(source_unit.nodes[1].nodes[1], ast.FunctionDefinition)
