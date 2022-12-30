from typing import List

from securify.analyses.patterns.abstract_pattern import Severity, PatternMatch, \
    MatchComment
from securify.analyses.patterns.ast.abstract_ast_pattern import AbstractAstPattern
from securify.solidity.v_0_5_x import solidity_grammar_core as ast


class AssemblyUsagePattern(AbstractAstPattern):
    name = "Assembly Usage"

    description = "Usage of assembly in Solidity code is discouraged."

    severity = Severity.INFO
    tags = {}

    def find_matches(self) -> List[PatternMatch]:
        ast_root = self.get_ast_root()

        matches = []

        for assembly in ast_root.find_descendants_of_type(ast.InlineAssembly):
            function = assembly.find_ancestor_of_type((ast.FunctionDefinition, ast.ModifierDefinition))
            contract = function.find_ancestor_of_type(ast.ContractDefinition)

            match = self.match_violation().with_info(
                MatchComment(
                    f"Function '{function.name}' in contract '{contract.name}'"
                    f"contains inline assembly statements."
                ),
                *self.ast_node_info(assembly)
            )

            matches.append(match)

        return matches
