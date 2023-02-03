from typing import List
import re

from securify.analyses.patterns.abstract_pattern import Severity, PatternMatch, MatchComment, MatchAstNode
from securify.analyses.patterns.ast.abstract_ast_pattern import AbstractAstPattern
from securify.analyses.patterns.ast.declaration_utils import DeclarationUtils
from securify.solidity.v_0_5_x.solidity_grammar_core import EventDefinition


class ERC20IndexedPattern(DeclarationUtils, AbstractAstPattern):
    name = "ERC20 Indexed Pattern"

    description = "Events defined by ERC20 specification should use the 'indexed' keyword."

    severity = Severity.LOW
    tags = {}

    def find_matches(self) -> List[PatternMatch]:
        ast_root = self.get_ast_root()
        events = ast_root.find_descendants_of_type(EventDefinition)

        for e in events:
            if e.name in self.ERC20_events:
                matches = [re.match(r".* indexed .*", p.src_code) for p in e.parameters.parameters[:2]]
                if all(matches):
                    yield self.match_compliant().with_info(
                        MatchComment(f"{e.name} event is a compliant ERC20 event."),
                        *self.ast_node_info(e)
                    )
                else:
                    yield self.match_violation().with_info(
                        MatchComment(f"{e.name} event is an ERC20 event and as such, \
                        it should contain indexed keyword in the first two arguments"),
                        *self.ast_node_info(e)

                    )

    ERC20_events = {
        "Transfer", "Approval"
    }
