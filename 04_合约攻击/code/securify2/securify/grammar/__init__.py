from __future__ import annotations

from collections.abc import Sequence
from copy import deepcopy
from dataclasses import dataclass
from enum import Flag, auto
from functools import lru_cache
from inspect import getmro, getmembers, isclass
from typing import _GenericAlias, Union, get_type_hints, Dict, Set, Optional, Any, List, Iterable, TypeVar, Type, \
    Generator, Iterator


class Grammar:
    def __init__(self, classes, **kwargs):
        productions = set(classes)

        for p in productions:
            if not Production.is_production(p):
                raise GrammarError(
                    f"Class {p.__name__} is not a production. "
                    f"Please use the @production or @abstract_production decorator.")

        self.productions_by_name: Dict[str, type] = {c.__name__: c for c in productions}

        self.super_productions: Dict[type, List[type]] = {
            c: [t for t in getmro(c) if t in productions if t != c]
            for c in productions
        }

        self.sub_productions: Dict[type, Set[type]] = {
            c: {t for t in get_all_subclasses(c) if t in productions if t != c}
            for c in productions
        }

        self.productions: Dict[type, Dict[str, ProductionChildInfo]] = {
            cls: ProductionInfo.from_class(cls).children for cls in productions
        }

        self.validate_grammar()

    @property
    @lru_cache(None)
    def starting_productions(self):
        outputs = {
            production_type
            for p1 in self.productions.values()
            for p2 in p1.values()
            for production_type in self.get_sub_productions(p2.symbol)}

        return set.difference(set(self.productions.keys()), outputs)

    def visitor(self):
        return ProductionVisitor(self)

    def traverse(self, root, action):
        return self.visitor().visit(root, action)

    def children_of(self, node):
        return self.productions[self.production_of(node)]

    @lru_cache(None)
    def _production_of_cached(self, node_cls):
        for cls in node_cls.mro():
            if cls in self.productions:
                return cls
        return None

    def production_of(self, node, default=...):
        node_cls = node if isinstance(node, type) else type(node)
        prod = self._production_of_cached(node_cls)

        if prod or default is not ...:
            return prod or default

        raise GrammarError(f"Could not find production for '{node}'")

    # region Validation
    def validate_grammar(self):
        pass

    def validate_tree(self, root):
        self.visitor().visit(root, lambda n, a, c: self.validate_node(n))
        return True

    def validate_node(self, node):
        if node is None:
            return True

        production = self.production_of(node)

        for child_name, child_properties in self.productions[production].items():
            child = getattr(node, child_name, None)
            child_properties.validate_child(child)

        return True

    # endregion

    def get_sub_productions(self, production):
        if not isinstance(production, Iterable):
            productions = {production}
        else:
            productions = production

        return set(productions) | {
            ss
            for s in productions if s is not None  # (s, type(None))
            for ss in self.sub_productions[s]
        }

    def grammar_info(self):
        return {
            "productions": {
                prod.__name__: {
                    n: t.to_string()
                    for n, t in children.items()
                } for prod, children in self.productions.items()
            },
            "superProductions": {
                p.__name__: ", ".join(q.__name__ for q in pt)
                for p, pt in self.super_productions.items() if len(pt) > 0
            },
            "subProductions": {
                p.__name__: ", ".join(q.__name__ for q in pt)
                for p, pt in self.sub_productions.items() if len(pt) > 0
            },
        }

    @classmethod
    def from_modules(cls, *modules, base_class=None, **kwargs):
        classes = [c for m in modules for _, c in getmembers(m, isclass)]
        classes = [c for c in classes if Production.is_production(c)]

        if base_class is not None:
            classes = [c for c in classes if issubclass(c, base_class)]

        return cls(classes, **kwargs)


class ProductionVisitor:
    def __init__(self, grammar):
        self.grammar = grammar

    def visit(self, node, action, ancestor=None, ancestor_set=None, context_info=None, post_order=False):
        context_info = context_info or ContextInfo.root()
        ancestor_set = ancestor_set or set()

        if node in ancestor_set:
            raise GrammarError(f"Found cycle in derivation tree at node {node} of type {type(node)}")

        if not post_order:
            action(node, ancestor, context_info)

        for child, context in self.iterate_children(node):
            self.visit(child, action, context.ancestor, ancestor_set | {node}, context, post_order)

        if post_order:
            action(node, ancestor, context_info or ContextInfo.root())

    def transform(self, root, transformer):
        root = deepcopy(root)
        grammar = self.grammar

        def override_node(context_info, new_node):
            if not context_info.is_root:
                if context_info.array:
                    context_info.array[context_info.index] = new_node
                else:
                    setattr(context_info.ancestor, context_info.name, new_node)
                grammar.validate_node(context_info.ancestor)

        def transform(node, ancestor_set, context_info):
            context_info = context_info or ContextInfo.root()

            if node in ancestor_set:
                raise GrammarError(f"Found cycle in derivation tree at node {node} of type {type(node)}")

            new_node = transformer(node, context_info)

            if new_node and new_node != node:
                grammar.validate_node(new_node)
                override_node(context_info, new_node)
                node = new_node

            for child, context in self.iterate_children(node):
                transform(child, ancestor_set | {node}, context)

            return node

        return transform(root, set(), None)

    def iterate_children(self, node):
        if node is None:
            return

        local_productions = self.grammar.productions[self.grammar.production_of(node)]
        for production_name, production_type in local_productions.items():
            production = getattr(node, production_name, None)

            if production is None:
                if not production_type.is_node_optional:
                    raise GrammarError(f"Unexpected missing child '{production_name}' "
                                       f"in '{type(node).__name__}'.")
                continue

            if production_type.is_list:
                for i, p in enumerate(production):
                    if p is not None:
                        yield p, ContextInfo(node, production, i, production_name)
            else:
                yield production, ContextInfo(node, None, None, production_name)

    def iterate_children_recursively(self, node, post_order=False):
        if not post_order:
            yield node

        for c, _ in self.iterate_children(node):
            yield from self.iterate_children_recursively(c)

        if post_order:
            yield node

    def find_descendants_of_type(self, node, types, post_order=False):
        yield from (n for n
                    in self.iterate_children_recursively(node, post_order)
                    if isinstance(n, types))

    def find_descendant_of_type(self, node, types, post_order=False):
        try:
            return next(self.find_descendants_of_type(node, types, post_order))
        except StopIteration:
            return None

    def build_mapping(self, root, mapper):
        result = {}

        def add(node, *args):
            result[node] = mapper(node, *args)

        self.visit(root, add)

        return result

    def build_mapping_inverse(self, root, key):
        result = {}

        def add(node, *args):
            result[key(node, *args)] = node

        self.visit(root, add)

        return result


class GrammarError(Exception):
    pass


class Production(type):
    @staticmethod
    def is_production(cls):
        return getattr(cls, "__is_production", False)

    @staticmethod
    def is_abstract(cls):
        return getattr(cls, "__is_abstract_production")


def abstract_production(cls):
    return __make_production(cls, **{
        "__is_abstract_production": True,
        "__is_production": True
    })


def production(cls):
    return __make_production(cls, **{
        "__is_abstract_production": False,
        "__is_production": True,
    })


T = TypeVar("T")


class ProductionOps:

    def production_info(self) -> ProductionInfo:
        return getattr(self, "__production")

    def root(self):
        return getattr(self, "__root", None)

    def parent(self):
        return getattr(self, "__parent", None)

    def children(self):
        children_info = self.production_info().children
        for name in children_info:
            child = getattr(self, name)

            if child is None:
                continue

            for c in child if children_info[name].is_list else [child]:
                yield c

    def descendants(self):
        for child in ProductionOps.children(self):
            yield child

            if child is not None:
                yield from ProductionOps.descendants(child)

    def ancestors(self):
        ancestor = ProductionOps.parent(self)
        while ancestor is not None:
            yield ancestor
            ancestor = ProductionOps.parent(ancestor)

    def find_ancestor_of_type(self, types: Type[T]) -> Optional[T]:
        for ancestor in self.ancestors():
            if isinstance(ancestor, types):
                return ancestor

    def find_descendants_of_type(self, types: Type[T]) -> Iterator[T]:
        for descendant in self.descendants():
            if isinstance(descendant, types):
                yield descendant

    def find_children_of_type(self, types: Type[T]) -> Iterator[T]:
        for child in self.children():
            if isinstance(child, types):
                yield child


def __make_production(cls, *bases, **kwargs):
    # TODO: Use proper metaclasses when this issue
    #  https://bugs.python.org/issue29944 is fixed

    if len(bases) > 0:
        return Production(cls.__name__, (cls, *bases), kwargs)

    def set_context(self, parent):
        setattr(self, "__parent", parent)
        setattr(self, "__root_node__", parent.__root)

    def get_root(node):
        while node.__parent is not None:
            node = node.__parent

        return node

    def __setattr__(self, name, value):
        production_info: ProductionInfo = self.__production
        if name in production_info.children:
            child_info = production_info.children[name]
            child_info.validate_child(value)

            if isinstance(value, list):
                for val in value:
                    if val is not None:
                        set_context(val, self)
            elif value is not None:
                set_context(value, self)

        super(cls, self).__setattr__(name, value)

    # noinspection PyPep8Naming,SpellCheckingInspection
    class classproperty(object):
        def __init__(self, getter):
            self.getter = getter

        def __get__(self, instance, owner):
            return self.getter(owner)

    __production = classproperty(lru_cache(1)(lambda _: ProductionInfo.from_class(cls)))
    __root = property(get_root)

    kwargs = {
        "__setattr__": __setattr__,
        "__production": __production,
        "__root": __root,
        "__parent": None,
        **kwargs
    }

    for k, v in kwargs.items():
        setattr(cls, k, v)

    return cls


@dataclass
class NodeInfo:
    pass


@dataclass
class ProductionInfo:
    children: Dict[str, ProductionChildInfo]

    @staticmethod
    def from_class(production_rule):
        children = {}
        production_name = production_rule.__name__

        try:
            type_hints = get_type_hints(production_rule)
        except NameError or TypeError as e:
            raise GrammarError(f"Production class {production_name} could not be processed.") from e

        for name, annotation in type_hints.items():
            try:
                child_info = ProductionChildInfo.from_type_hint(annotation, production_name, name)

                if child_info is not None:
                    if Production.is_production(child_info.symbol):
                        children[name] = child_info

            except GrammarError as e:
                raise GrammarError(f"Production class {production_name} could not process child {name}.") from e

        return ProductionInfo(children)


class ProductionChildArity(Flag):
    LIST = auto()
    LIST_OPTIONAL = auto()
    SINGLE = auto()


@dataclass(frozen=True)
class ProductionChildInfo:
    child_name: str
    production_name: str

    symbol: type
    symbol_optional: bool
    arity: ProductionChildArity
    annotation: Any

    def validate_child(self, child):
        def error(msg):
            raise GrammarError(msg)

        if child is None:
            if not self.is_node_optional:
                error(f"Expected child '{child}' in node of type '{self.production_name}'."
                      f"Consider using the 'Optional[T]' type annotation.")
        else:
            is_sequence = isinstance(child, (list, tuple, Sequence))

            if is_sequence and not self.is_list:
                error(f"Unexpected sequence-like field '{self.child_name}' in node of type '{self.production_name}'."
                      f"Consider using the 'Sequence[T]' type annotation.")

            if not is_sequence and self.is_list:
                error(f"Expected sequence-like field '{self.child_name}' but got single node value "
                      f"in node of type '{self.production_name}'.")

            for e in child if is_sequence else [child]:
                possible_types = {self.symbol}
                possible_types |= {type(None)} if self.symbol_optional else set()
                child_type_name = type(e).__name__
                child_type_names = [c.__name__ for c in possible_types]
                types_invalid = [not isinstance(e, c) for c in possible_types]

                if all(types_invalid):
                    error(f"Expected child of type in {child_type_names} "
                          f"but got '{child_type_name}' in "
                          f"node of type '{self.production_name}'.")

                if e is not None and Production.is_abstract(type(e)):
                    error(f"Found instance of abstract production {type(e).__name__}.")

    @property
    def is_list(self):
        return self.arity in {ProductionChildArity.LIST, ProductionChildArity.LIST_OPTIONAL}

    @property
    def is_node_optional(self):
        return self.arity is ProductionChildArity.LIST_OPTIONAL or self.symbol_optional

    def to_string(self):
        result = self.symbol.__name__
        result = f"{result}?" if self.symbol_optional else result
        result = f"({result})*" if self.arity is ProductionChildArity.LIST else result
        result = f"(({result})*)?" if self.arity is ProductionChildArity.LIST_OPTIONAL else result
        return result

    def __str__(self) -> str:
        return "[RuleOutput: %s]" % self.to_string()

    @staticmethod
    def from_type_hint(type_hint, production_name, child_name):
        symbol = None
        modifiers = []

        type_hint_element = type_hint

        while symbol is None:
            if isinstance(type_hint_element, _GenericAlias):
                type_params = type_hint_element.__args__
                annotation_type = type_hint_element.__origin__

                if annotation_type in [Sequence, list, tuple]:
                    modifiers.append("list")
                    type_hint_element = type_params[0]
                elif annotation_type is Union:
                    if not (len(type_params) == 2 and type(None) in type_params):
                        return None

                    modifiers.append("opt")
                    type_hint_element, *_ = {t for t in type_params if t is not type(None)}

                else:
                    return None

            elif Production.is_production(type_hint_element):
                symbol = type_hint_element

            else:  # Not supported
                return None

        def constructor(*args):
            return ProductionChildInfo(child_name, production_name, symbol, *args)

        if not modifiers:
            info = constructor(False, ProductionChildArity.SINGLE, type_hint)
        elif modifiers == ["opt"]:
            info = constructor(True, ProductionChildArity.SINGLE, type_hint)
        elif modifiers == ["list"]:
            info = constructor(False, ProductionChildArity.LIST, type_hint)
        elif modifiers == ["list", "opt"]:
            info = constructor(True, ProductionChildArity.LIST, type_hint)
        elif modifiers == ["opt", "list"]:
            info = constructor(False, ProductionChildArity.LIST_OPTIONAL, type_hint)
        elif modifiers == ["opt", "list", "opt"]:
            info = constructor(True, ProductionChildArity.LIST_OPTIONAL, type_hint)
        else:
            raise RuntimeError()

        return info


@dataclass(frozen=True)
class ContextInfo:
    ancestor: object
    array: Optional[list]
    index: Optional[int]
    name: Optional[str]

    @property
    def is_root(self):
        return self.ancestor is None

    @property
    def is_head(self):
        return self.in_array and self.index == 0

    @property
    def is_last(self):
        return self.in_array and self.index == len(self.array) - 1

    @property
    def in_array(self):
        return self.array is not None

    @property
    def array_previous(self):
        if not self.in_array or self.is_head:
            return None
        return getattr(self.ancestor, self.name)[self.index - 1]

    @property
    def array_next(self):
        if not self.in_array or self.is_last:
            return None
        return getattr(self.ancestor, self.name)[self.index + 1]

    @staticmethod
    def root():
        return ContextInfo(None, None, None, None)


class DerivationTree:
    @dataclass(frozen=True)
    class NodeInfo:
        grammar: Grammar
        context: ContextInfo

    def __init__(self, grammar, root):
        self.grammar = grammar
        self.root = root

    def __getitem__(self, item):
        return self.NodeInfo(grammar=self.grammar,
                             context=self.node_context[item])

    def visit(self, function, **kwargs):
        return ProductionVisitor(self.grammar).visit(self.root, function, **kwargs)

    def build_mapping(self, function):
        return ProductionVisitor(self.grammar).build_mapping(self.root, function)

    def resolve_node(self, base, requested, production=None):
        """Resolves a node by name relative to the specified base."""
        if requested == "self":
            return base
        else:
            if requested not in self.grammar.productions[production or self.grammar.production_of(base)]:
                raise AttributeError(f"Semantic rule references non-existent child node '{requested}'.")

            if not hasattr(base, requested):
                raise AttributeError(f"Semantic rule references unavailable child node '{requested}'.")

            return getattr(base, requested, None)

    @property
    @lru_cache(None)
    def node_context(self) -> Dict[object, ContextInfo]:
        return self.build_mapping(lambda n, _, c: c)


def get_all_subclasses(cls):
    all_subclasses = []

    for subclass in cls.__subclasses__():
        all_subclasses.append(subclass)
        all_subclasses.extend(get_all_subclasses(subclass))

    return all_subclasses
