from __future__ import annotations

from typing import List

from securify.grammar.attributes import AttributeGrammar
from securify.grammar.attributes.annotations import synthesized, pushdown
from securify.grammar.attributes.evaluators.evaluator_static import StaticEvaluator


class Parent:
    children: List[Child]

    def __init__(self, *children):
        self.children = children

    @synthesized
    def max_value(self, children: {value}):
        return max([c.value for c in children])

    @pushdown.base
    def partial_sum(self: {max_value}) -> {children: {partial_sum}}:
        return self.max_value

    @partial_sum.step
    def partial_sum(self, children: {attenuated_sum}) -> {children: {partial_sum}}:
        return children.attenuated_sum

    @synthesized
    def attenuated_sums(self, children: {attenuated_sum}) -> {children: {partial_sum}}:
        return [c.attenuated_sum for c in children]


class Child:
    value: int

    def __init__(self, v):
        self.value = v

    @synthesized
    def value(self):
        return self.value

    @synthesized
    def attenuated_sum(self: {partial_sum, value}):
        return self.partial_sum / 2 + self.value


def main():
    grammar = AttributeGrammar([
        Parent,
        Child
    ])

    from pprint import pprint
    pprint(grammar.grammar_info())

    pprint("Local Functional Dependencies")
    for i, j in grammar.local_functional_dependence.items():
        pprint(i)

        for jj in j:
            pprint(jj, indent=2)

        print()

    pprint("Lower Dependencies")
    pprint(grammar.lower_dependence)

    print()
    print(grammar.is_acyclic)
    print(grammar.is_absolutely_acyclic)

    array = [4, 8, 2, 24, 32]

    root = Parent(*map(Child, array))
    root = StaticEvaluator(grammar).for_tree(root)

    expected = []
    tmp = max(array)
    for a in array:
        tmp = tmp / 2 + a
        expected.append(tmp)

    print(root.attenuated_sums)
    print(expected)


if __name__ == '__main__':
    main()
