from typing import List


from securify.analyses.patterns.abstract_pattern import Severity, PatternMatch, MatchComment
from securify.analyses.patterns.ast.abstract_ast_pattern import AbstractAstPattern
from securify.analyses.patterns.ast.declaration_utils import DeclarationUtils


class ShadowedBuiltinPattern(DeclarationUtils, AbstractAstPattern):
    name = "Shadowed Builtin"

    description = "Reports declarations that shadow Solidity's builtin symbols."

    severity = Severity.MEDIUM
    tags = {}

    def find_matches(self) -> List[PatternMatch]:
        ast_root = self.get_ast_root()

        def match_violation(name, tpe, node):
            return self.match_violation().with_info(
                MatchComment(f"{tpe.capitalize()} shadows builtin symbol '{name}'."),
                *self.ast_node_info(node)
            )

        for decl_name, decl_type, decl_node in self.find_named_nodes(ast_root):
            if decl_name in self.builtin_symbols:
                yield match_violation(decl_name, decl_type, decl_node)

    builtin_symbols = {
        "assert", "require", "revert",
        "blockhash", "block", "gasleft", "msg", "now", "tx", "abi",
        "addmod", "mulmod",
        "keccak256", "sha256", "sha3", "ripemd160", "ecrecover",
        "this", "super",
        "selfdestruct", "suicide",

        "abstract", "after", "alias", "apply", "auto",
        "case", "catch", "copyof",
        "default", "define",
        "final",
        "immutable", "implements", "in", "inline",
        "let",
        "macro", "match", "mutable",
        "null",
        "of", "override",
        "partial", "promise",
        "reference", "relocatable",
        "sealed", "sizeof", "static", "supports", "switch",
        "try", "type", "typedef", "typeof",
        "unchecked"
    }
