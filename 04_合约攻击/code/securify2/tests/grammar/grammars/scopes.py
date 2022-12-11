from __future__ import annotations

from typing import Tuple

from securify.grammar import abstract_production, production
from securify.grammar.attributes import AttributeGrammar
from securify.grammar.attributes.annotations3 import synthesized, pushdown, inherited, Parser
from securify.grammar.attributes.evaluators import DemandDrivenIterative
from securify.grammar.attributes.evaluators import StaticEvaluator


def append_dict(d: dict, t: tuple):
    new_dict = d.copy()
    new_dict[t[0]] = t[1]
    return new_dict


@abstract_production
class Decl:
    new: Tuple[(str, str)] = synthesized()
    env: dict = inherited()
    ok: bool = synthesized()

@production
class VarDecl(Decl):
    var: str
    typ: str

    @synthesized
    def new(self):
        return self.var, self.typ

    @synthesized
    def ok(self):
        return True

    def ast_dict(self):
        return {
            "var": self.var,
            "type": self.typ,
            "class": self.__class__.__name__
        }


@production
class SubDecl(Decl):
    block: Block
    var: str

    @synthesized
    def new(self):
        return self.var, "void()"

    @synthesized
    def ok(self, block):
        return block.ok

    @pushdown
    def block_same(self) -> Block.same @ block:
        return []

    @pushdown
    def block_env(self, block) -> Block.env @ block:
        return {**self.env, **block.procs}

    def ast_dict(self):
        return {
            "block": self.block.ast_dict(),
            "var": self.var,
            "class": self.__class__.__name__
        }


@abstract_production
class Stat:
    ok: bool = synthesized()
    env: dict = inherited()
    same: list = inherited()


@production
class StatAssign(Stat):  # Assignment of value of type tpe to var
    var: str
    typ: str

    @synthesized
    def ok(self):
        return self.env[self.var] == self.typ

    def ast_dict(self):
        return {
            "type": self.typ,
            "var": self.var,
            "class": self.__class__.__name__
        }


@production
class StatBlock(Stat):
    block: Block

    @pushdown
    def block_env(self, block) -> Block.env @ block:
        return {**self.env, **block.procs}

    @pushdown
    def block_same(self) -> Block.same @ block:
        return []

    @synthesized
    def ok(self, block):
        return block.ok

    def ast_dict(self):
        return {
            "block": self.block.ast_dict(),
            "class": self.__class__.__name__
        }


@abstract_production
class Block:
    ok: bool = synthesized()
    env: dict = inherited()
    procs: dict = synthesized()
    same: list = inherited()


@production
class BlockDeclList(Block):
    decl: Decl
    block: Block

    @pushdown
    def decl_env(self) -> Decl.env @ decl:
        return self.env

    @pushdown
    def block_same(self, decl) -> Block.same @ block:
        return self.same + [decl.new]

    @pushdown
    def block_env(self, decl) -> Block.env @ block:
        return append_dict(self.env, decl.new)

    @synthesized
    def ok(self, decl, block):
        return decl.new not in self.same and (decl.ok and block.ok)

    @synthesized
    def procs(self, decl, block):
        if decl.new[1] == "void()":
            return append_dict(block.procs, decl.new)
        else:
            return block.procs

    def ast_dict(self):
        return {
            "decl": self.decl.ast_dict(),
            "block": self.block.ast_dict(),
            "class": self.__class__.__name__
        }


@production
class BlockStatList(Block):
    stat: Stat
    block: Block

    @pushdown
    def stat_same(self) -> Stat.same @ stat:
        return None

    @pushdown
    def stat_env(self) -> Stat.env @ stat:
        return self.env

    @pushdown
    def block_env(self) -> Block.env @ block:
        return self.env

    @pushdown
    def block_same(self) -> Block.same @ block:
        return self.same

    @synthesized
    def ok(self, stat, block):
        return stat.ok and block.ok

    @synthesized
    def procs(self, block):
        return block.procs

    def ast_dict(self):
        return {
            "stat": self.stat.ast_dict(),
            "block": self.block.ast_dict(),
            "class": self.__class__.__name__
        }


@production
class BlockEmpty(Block):
    @synthesized
    def ok(self):
        return True

    @synthesized
    def procs(self):
        return {}

    def ast_dict(self):
        return {
            "class": self.__class__.__name__
        }


program = """
    int a 
    {
        int b
        b = int
    }
    
    {
        {
            int p
        }
    }
    
    void test(){
        int a
        int b 
        
        a = int
    }
"""


def dump_ast(ast):
    import os
    import json
    ast_json = json.dumps(ast)
    with open("scopes_ast.json", 'w') as f:
        f.write(ast_json)
    os.startfile("scopes_ast.json")
    print(ast_json)


def main():
    from tests.grammar.grammars import scopes

    grammar = AttributeGrammar.from_modules(scopes, rule_extractor=Parser())

    # print(grammar.synthesized_attributes)
    # print(grammar.inheritable_attributes)

    from tests.grammar.grammars.scopes_parser import parse
    ast = parse(program)
    # dump_ast(grammar.grammar_info())

    grammar.traverse(ast, lambda n, a, c: setattr(n, "_id", id(n)))

    ast.same = []
    ast.env = {}

    ast_original = ast

    ast = DemandDrivenIterative(grammar).for_tree(ast)

    print(ast)
    print(ast.ok)
    print(ast.procs)

    from pprint import pprint

    pprint(grammar.grammar_info())
    print()
    print("# Local Functional Dependencies")
    pprint({a.__name__: set(b) for a, b in grammar.local_functional_dependence.items()})
    print()
    print("# Lower Dependence Relations")
    pprint({a.__name__: set(b) for a, b in grammar.lower_dependence.items()})

    print()
    print("# Lower Dependence All")
    pprint({a.__name__: set(b) for a, b in grammar.lower_dependence_combined.items()})
    print()
    # DictTransformer(grammar)
    #
    #
    # ast.env = {}
    # ast.same = []

    # ast = DemandDriven(ast).root
    # print(ast.ok)

    evaluated = StaticEvaluator(grammar).for_tree(ast_original)

    def attribute_dict(tree):
        result = {}

        def fill_dict(node, attribute):
            result[(node._id, attribute)] = getattr(node, attribute)

        grammar.attribute_visitor().visit(tree, fill_dict)

        return result

    for a in attribute_dict(evaluated):
        print(attribute_dict(ast)[a])
        print(attribute_dict(evaluated)[a])

    pprint(attribute_dict(evaluated) == attribute_dict(ast))

    pass


if __name__ == '__main__':
    main()
