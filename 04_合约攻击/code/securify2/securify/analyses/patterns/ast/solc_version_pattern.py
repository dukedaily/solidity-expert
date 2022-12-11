from typing import List

from securify.analyses.patterns.abstract_pattern import Severity, PatternMatch, MatchComment
from securify.analyses.patterns.ast.abstract_ast_pattern import AbstractAstPattern
from securify.analyses.patterns.ast.declaration_utils import DeclarationUtils
from securify.solidity.v_0_5_x.solidity_grammar_core import PragmaDirective
import re


class SolcVersionPattern(DeclarationUtils, AbstractAstPattern):
    name = "Solidity pragma directives"

    description = "Avoid complex solidity version pragma statements."

    # Needs to be changed to informational
    severity = Severity.LOW
    tags = {}

    def find_matches(self) -> List[PatternMatch]:
        ast_root = self.get_ast_root()
        nodes = ast_root.find_descendants_of_type(PragmaDirective)
        for node in nodes:
            # Is != also used
            if re.compile(r"[<>^]").search(node.src_code):
                yield self.match_violation().with_info(
                    MatchComment(f"{node.src_code} is complex"),
                    *self.ast_node_info(node)
                )
