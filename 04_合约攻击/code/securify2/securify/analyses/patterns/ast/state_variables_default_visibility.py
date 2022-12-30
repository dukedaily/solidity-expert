from typing import List
from collections import defaultdict

from securify.analyses.patterns.abstract_pattern import Severity, PatternMatch, MatchComment
from securify.analyses.patterns.ast.abstract_ast_pattern import AbstractAstPattern
from securify.analyses.patterns.ast.declaration_utils import DeclarationUtils
from securify.solidity.v_0_5_x.solidity_grammar_core import VariableDeclaration, FunctionDefinition, EventDefinition, StructDefinition


# IR has no information about the visibility of state variables.
class StateVariablesDefaultVisibilityPattern(DeclarationUtils, AbstractAstPattern):
    name = "State variables default visibility"

    description = "Visibility of state variables should be stated explicitly"

    severity = Severity.INFO
    tags = {}


    def find_matches(self) -> List[PatternMatch]:
        ast_root = self.get_ast_root()
        declarations = ast_root.find_descendants_of_type(VariableDeclaration)

        visibility = {"public", "internal", "private"}

        def contains_visibility_modifier(src_code):
            for v in visibility:
                if v in src_code:
                    return True
            return False

        for d in declarations:

            # Skip declarations inside functions since there not state variables.
            if d.find_ancestor_of_type(FunctionDefinition) \
                or d.find_ancestor_of_type(EventDefinition) \
                or d.find_ancestor_of_type(StructDefinition):
                continue

            if contains_visibility_modifier(d.src_code):
                yield self.match_compliant().with_info(
                    MatchComment(f"Visibility is defined for state variable: {d.name}"),
                    *self.ast_node_info(d)
                )
            else:
                yield self.match_violation().with_info(
                    MatchComment(f"Visibility is not defined for state variable: {d.name}"),
                    *self.ast_node_info(d)
                )

