from __future__ import annotations

from dataclasses import dataclass
from typing import Optional

from securify.grammar import production
from securify.grammar.attributes import AttributeGrammar
from securify.grammar.attributes.annotations3 import synthesized, inherited, Parser
from securify.grammar.attributes.evaluators import StaticEvaluator


@production
@dataclass(eq=False)
class Parent:
    child1: ChildA
    child2: ChildA

    default = synthesized(default="Default Synth")


@production
@dataclass(eq=False)
class ChildA:
    child: Optional[ChildB]
    attr = inherited(default="Success")
    listA = inherited(default=[])
    listB = inherited(default=lambda: [])


@production
@dataclass(eq=False)
class ChildB:
    attr = inherited()


if __name__ == '__main__':
    grammar = AttributeGrammar([Parent, ChildA, ChildB],
                               rule_extractor=Parser())

    ast = Parent(ChildA(ChildB()), ChildA(None))
    ast = StaticEvaluator(grammar).for_tree(ast)

    print(ast.default)

    print(ast.child1.attr)
    print(ast.child1.child.attr)

    print(ast.child1.listA, ast.child1.listB)
    ast.child1.listA.append(1)
    ast.child1.listB.append(1)
    print(ast.child1.listA, ast.child1.listB)
    print(ast.child2.listA, ast.child2.listB)
