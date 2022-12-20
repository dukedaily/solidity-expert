import re
from typing import List

from securify.analyses.patterns.abstract_pattern import Severity, PatternMatch, MatchComment
from securify.analyses.patterns.ast.abstract_ast_pattern import AbstractAstPattern
from securify.analyses.patterns.ast.declaration_utils import DeclarationUtils


class SolidityNamingConventionPattern(DeclarationUtils, AbstractAstPattern):
    name = "Solidity Naming Convention"
    description = "Reports declarations that do not adhere to Solidity's naming convention."

    severity = Severity.INFO
    tags = {}

    def find_matches(self) -> List[PatternMatch]:
        ast_root = self.get_ast_root()

        for decl_name, decl_type, decl_node in self.find_named_nodes(ast_root):
            # Empty names that pass compilation are ok (e.g. constructors, fallback function, etc.)
            if decl_name == "":
                continue

            if decl_name in self.discouraged_names and "variable" in decl_type:
                yield self.match_violation().with_info(
                    MatchComment(f"Local and state variables should not be "
                                 f"named 'l', 'I' or 'O' as those are often "
                                 f"indistinguishable from the numerals one "
                                 f"and zero"),
                    *self.ast_node_info(decl_node)
                )

            decl_type = self.refine_decl_type(decl_type, decl_node)
            convention = self.naming_conventions.get(decl_type, None)

            if convention is None:
                continue

            convention_pattern, convention_name = convention

            if not convention_pattern.fullmatch(decl_name):
                yield self.match_violation().with_info(
                    MatchComment(f"The {decl_type} '{decl_name}' does not adhere "
                                 f"to Solidity's naming convention. It should be "
                                 f"in {convention_name}."),
                    *self.ast_node_info(decl_node)
                )

    @staticmethod
    def refine_decl_type(decl_type, decl_node):
        if decl_type == 'state variable' and getattr(decl_node, 'constant', False):
            return 'constant'

        if decl_type in {'function', 'state variable'}:
            if getattr(decl_node, 'visibility', None) in {'private', 'internal'}:
                return f"{decl_type} (private)"

        return decl_type

    upper_case = re.compile('[A-Z0-9_]+'), "UPPER_CASE"
    mixed_case = re.compile('[a-z]([A-Za-z0-9]+)?_?'), "mixedCase (i.e. camelCase)"
    mixed_case_private = re.compile('[_]?[a-z]([A-Za-z0-9]+)?_?'), "_mixedCase (i.e. camelCase with underscore prefix)"
    cap_words = re.compile('[A-Z]([A-Za-z0-9]+)?_?'), "CapitalizedWords (i.e. PascalCase)"

    discouraged_names = {"l", "I", "O"}

    naming_conventions = {
        'contract': cap_words,
        'struct': cap_words,
        'enum': cap_words,
        'event': cap_words,

        'constant': upper_case,

        'modifier': mixed_case,
        'function': mixed_case,
        'function (private)': mixed_case_private,

        'local variable': mixed_case,
        'state variable': mixed_case,
        'state variable (private)': mixed_case_private,
    }
