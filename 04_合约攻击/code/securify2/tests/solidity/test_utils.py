import json
import pickle
from dataclasses import dataclass
from pathlib import Path

from securify.grammar.attributes.evaluators import DefaultEvaluator
from securify.grammar.transformer import DictTransformer
from securify.solidity import get_solidity_grammar_instance, CompileOutput
from securify.solidity.solidity_ast_compiler import compile_ast
from securify.solidity.v_0_5_x.solidity_grammar import AstNode


def compile_cached(path_src):
    grammar = get_solidity_grammar_instance()

    path_src = Path(path_src)
    path_cache = path_src.parent / "cache"

    if not path_cache.exists():
        path_cache.mkdir()

    path_ast_json = path_cache / (path_src.name + ".ast_json")
    path_ast = path_cache / (path_src.name + ".ast")

    if not path_ast_json.exists() or not path_ast.exists():
        ast_json = compile_ast(str(path_src))
        ast = DictTransformer(grammar=grammar,
                              implicit_terminals=True).transform(ast_json)

        print(f"Precompiled AST not found. Compiling AST... [{path_src}]")
        with open(path_ast_json, 'w') as file:
            ast_json["_solc_version"] = str(ast_json["_solc_version"])
            json.dump(ast_json, file)

        with open(path_ast, 'wb') as file:
            pickle.dump(ast, file)

    with open(path_ast, 'rb') as file:
        ast = pickle.load(file)

    ast = DefaultEvaluator(grammar).for_tree(ast)

    return CompileOutput(ast.cfg, ast, None, None, None)


@dataclass
class AstNodeDescription:
    node_type_name: str
    node_values: dict
