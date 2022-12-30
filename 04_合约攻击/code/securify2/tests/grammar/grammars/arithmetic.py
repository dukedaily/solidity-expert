from __future__ import annotations

from dataclasses import dataclass
from typing import Union, List, Optional

from securify.grammar import production, abstract_production
from securify.grammar.attributes import AttributeGrammar, ListElement
from securify.grammar.attributes.annotations3 import Parser, synthesized, inherited, pushdown, All, rules_for


@abstract_production
class ASTNode:
    pass


@production
@dataclass(unsafe_hash=True)
class Root(ASTNode):
    content: Term

    @pushdown
    def index(self) -> Term.index @ content:
        return None

    @pushdown
    def depth(self) -> Term.depth @ content:
        return 0

    @pushdown
    def implicit_pushdown(self) -> Term.implicit_pushdown @ content:
        return None


# @pushdown
# def root_comment(self: Root) -> Other.comment @ Root.content:
#     return "Comment"


# @production
# class Other(ASTNode):
#     comment = inherited()


@abstract_production
class Term(ASTNode):
    # Inherited Attributes
    implicit_pushdown = inherited(implicit_pushdown=True)

    depth = inherited()
    index = inherited()

    # Synthesized Attributes
    index2 = synthesized()
    value = synthesized()
    type = synthesized()

    subtree_depth = synthesized()
    string = synthesized()
    summary = synthesized()

    # Default Rule Implementations
    @synthesized
    def summary(self):
        return "%s, %s" % (self.value, self.type)

    @synthesized
    def index2(self):
        if self.index is None:
            return None

        return self.index * 2

    @pushdown
    def rule_index(self) -> Term.index @ All:
        return None

    @pushdown
    def rule_depth(self) -> Term.depth @ All:
        return self.depth + 1


Term.set_in_module = synthesized()

with rules_for(Term):
    @synthesized
    def set_in_module():
        return "Success"


@production
class Sum(Term):
    addends: List[Term]

    def __init__(self, *addends):
        super().__init__()
        self.addends = list(addends)

    @pushdown
    def index_pushdown(self) -> Term.index @ addends:
        return 0

    @pushdown
    def index_pushdown(self: ListElement[Sum, "addends"]) -> Term.index @ next:
        return self.index + 1

    @pushdown
    def depth_pushdown(self) -> Term.depth @ addends:
        return self.depth + 1

    @pushdown
    def depth_pushdown(self: ListElement[Sum, "addends"]) -> Term.depth @ next:
        return self.depth

    @synthesized
    def value(self, addends: Term.value):
        return sum([a.value for a in addends])

    @synthesized
    def rule_type(self, addends: Term.type) -> Term.type:
        return float if any([float == a.type for a in addends]) else int

    @synthesized
    def rule_string(self, addends: Term.string) -> Term.string:
        return "SUM(%s)" % ", ".join([a.string for a in addends])

    @synthesized
    def rule_subtree_depth(self, addends: Term.subtree_depth) -> Term.subtree_depth:
        return max([a.subtree_depth for a in addends])


# noinspection PyMethodParameters
@production
class Addition(Term):
    lhs: Term
    rhs: Term

    def __init__(self, lhs=None, rhs=None):
        super().__init__()
        self.lhs = lhs
        self.rhs = rhs

    @synthesized
    def value(self, lhs, rhs) -> Term.value:
        return lhs.value + rhs.value

    @synthesized
    def type(self, lhs, rhs) -> Term.type:
        if lhs.type is float or rhs.type is float:
            return float
        else:
            return int

    @synthesized
    def string(self, lhs, rhs) -> Term.string:
        return "(%s + %s)" % (lhs.string, rhs.string)

    @synthesized
    def subtree_depth(self, lhs, rhs) -> Term.subtree_depth:
        return max(lhs.subtree_depth, rhs.subtree_depth)


@production
class Multiplication(Term):
    lhs: Term
    rhs: Term

    def __init__(self, lhs=None, rhs=None):
        super().__init__()
        self.lhs = lhs
        self.rhs = rhs

    @synthesized
    def rule_value(self, lhs, rhs) -> Term.value:
        return lhs.value * rhs.value

    @synthesized
    def rule_type(self, lhs, rhs) -> Term.type:
        if lhs.type is float or rhs.type is float:
            return float
        else:
            return int

    @synthesized
    def rule_string(self, lhs, rhs) -> Term.string:
        return "(%s * %s)" % (lhs.string, rhs.string)

    @synthesized
    def rule_subtree_depth(self, lhs: Term, rhs: Term) -> Term.subtree_depth:
        return max(lhs.subtree_depth, rhs.subtree_depth)


@production
class Constant(Term):
    value: Union[int, float]
    type: Union[int.__class__, float.__class__]

    def __init__(self, value) -> None:
        super().__init__()
        self.value = value
        self.type = type(value)

    @synthesized
    def value(self):
        return getattr(self, "value")

    @synthesized
    def type(self):
        return getattr(self, "type")

    @synthesized
    def string(self):
        return str(self.value)

    @synthesized
    def subtree_depth(self):
        return self.depth


def parse_rpn(rpn) -> Root:
    from ast import literal_eval

    stack = []
    for e in rpn.split(" "):
        if e == "+":
            b, a = stack.pop(), stack.pop()
            stack.append(Addition(a, b))
        elif e == "*":
            b, a = stack.pop(), stack.pop()
            stack.append(Multiplication(a, b))
        elif e == "SUM":
            stack.reverse()
            stack = [Sum(*stack)]
        else:
            value = literal_eval(e)
            assert type(value) in [int, float]
            stack.append(Constant(value))

    assert len(stack) == 1

    return Root(stack[0])


def main():
    from securify.grammar.attributes.evaluators.evaluator import DemandDrivenRecursive

    grammar = AttributeGrammar([
        ASTNode,
        Root,
        # Other,
        Term,
        Addition,
        Multiplication,
        Constant,
        Sum,
    ], rule_extractor=Parser())

    from pprint import pprint
    info = grammar.grammar_info()
    pprint(grammar.grammar_info(), width=120, indent=2)

    root = Sum(
        Multiplication(Addition(Constant(1), Constant(2)), Constant(2.5)),
        Constant(2),
        Constant(2),
        Constant(2),
        Constant(5)
    )

    root.implicit_pushdown = "Works!"
    root.depth = 0
    root.index = None

    root = DemandDrivenRecursive(grammar).for_tree(root)

    print()
    print("Results:")

    print("Root value", root.value)
    print("Root string", root.string)

    print("Root string", root.subtree_depth)
    print("Root lhs depth", root.addends[1].depth)
    print("Root lhs depth", root.addends[0].lhs.depth)
    print("Root lhs max subtree", root.subtree_depth)

    print("Implicit Attribute", root.addends[0].implicit_pushdown)

    print(DemandDrivenRecursive(grammar).for_tree(Root(Constant(1))).content.depth)
    # print(DemandDriven(grammar).for_tree(Root(Other())).content.comment)

    print("Index", root.addends[0].index)
    print("Index", root.addends[1].index)
    print("Index", root.addends[2].index)
    print("Index", root.addends[3].index)
    print("Index", root.addends[4].index)

    print(root.set_in_module)

    # print("LPR")
    # pprint({a.__name__: set(b) for a, b in grammar.local_functional_dependence.items()})
    # print("LDR")
    # pprint({a.__name__: set(b) for a, b in grammar.lower_dependence.items()})
    # print("R")
    # pprint({a.__name__: set(b) for a, b in grammar.lower_dependence_combined.items()})
    #
    # print("Acyclic", grammar.is_acyclic)
    # print("Absolutely Noncircular", grammar.is_absolutely_acyclic)

    # root_static = StaticEvaluator(grammar).for_tree(root_original)
    # print()

    # grammar.validate_rules()


if __name__ == '__main__':
    main()
