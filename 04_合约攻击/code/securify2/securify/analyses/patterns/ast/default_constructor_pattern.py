from typing import List

from securify.analyses.patterns.abstract_pattern import Severity, PatternMatch, MatchComment
from securify.analyses.patterns.ast.abstract_ast_pattern import AbstractAstPattern


class CallToDefaultConstructorPattern(AbstractAstPattern):
    name = "Call to Default Constructor"

    description = "A call to the constructor might be a call to a normal function instead."

    severity = Severity.LOW
    tags = {}

    def find_matches(self) -> List[PatternMatch]:
        ast = self.get_ast_module()
        ast_root = self.get_ast_root()

        for constructor in ast_root.find_descendants_of_type(ast.FunctionDefinition):
            if not constructor.is_constructor:
                continue

            for modifier in constructor.modifiers:
                modifier_decl = modifier.modifier_name.resolve()

                if modifier.arguments is None:
                    continue

                if not isinstance(modifier_decl, ast.ContractDefinition):
                    continue

                base_constructor = modifier_decl.find_descendants_of_type(ast.FunctionDefinition)
                base_constructor = next((b for b in base_constructor if b.is_constructor), None)

                if base_constructor is None:
                    yield self.match_violation().with_info(
                        MatchComment("Explicit call to default constructor."),
                        *self.ast_node_info(modifier)
                    )

