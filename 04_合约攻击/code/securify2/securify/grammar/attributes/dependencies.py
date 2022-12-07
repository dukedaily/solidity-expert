from collections import defaultdict
from functools import lru_cache

from securify.grammar.attributes import AttributeGrammar, PushdownRule


class AttributeDependenceRelations:

    def __init__(self, attribute_grammar: AttributeGrammar):
        self.grammar = attribute_grammar

    @property
    @lru_cache(1)
    def local_functional_dependence(self):
        grammar = self.grammar
        result = {}

        for p in grammar.productions:
            d = set()
            for target, rule in grammar.synthesized_rules[p].items():
                rule = rule[0]
                for dependency in rule.dependencies:
                    d.add((dependency, target))

            for target, rule in grammar.inheritable_rules[p].items():
                rule = rule[0]
                if isinstance(rule, PushdownRule):
                    for dependency in rule.dependencies:
                        d.add((dependency, target))

            result[p] = DependenceRelation(d)

        return result

    @staticmethod
    def expand(node, relation):
        return {((node, a), (node, b)) for a, b in relation}

    @staticmethod
    def project(relation):
        return {(a, b) for ((i, a), (j, b)) in relation if i == j == "self"}

    def effect_transitive_union(self, p, ls):
        d = self.local_functional_dependence
        result = d[p]

        for i, l in ls:
            result = result.union(self.expand(i, l))

        return result.transitive_closure()

    def effect(self, p, ls):
        result = self.effect_transitive_union(p, ls)
        result = self.project(result)

        return DependenceRelation(result)

    @property
    @lru_cache(1)
    def lower_dependence(self):
        grammar = self.grammar
        ldr = {s: {DependenceRelation()} for s in grammar.productions}

        def ldrs(symbols):
            return {q for ss in grammar.get_sub_productions(symbols) for q in ldr[ss]}

        while True:
            prev_lengths = list(map(len, ldr.values()))

            for s in grammar.productions:
                p = grammar.productions[s]

                p_i_name, p_i_symbols = ([], []) if len(p) == 0 else zip(*p.items())
                p_i_ldrs = [ldrs(i.symbol) for i in p_i_symbols]

                from itertools import product
                for ls in product(*p_i_ldrs):
                    ldr[s].add(self.effect(s, zip(p_i_name, ls)))

            new_lengths = list(map(len, ldr.values()))

            if prev_lengths == new_lengths:
                break

        return ldr

    @property
    @lru_cache(1)
    def lower_dependence_combined(self):
        grammar = self.grammar
        r = {s: DependenceRelation() for s in grammar.productions}

        def rs(symbols):
            return {r[ss] for ss in self.grammar.get_sub_productions(symbols)}

        while True:
            prev_lengths = list(map(len, r.values()))

            for s in grammar.productions:
                p = grammar.productions[s]

                p_i_name, p_i_symbols = ([], []) if len(p) == 0 else zip(*p.items())
                p_i_ldrs = [rs(i.symbol) for i in p_i_symbols]

                from itertools import product
                for ls in product(*p_i_ldrs):
                    r[s] = r[s].union(self.effect(s, zip(p_i_name, ls)))

            new_lengths = list(map(len, r.values()))

            if prev_lengths == new_lengths:
                break

        return r

    @property
    @lru_cache(1)
    def is_acyclic(self):
        grammar = self.grammar
        ldr = self.lower_dependence

        def ldrs(symbols):
            return {q for ss in grammar.get_sub_productions(symbols) for q in ldr[ss]}

        for s in grammar.productions:
            p = grammar.productions[s]

            p_i_name, p_i_symbols = ([], []) if len(p) == 0 else zip(*p.items())
            p_i_ldrs = [ldrs(i.symbol) for i in p_i_symbols]

            from itertools import product
            for ls in product(*p_i_ldrs):
                if not self.effect_transitive_union(s, zip(p_i_name, ls)).is_acyclic:
                    return False

        return True

    @property
    @lru_cache(1)
    def is_absolutely_acyclic(self):
        grammar = self.grammar
        r = self.lower_dependence_combined

        def rs(symbol):
            return {r[ss] for ss in self.grammar.get_sub_productions(symbol)}

        for s in grammar.productions:
            p = grammar.productions[s]

            p_i_name, p_i_symbols = ([], []) if len(p) == 0 else zip(*p.items())
            p_i_ldrs = [rs(i.symbol) for i in p_i_symbols]

            from itertools import product
            for ls in product(*p_i_ldrs):
                if not self.effect_transitive_union(s, zip(p_i_name, ls)).is_acyclic:
                    return False

        return True


class DependenceRelation(frozenset):
    # dependence relation (b, a) <=> a depends on b
    def __new__(cls, iterable=...):
        if iterable is ...:
            return frozenset.__new__(cls)
        else:
            return frozenset.__new__(cls, iterable)

    def transitive_closure(self):
        result = self.copy()
        previously_added = result

        while True:
            previously_added1 = defaultdict(lambda: [])
            for elem in previously_added:
                previously_added1[elem[0]].append(elem)

            new_relations = {(a, c)
                             for (a, b1) in result
                             for (b2, c) in previously_added1[b1]}

            old_size = len(result)
            result |= new_relations
            new_size = len(result)

            previously_added = new_relations

            if old_size == new_size:
                break

        return DependenceRelation(result)

    def union(self, *s):
        return DependenceRelation(super().union(*s))

    @property
    def is_acyclic(self):
        for a, b in self:
            if a == b:
                return False
        return True

    @property
    @lru_cache(1)
    def depends_on(self):
        result = {a: set() for _, a in self}

        for (b, a) in self:
            result[a].add(b)

        return result

    @property
    @lru_cache(1)
    def dependency_of(self):
        result = {a: set() for a, _ in self}

        for (a, b) in self:
            result[a].add(b)

        return result

    def __repr__(self) -> str:
        return set(self).__repr__()
