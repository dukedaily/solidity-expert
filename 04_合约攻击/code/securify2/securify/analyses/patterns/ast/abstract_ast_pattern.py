from abc import ABC

from securify.analyses.patterns.abstract_pattern import AbstractPattern, PatternMatchError, \
    PatternNotApplicableError, MatchSourceLocation, MatchAstNode, Level
from securify.grammar import Grammar
from securify.grammar.transformer import DictTransformer

from securify.solidity.v_0_5_x import solidity_grammar_core as ast


class AbstractAstPattern(AbstractPattern, ABC):
    level = Level.AST

    def get_ast_module(self):
        return ast

    def get_ast_root(self):
        ast_root = self.analysis_context.ast

        if isinstance(ast_root, Exception):
            raise PatternMatchError("AST is not available") from ast_root

        if ast_root is None:
            raise PatternMatchError("AST is not available")

        # TODO: transformed dict or grammar should be available in analysis_context
        ast_root = DictTransformer(Grammar.from_modules(ast), implicit_terminals=True).transform(ast_root)

        if not isinstance(ast_root, ast.SourceUnit):
            raise PatternNotApplicableError("Unrecognized AST root type.")

        return ast_root

    def ast_node_info(self, ast_node):
        return [
            MatchSourceLocation(
                self.analysis_context.config.encoding,
                ast_node.src_range[0],
                ast_node.src_range[1],
                ast_node.src_line,
                ast_node.src_contract
            ),
            MatchAstNode(
                ast_node
            )
        ]
