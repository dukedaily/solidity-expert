from __future__ import annotations

import os
import tempfile
import time
from dataclasses import dataclass
from functools import lru_cache

from semantic_version import Version

from .v_0_5_x import solidity_grammar as solidity_v_0_5_x

from .solidity_ast_compiler import compile_ast

from .. import SecurifyError
from ..grammar.attributes import AttributeGrammar
from ..grammar.attributes.annotations3 import Parser
from ..grammar.attributes.evaluators import DefaultEvaluator
from ..grammar.transformer import DictTransformer
from ..ir import cfg_ir as ir

__all__ = [
    "compile_cfg",
    "compile_cfg_from_string",
    "compile_attributed_ast",
    "compile_attributed_ast_from_string",
    "compile_evaluable_ast",
    "CompileOutput",
    "CompilationStats",
    "get_solidity_grammar_instance",
]


@dataclass
class CompileOutput:
    cfg: ir.SourceUnit
    ast: ast.SourceUnit
    ast_dict: dict

    compilation_stats: CompilationStats

    ast_evaluable: ast.SourceUnit

    def __iter__(self):
        return iter((self.cfg, self.ast, self.ast_dict, self.ast_evaluable))


@dataclass
class CompilationStats:
    ast_compile_time: float
    cfg_compile_time: float

    def pprint(self):
        time_format = '{:<17}{:.5f}s'
        print(time_format.format('AST compilation time', self.ast_compile_time))
        print(time_format.format('CFG compilation time', self.cfg_compile_time))


def compile_evaluable_ast(ast_or_source_path):
    start_time = time.time()

    if isinstance(ast_or_source_path, dict):
        ast_dict = ast_or_source_path
    else:
        ast_dict = compile_ast(ast_or_source_path)

    ast_compile_time = time.time() - start_time

    grammar = get_solidity_grammar_instance(
        solidity_version=ast_dict["_solc_version"]
    )

    ast = DictTransformer(grammar=grammar,
                          implicit_terminals=True).transform(ast_dict)

    return ast, ast_dict, ast_compile_time, grammar


def compile_cfg(ast_or_source_path, evaluator=...):
    if evaluator is ...:
        evaluator = DefaultEvaluator

    (ast, ast_dict, ast_compile_time, grammar) = \
        compile_evaluable_ast(ast_or_source_path)

    start_time = time.time()
    ast_attr = evaluator(grammar).for_tree(ast)
    cfg = ast_attr.cfg
    end_time = time.time()
    cfg_compile_time = end_time - start_time

    return CompileOutput(cfg, ast, ast_dict, CompilationStats(
        ast_compile_time,
        cfg_compile_time
    ), ast_attr)


def compile_attributed_ast(ast_or_source_path, evaluator=...):
    if evaluator is ...:
        evaluator = DefaultEvaluator

    (ast, _, _, grammar) = \
        compile_evaluable_ast(ast_or_source_path)

    return evaluator(grammar).for_tree(ast)


def compile_cfg_from_string(source, evaluator=...):
    path = tempfile.gettempprefix() + ".sol"
    try:
        with open(path, "w") as tmp:
            tmp.write(source)

        return compile_cfg(path, evaluator)
    finally:
        os.remove(path)


def compile_attributed_ast_from_string(source, evaluator=...):
    path = tempfile.gettempprefix() + ".sol"
    try:
        with open(path, "w") as tmp:
            tmp.write(source)

        return compile_attributed_ast(path, evaluator)
    finally:
        os.remove(path)


@lru_cache()
def get_solidity_grammar_instance(solidity_version=None):
    if isinstance(solidity_version, str):
        solidity_version = Version(solidity_version)

    version_map = {
        Version("0.5.0"): (solidity_v_0_5_x, Parser),
        Version("0.6.0"): (solidity_v_0_5_x, Parser),
    }

    grammar_and_parser = None
    for version in sorted(version_map.keys(), reverse=True):
        if solidity_version is None:
            can_use_version = version_map[version] is not None
        else:
            can_use_version = version <= solidity_version

        if can_use_version:
            grammar_and_parser = version_map[version]
            break

    if grammar_and_parser is None:
        raise SecurifyCompilationError(
            f"Solc version {solidity_version} not supported by CFG compiler.")

    grammar, rule_parser = grammar_and_parser

    return AttributeGrammar.from_modules(
        grammar,
        check_acyclicity=False,
        rule_extractor=rule_parser())


class SecurifyCompilationError(SecurifyError):
    pass
