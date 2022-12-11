from functools import singledispatch
from typing import Iterator

from securify.analyses.patterns.abstract_pattern import Severity, PatternMatch, MatchComment
from securify.analyses.patterns.ast.abstract_ast_pattern import AbstractAstPattern
from securify.analyses.patterns.ast.declaration_utils import DeclarationUtils
from securify.solidity.utils import of_type


class ShadowedLocalVariablePattern(DeclarationUtils, AbstractAstPattern):
    name = "Shadowed Local Variable"

    description = "Reports local variable declarations that " \
                  "shadow declarations from outer scopes."

    severity = Severity.MEDIUM
    tags = {}

    def find_matches(self) -> Iterator[PatternMatch]:
        ast_root = self.get_ast_root()
        ast = self.get_ast_module()

        for contract in ast_root.find_descendants_of_type(ast.ContractDefinition):
            conflicts = self.process_declarations(contract)

            for conflict in conflicts:
                shadowed_var, new_var = conflict

                yield self.match_violation().with_info(
                    MatchComment(f"{self.get_decl_kind(new_var).capitalize()} '{new_var.name}' "
                                 f"shadows {self.get_decl_kind(shadowed_var)} from outer scope."),
                    *self.ast_node_info(new_var)
                )

    def process_declarations(self, contract):
        ast = self.get_ast_module()

        @singledispatch
        def add_decls(_, scope):
            return []

        @add_decls.register
        def _(statement: ast.Statement, scope):
            for c in statement.children():
                yield from add_decls(c, scope)

        @add_decls.register
        def _(params: ast.ParameterList, scope):
            for c in params.parameters:
                yield from add_decls(c, scope)

        # Scope processors
        @add_decls.register(ast.VariableDeclaration)
        def _(decl, scope):
            if decl.name == "":
                return

            if decl.name in scope:
                yield scope[decl.name], decl

            scope[decl.name] = decl

        @add_decls.register
        def _(c: ast.ContractDefinition, scope):
            bases = reversed(c.linearized_base_contracts)

            function_like = (
                ast.FunctionDefinition,
                ast.ModifierDefinition,
            )

            for base in bases:
                base: ast.ContractDefinition = c.resolve_reference(base)
                new_decls = ((t.name, t) for t in base.find_children_of_type(self.named_node_types))

                scope.update(new_decls)

            for node in of_type[function_like](c.nodes):
                yield from add_decls(node, scope)

        @add_decls.register
        def _(node: ast.FunctionDefinition, scope):
            function_scope = scope.copy()

            yield from add_decls(node.parameters, function_scope)
            yield from add_decls(node.return_parameters, function_scope)
            yield from add_decls(node.body, function_scope)

        @add_decls.register
        def _(node: ast.ModifierDefinition, scope):
            function_scope = scope.copy()

            yield from add_decls(node.parameters, function_scope)
            yield from add_decls(node.body, function_scope)

        @add_decls.register
        def _(node: ast.Block, scope):
            current_scope = scope.copy()

            for stmt in node.statements:
                yield from add_decls(stmt, current_scope)

        @add_decls.register
        def _(node: ast.IfStatement, scope):
            yield from add_decls(node.true_body, scope.copy())
            yield from add_decls(node.false_body, scope.copy())

        @add_decls.register
        def _(node: ast.ForStatement, scope):
            current_scope = scope.copy()

            yield from add_decls(node.initialization_expression, current_scope)
            yield from add_decls(node.body, current_scope)

        yield from add_decls(contract, {})
