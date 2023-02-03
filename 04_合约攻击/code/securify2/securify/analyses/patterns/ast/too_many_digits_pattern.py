from typing import List

from securify.analyses.patterns.abstract_pattern import Severity, PatternMatch, MatchComment
from securify.analyses.patterns.ast.abstract_ast_pattern import AbstractAstPattern


class TooManyDigitsPattern(AbstractAstPattern):
    name = "Too Many Digit Literals"

    description = "Usage of assembly in Solidity code is discouraged."

    severity = Severity.INFO
    tags = {}

    def find_matches(self) -> List[PatternMatch]:
        ast = self.get_ast_module()
        ast_root = self.get_ast_root()

        matches = []

        for literal in ast_root.find_descendants_of_type(ast.Literal):
            if not any((literal.type_string.startswith("int"),
                        literal.type_string.startswith("uint"),
                        literal.type_string.startswith("fixed"),
                        literal.type_string.startswith("ufixed"))):
                continue

            if literal.value.startswith("0x"):
                continue

            contract = literal.find_ancestor_of_type(ast.ContractDefinition)

            if "00000" in literal.value:
                match = self.match_violation().with_info(
                    MatchComment(
                        f"Contract '{contract.name}' contains a numeric "
                        f"literal with too many digits."
                    ),
                    *self.ast_node_info(literal)
                )

                matches.append(match)

        return matches
