# language=Solidity
"""
pragma solidity ^0.5.0;

contract A {
    function test1() public payable {
        uint a = 4; // a
        uint b = 5; // a, b

        { // a, b
            uint q = 4; // a, b, q
            b+=1; // a, b, q
        }

        b+=1; // a, b

        if (true)
        { // a, b
            uint e; // a, b, e
        }
        else
        {
            uint f; // a, b, f
            f+=1; // a, b, f
            uint g; // a, b, f, g
        }

        for ( // a, b
            uint i = 10; // a, b, i
            i < 100;
            ++i)
        {
        }
    }

    function test2(uint arg) public payable {
        if (true) // arg
        { // arg
            uint e; // arg, e
        }
    }

    function test3(uint arg) public returns(uint ret) {
        ret = arg; // ret, arg
    }
}
"""
import unittest

from securify.solidity import get_solidity_grammar_instance
from securify.solidity.v_0_5_x import solidity_grammar as ast
from securify.solidity.v_0_5_x.solidity_grammar import Statement, VariableDeclaration


def validate_attributed_ast(test: unittest.TestCase, source_unit: ast.SourceUnit):
    grammar = get_solidity_grammar_instance()

    stmts = []
    ids_to_vars = {}

    def regsiter_variables(a, _, __):
        if isinstance(a, Statement):
            stmts.append(a)

        if isinstance(a, VariableDeclaration):
            test.assertNotIn(a.id, ids_to_vars)
            ids_to_vars[a.id] = a.name

    grammar.traverse(source_unit, regsiter_variables)

    # Assert unambiguous line<=>stmt correspondence
    test.assertEqual(len(stmts), len({s.src_line for s in stmts}))

    stmts_by_line = {s.src_line: s for s in stmts}

    for i, line in enumerate(source_unit.source.split("\n")):
        if "//" not in line:
            continue

        _, line, *_ = line.split("//")

        expected_scope_vars = line.split(",")
        expected_scope_vars = {v.strip() for v in expected_scope_vars}

        stmt = stmts_by_line[i + 1]
        actual_scope_vars = stmt
        actual_scope_vars = {ids_to_vars[q] for q in actual_scope_vars.scope_post}

        # print(stmt, actual_scope_vars, expected_scope_vars)

        test.assertSetEqual(expected_scope_vars, actual_scope_vars, f"Line: {i}")
