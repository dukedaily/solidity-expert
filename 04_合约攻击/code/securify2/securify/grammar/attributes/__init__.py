from __future__ import annotations

import itertools
from collections import namedtuple
from dataclasses import dataclass, field
from functools import lru_cache, partial
from typing import Dict, Tuple, Callable, List, Set

from securify.grammar import Grammar, DerivationTree, production

AttributeOccurrence = namedtuple('AttributeOccurrence', 'node attribute')


class AttributeGrammar(Grammar):

    def __init__(self, classes,
                 rule_extractor=...,
                 check_acyclicity=False, **kwargs):
        super().__init__(classes, **kwargs)

        if rule_extractor is ...:
            raise DeprecationWarning("A rule extractor must be passed explicitly.")
            # from securify.grammar.attributes.annotations import DefaultRuleParser
            # rule_extractor = DefaultRuleParser(implicit_rules=True)

        self.attributes = {}

        (self.synthesized_rules,
         self.inheritable_rules,
         self.synthesized_attributes,
         self.inherited_attributes) = rule_extractor(self, classes)

        for key in itertools.chain(self.synthesized_attributes, self.inherited_attributes):
            self.attributes[key] = self.synthesized_attributes.get(key, {}) | self.inherited_attributes.get(key, {})

        self.validate_attribute_grammar()

        from securify.grammar.attributes.dependencies import AttributeDependenceRelations
        self.dependence_relations = AttributeDependenceRelations(self)

        if check_acyclicity:
            self.validate_acyclicity()

    def attribute_visitor(self):
        return AttributeVisitor(self)

    def overridden_attributes(self, node):
        production = self.production_of(node)
        attributes = self.attributes[production]
        overridden = {a for a in attributes if a in node.__dict__}

        return overridden

    def validate_attribute_grammar(self):
        self.validate_grammar()
        # self.validate_rule_dependencies()
        self.validate_rule_targets()

        return True

    def validate_acyclicity(self):
        if not self.is_acyclic:
            raise AttributeGrammarValidationError(
                f"Attribute grammar is not acyclic. "
                f"See the lower dependence relation for more information: \n"
                f"{self.lower_dependence}")

    def validate_rule_dependencies(self):
        def validate_dependencies(symbol, rule):
            production = self.productions[symbol]

            for dependency in rule.dependencies:
                node = dependency.node
                attr = dependency.attribute

                if node not in production and node != "self":
                    raise AttributeGrammarValidationError(
                        f"Child '{node}' not in productions of symbol {symbol.__name__}")

                dependency_symbols = [symbol] if node == "self" else production[node].symbol

                for dependency_symbol in dependency_symbols:
                    available_attributes = self.attributes[dependency_symbol]
                    if attr not in available_attributes:
                        raise AttributeGrammarValidationError(
                            f"Attribute '{attr}' not available for rule "
                            f"'{rule}' of symbol '{dependency_symbol.__name__}'.")

        rules = {
            k: {*self.synthesized_rules.get(k, {}).values(), *self.inheritable_rules.get(k, {}).values()}
            for k in {*self.synthesized_rules.keys(), *self.inheritable_rules.keys()}
        }

        for symbol, rules in rules.items():
            for rule in rules:
                if isinstance(rule, (SynthesizeRule, PushdownRule)):
                    validate_dependencies(symbol, rule)
                # elif isinstance(rule, PushdownInductiveRule):
                #     validate_dependencies(symbol, rule.base_rule)
                #     validate_dependencies(symbol, rule.step_rule)

        return True

    def validate_rule_targets(self):
        for s, ps in self.productions.items():
            inheritable_rules = {
                (r.target.node,
                 r.target.attribute): r
                for rules in self.inheritable_rules[s].values()
                for r in rules}

            for n, p in ps.items():
                required_attributes = {a for a in self.inherited_attributes[p.symbol]}

                for a in required_attributes:
                    if (n, a) not in inheritable_rules:
                        raise AttributeGrammarValidationError(
                            f"Rule '{s.__name__}' defines child '{n}' which requires "
                            f"an attribute '{a}', but a corresponding semantic rule "
                            f"could not be found."
                        )

    # def validate_attribute_dependencies(self, tree):
    #     self.validate_tree(tree)
    #
    #     def validate_attribute_overrides(node):
    #         o = self.overridden_attributes(node)
    #
    #     self.visitor().visit(tree, lambda n, a, c: validate_attribute_overrides(n))
    #
    #     return True

    @property
    def local_functional_dependence(self):
        return self.dependence_relations.local_functional_dependence

    @property
    def lower_dependence(self):
        return self.dependence_relations.lower_dependence

    @property
    def lower_dependence_combined(self):
        return self.dependence_relations.lower_dependence_combined

    @property
    def is_acyclic(self):
        return self.dependence_relations.is_acyclic

    @property
    def is_absolutely_acyclic(self):
        return self.dependence_relations.is_absolutely_acyclic

    def grammar_info(self):
        def render_rule_dependencies(rule):
            return {k: ", ".join([t.attribute for t in g])
                    for k, g in itertools.groupby(rule.dependencies, lambda r: r.node)}

        def render_semantic_rule(rule):
            if isinstance(rule, SynthesizeRule):
                return f"self.{rule.name}", {
                    "dependencies": render_rule_dependencies(rule),
                    "type": "synthesized",
                    "annotations": rule.annotations,
                    "sourceLocation": {
                        "file": rule.source_location.file,
                        "line": rule.source_location.line
                    } if rule.source_location else None
                }

            if isinstance(rule, PushdownRule):
                return f"{rule.target.node}.{rule.target.attribute}", {
                    "dependencies": render_rule_dependencies(rule),
                    "type": "inherited",
                    "annotations": rule.annotations,
                    "sourceLocation": {
                        "file": rule.source_location.file,
                        "line": rule.source_location.line
                    } if rule.source_location else None
                }

            raise AttributeGrammarError("Wtf")

        return {
            **super().grammar_info(),
            "attributes": {
                "synthesized": {
                    symbol.__name__: list(attributes)
                    for symbol, attributes in self.synthesized_attributes.items()
                    if len(attributes) > 0
                },
                "inherited": {
                    symbol.__name__: list(attributes)
                    for symbol, attributes in self.inherited_attributes.items()
                    if len(attributes) > 0
                },
            },
            "semanticRules": {
                symbol.__name__: {
                    r: data
                    for _, rules2 in [*self.synthesized_rules[symbol].items(),
                                      *self.inheritable_rules[symbol].items()]
                    for rule in rules2 if len(rules2) > 0
                    for r, data in [render_semantic_rule(rule)]
                }
                for symbol in self.synthesized_rules.keys() | self.inheritable_rules.keys()
            },
        }


class AttributedTree(DerivationTree):
    grammar: AttributeGrammar

    @dataclass(frozen=True)
    class AttributedNodeInfo(DerivationTree.NodeInfo):
        resolve_node: Callable[[str], object]
        resolve_rule: Callable[[str], AttributedTree.AttributedNodeRuleInfo]

        def __getitem__(self, item):
            self.resolve_rule(item)

    @dataclass(frozen=True)
    class AttributedNodeRuleInfo:
        rule: SemanticRule
        rule_node: object
        node_dependencies: Dict[str, object]
        attribute_dependencies: List[Tuple[object, str]]

    def __getitem__(self, item):
        return self.AttributedNodeInfo(
            self.grammar,
            self.node_context[item],
            partial(self.resolve_node, item),
            partial(self.resolve_rule, item))

    def _select_rule_overload(self, rules: List[SemanticRule], node):
        rules = [r for r in rules if r.matches(node)]

        rules.sort()

        return rules[0]

    def resolve_rule(self, node, attribute=...):
        if attribute is ...:
            node, attribute = node

        production = self.grammar.production_of(node)

        node_context = self.node_context[node]
        node_rules = self.node_rules[node]

        if attribute not in node_rules:
            if node_context.is_root:
                return None

            available_attributes = self.grammar.synthesized_attributes[production] | \
                                   self.grammar.inherited_attributes[production]

            if attribute not in available_attributes:
                return None

            raise AttributeGrammarError(
                f"Semantic rule for attribute '{attribute}' of production "
                f"'{production}' could not be found.")

        if attribute in self.grammar.synthesized_attributes[production]:
            rule_node = node
            rule_node_production = production

        elif attribute in self.grammar.inherited_attributes[production]:
            if not node_context.in_array:
                rule_node = node_context.ancestor
            elif node_context.is_head:
                rule_node = node_context.ancestor
            else:
                rule_node = node_context.array_previous

            rule_node_production = self.grammar.production_of(rule_node)
        else:
            raise RuntimeError

        try:
            rule = self._select_rule_overload(node_rules[attribute], rule_node)
        except Exception:
            debug_info = node_rules[attribute]
            debug_info = "\n\t".join([f"{b} \t {b.arguments}" for b in debug_info])

            raise AttributeGrammarError(f"Could not find rule for {attribute} "
                                        f"in node {type(node)} \n\t{debug_info}")

        node_dependencies = {c.node: self.resolve_node(rule_node, c.node, rule_node_production) for c in rule.arguments}

        attribute_dependencies = [
            (n, a)
            for c, a in rule.dependencies
            for n in (node_dependencies[c] if isinstance(node_dependencies[c], list) else
                      [node_dependencies[c]]) if
            n is not None]

        return self.AttributedNodeRuleInfo(
            rule,
            rule_node,
            node_dependencies,
            attribute_dependencies)

    @property
    @lru_cache(None)
    def node_rules(self):
        grammar = self.grammar
        rule_map = {}

        def add_rules(node, _, context):
            rules = {}

            node_type = self.grammar.production_of(node)

            for attr in grammar.synthesized_attributes[node_type]:
                rules[attr] = grammar.synthesized_rules[node_type][("self", attr)]

            for attr in grammar.inherited_attributes[node_type]:
                if context.is_root:
                    continue

                ancestor_type = self.grammar.production_of(context.ancestor)
                rules[attr] = grammar.inheritable_rules[ancestor_type][(context.name, attr)]

                if context.in_array:
                    if not context.is_head:
                        predecessor_type = self.get_list_type(ancestor_type, context.name)
                        rules[attr] = grammar.inheritable_rules[predecessor_type][("next", attr)]

            rule_map[node] = rules

        self.visit(add_rules)

        return rule_map

    @lru_cache(None)
    def get_list_type(self, ancestor_type, name):
        return ListElement[ancestor_type, name]


class __ListElement:
    @lru_cache(None)
    def __getitem__(self, item):
        parent, child_name = item

        def get_contained_type(grammar: Grammar):
            return grammar.productions[parent][child_name].symbol

        return production(type("ListElement" + parent.__name__ + child_name, (), {
            "get_contained_type": get_contained_type
        }))


ListElement = __ListElement()


@dataclass(frozen=True)
class RuleArgument:
    node: str
    types: Set[type] = field(default=None)


class SemanticRule:
    def __init__(self, func, arguments, dependencies, name, source_location, annotations):
        self.func = func
        self.name = name
        self.arguments: List[RuleArgument] = arguments
        self.dependencies = dependencies
        self.source_location = source_location
        self.annotations = annotations

    def matches(self, node):
        for arg in self.arguments:
            if arg.node == "self":
                continue

            val = getattr(node, arg.node, None)
            tpe = set([None] if val is None else type(val).mro())

            if arg.types is not None:
                if val.__class__ in (list, tuple):
                    raise NotImplementedError

                if arg.types.isdisjoint(tpe):
                    return False

        return True


class SynthesizeRule(SemanticRule):
    def __init__(self, func, arguments, dependencies, name, source_location=None, annotations=None, target=None):
        super().__init__(func, arguments, dependencies, name, source_location, annotations)
        self.target = ("self", target or name)

    def __repr__(self):
        if self.source_location:
            file, line = self.source_location
            return f"SynthesizeRule {self.name} (File \"{file}\", line {line})"
        else:
            return f"SynthesizeRule {self.name}" + (f" ({self.annotations})" if self.annotations else "")


class PushdownRule(SemanticRule):
    def __init__(self, func, arguments, dependencies, target, name, source_location=None, annotations=None):
        super().__init__(func, arguments, dependencies, name, source_location, annotations)

        self.target = target

    def __repr__(self):
        if self.source_location:
            file, line = self.source_location
            return f"PushdownRule {self.name} (File \"{file}\", line {line})"
        else:
            return f"PushdownRule {self.name}" + (f" ({self.annotations})" if self.annotations else "")


class AttributeGrammarError(Exception):
    pass


class AttributeGrammarValidationError(AttributeGrammarError):
    pass


class AttributeVisitor:
    def __init__(self, attribute_grammar):
        self.attribute_grammar: AttributeGrammar = attribute_grammar

    def visit(self, root, function):
        def traverse_attributes(node, _, __):
            symbol = self.attribute_grammar.production_of(node)
            attributes = self.attribute_grammar.attributes[symbol]

            for attribute in attributes:
                function(node, attribute)

        self.attribute_grammar.traverse(root, traverse_attributes)
