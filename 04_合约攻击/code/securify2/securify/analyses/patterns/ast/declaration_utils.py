from abc import ABC

from securify.analyses.patterns.ast.abstract_ast_pattern import AbstractAstPattern


class DeclarationUtils(AbstractAstPattern, ABC):

    def find_named_nodes(self, ast_root):
        def get_name(node):
            return node.name

        all_nodes = ast_root.find_descendants_of_type(self.named_node_types)

        yield from (
            (
                get_name(node),
                self.get_decl_kind(node),
                node
            ) for node in all_nodes)

    @property
    def named_node_types(self):
        ast = self.get_ast_module()

        return (
            ast.ContractDefinition,
            ast.FunctionDefinition,
            ast.ModifierDefinition,
            ast.VariableDeclaration,
            ast.StructDefinition,
            ast.EnumDefinition,
            ast.EnumValue,
            ast.EventDefinition,
        )

    def get_decl_kind(self, node):
        ast = self.get_ast_module()

        if isinstance(node, ast.ModifierDefinition):
            return "modifier"

        if isinstance(node, ast.FunctionDefinition):
            return "function"

        if isinstance(node, ast.ContractDefinition):
            return "contract"

        if isinstance(node, ast.StructDefinition):
            return "struct"

        if isinstance(node, ast.EnumDefinition):
            return "enum"

        if isinstance(node, ast.EnumValue):
            return "enum value"

        if isinstance(node, ast.EventDefinition):
            return "event"

        if isinstance(node, ast.VariableDeclaration):
            if isinstance(node.parent(), ast.StructDefinition):
                return "struct field"

            if isinstance(node.parent(), ast.ContractDefinition):
                return "state variable"

            if isinstance(node.parent(), ast.ParameterList):
                return "argument variable"

            return "local variable"

        return "declaration"
