import ast
import dataclasses
import inspect
import typing
from abc import ABC, abstractmethod
from ast import Set, Dict, Tuple
from collections import defaultdict
from contextlib import contextmanager
from dataclasses import dataclass
from functools import lru_cache, singledispatch
from inspect import getmembers
from types import FunctionType
from typing import List, Callable

from securify.grammar import Grammar, Production
from securify.grammar.attributes import AttributeGrammarError, AttributeOccurrence, RuleArgument, ListElement
from securify.grammar.attributes import SynthesizeRule, PushdownRule

T = typing.TypeVar("T")


class RuleParser(ABC):
    @abstractmethod
    def __call__(self, grammar, classes):
        ...


"""
Definition of Attributes:

attr1 = synthesized()
attr2 = inherited()


Definition of Rules
@synthesized
def any_name(self) -> attribute: 
    ...

@synthesized
def attribute(self): 
    ...

@pushdown
def any_name(self) -> Attribute @ child:
    ....


Attributes and rules inherited via over python's class hierarchy mechanism.



"""


class _AttributeBase:
    name: str

    def __init__(self, source_location=None):
        self.source_location = source_location or SourceLocation.current(1)

    def __get__(self, instance, owner):
        if instance is None:
            return self

        raise AttributeGrammarError(
            f"Attributes cannot be accessed directly without prior evaluation. "
            f"Use an evaluator. ({self} in {self.owner.__name__}, {self.source_location})")

    def __set_name__(self, owner, name):
        self.__name__ = name
        self.name = name
        self.owner = owner


class SynthesizedAttribute(_AttributeBase):
    def __init__(self, default, source_location=None):
        super().__init__(source_location)
        self.default = default

    def __repr__(self):
        return f"Syn({self.name})"


class InheritedAttribute(_AttributeBase):
    def __init__(self, default, implicit_pushdown, source_location=None):
        super().__init__(source_location)
        self.default = default
        self.implicit_pushdown = implicit_pushdown

    def __repr__(self):
        return f"Inh({self.name})"


class AttributeDefinitionError(AttributeGrammarError):
    pass


class AllChildrenTarget:
    pass


All = AllChildrenTarget()


class Parser(RuleParser):
    class ParsingHelper:
        def __init__(self, grammar: Grammar):
            self.grammar = grammar
            self.a_s: Dict[type, Set[_AttributeBase]] = defaultdict(lambda: set())
            self.a_i: Dict[type, Set[_AttributeBase]] = defaultdict(lambda: set())
            self.r_s: Dict[type, Dict[Tuple[str, str], List[SynthesizeRule]]] = defaultdict(lambda: defaultdict(list))
            self.r_i: Dict[type, Dict[Tuple[str, str], List[PushdownRule]]] = defaultdict(lambda: defaultdict(list))

            for production in grammar.productions:
                for cls in production.mro():
                    self.sort_rules(cls)

            # Set owner in rules
            for production in grammar.productions:
                for cls in production.mro():
                    self.prepare_attributes(cls)
                    self.prepare_rules(cls)

            self.register_attributes()
            self.register_rules()

        def register_attributes(self):
            for production in self.grammar.productions:
                # if self.grammar.is_abstract_production(production):
                #     self.a_s[production] = set()
                #     self.a_i[production] = set()
                #     self.a_a[production] = set()
                #     continue

                self.a_s[production] = self.synthesized_attributes(production)
                self.a_i[production] = self.inherited_attributes(production)

        def register_rules(self):
            for production in self.grammar.productions:
                if Production.is_abstract(production):
                    continue

                for r in self.synthesized_rules(production):
                    assert isinstance(r.attribute, SynthesizedAttribute)
                for r in self.pushdown_rules(production):
                    assert isinstance(r.attribute, InheritedAttribute)

                for attribute in self.a_s[production]:
                    self.r_s[production][("self", attribute.name)] = [
                        self.synthesized_rule(production, attribute)
                    ]

                for name, child in self.grammar.productions[production].items():
                    for attribute in self.inherited_attributes(child.symbol):
                        self.r_i[production][(name, attribute.name)] = [
                            self.pushdown_rule(production, name, attribute)
                        ]

                    if child.is_list:
                        production_list = ListElement[production, name]
                        for attribute in self.inherited_attributes(child.symbol):
                            self.r_i[production_list][("next", attribute.name)] = [
                                self.pushdown_rule(production_list, "next", attribute)
                            ]

        @property
        def result(self):
            return (
                self.r_s, self.r_i,
                {i: frozenset(a.name for a in t) for i, t in self.a_s.items()},
                {i: frozenset(a.name for a in t) for i, t in self.a_i.items()},
            )

        def attributes_in_production_child(self, production, child):
            if child == "self":
                return self.all_attributes(production)

            production_info = self.grammar.productions[production]
            child_type = production_info[child].symbol

            return self.all_attributes(child_type)

        def synthesized_attributes(self, production):
            return self.attribute_declarations(production)[0]

        def inherited_attributes(self, production):
            return self.attribute_declarations(production)[1]

        def all_attributes(self, production):
            return self.synthesized_attributes(production) | self.inherited_attributes(production)

        @lru_cache(None)
        def attribute_declarations(self, production):
            if production is None:
                return set(), set()

            syn = getmembers(production, lambda x: isinstance(x, SynthesizedAttribute))
            inh = getmembers(production, lambda x: isinstance(x, InheritedAttribute))

            for super_production in self.grammar.super_productions[production]:
                if super_production in self.grammar.starting_productions:
                    continue

                for i_name, i_attr in inh:
                    if getattr(super_production, i_name, None) != i_attr:
                        raise AttributeDefinitionError(
                            f"Inherited attribute {i_attr} defined in production "
                            f"'{production.__name__}' must also be available in its "
                            f"super production '{super_production.__name__}'. "
                            f"Alternatively '{super_production.__name__}' must be a "
                            f"start production. {i_attr.source_location}")

            syn = set(a for _, a in syn)
            inh = set(a for _, a in inh)

            parent_attributes = set()
            for super_production in self.grammar.super_productions[production]:
                parent_attributes_new = self.attribute_declarations(super_production)
                if parent_attributes_new is None:
                    parent_attributes |= parent_attributes_new[0]
                    parent_attributes |= parent_attributes_new[1]

            local_attributes = (syn | inh)

            if not parent_attributes.issubset(local_attributes):
                raise AttributeGrammarError(local_attributes, parent_attributes)

            return syn, inh

        @lru_cache(None)
        def synthesized_rules(self, production):
            rules = [p.__dict__.get("__semantic_rules", []) for p in production.mro()]
            rules = [r for rs in rules for r in reversed(rs) if isinstance(r, SynthesizeRuleDescriptor)]
            return rules

        @lru_cache(None)
        def pushdown_rules(self, production):
            if "ListElement" in production.__name__:
                ttt = production.get_contained_type(self.grammar)
                rules = [p.__dict__.get("__semantic_rules", []) for p in (production.mro() + ttt.mro())]
            else:
                rules = [p.__dict__.get("__semantic_rules", []) for p in production.mro()]

            rules = [r for rs in rules for r in reversed(rs) if isinstance(r, PushdownRuleDescriptor)]
            return rules

        def synthesized_rule(self, production, attribute):
            rules: List[SynthesizeRuleDescriptor] = self.synthesized_rules(production)

            for r in rules:
                if r.attribute == attribute:
                    return r.to_rule(self, production)

            if attribute.default is not ...:
                return self.default_synthesized(attribute)

            error = (f"Could not find rule for attribute {attribute} in "
                     f"production {production.__name__}. {attribute.source_location} ")

            if attribute.default is ...:
                error += "A default value has not been provided. "

            raise AttributeDefinitionError(error + f"\n{attribute.source_location}")

        def pushdown_rule(self, production, child, attribute):
            rules = self.pushdown_rules(production)

            for r in rules:
                if r.attribute == attribute and r.is_in_targets(child):
                    return r.to_rule(self, production, child)

            if "ListElement" in production.__name__:
                production = production.get_contained_type(self.grammar)

            # No rule found, try implicit rule inferrence
            if attribute.implicit_pushdown:
                available_attributes = {a.name: a for a in self.a_i[production]}

                if attribute.name in available_attributes:
                    source = available_attributes[attribute.name]
                    return self.implicit_pushdown(child, source, attribute)

            if attribute.default is not ...:
                return self.default_pushdown(child, attribute)

            error = (f"Could not find rule for attribute {attribute} for child "
                     f"'{child}' production '{production.__name__};. ")

            if attribute.default is ...:
                error += "A default value has not been provided. "
            if attribute.implicit_pushdown:
                error += "An implicit or default pushdown could not be inferred either. "
            else:
                error += "Implicit pushdown has been disabled explicitly. "

            raise AttributeDefinitionError(error + f"\n{attribute.source_location}")

        @staticmethod
        def prepare_attributes(cls):
            for name, attr in getmembers(cls, lambda x: isinstance(x, _AttributeBase)):
                if getattr(attr, "owner", None) is None:
                    attr.__set_name__(cls, name)
                elif attr.name != name:
                    raise AttributeDefinitionError(
                        f"Attribute {attr} was renamed in class '{cls.__name__}' "
                        f"from {attr.name} to {name}.")

        @staticmethod
        def prepare_rules(cls):
            for r in getattr(cls, "__semantic_rules", []):
                r._set_owner(cls)

        @staticmethod
        def sort_rules(cls):
            reorder = []
            semantic_rules: list = getattr(cls, "__semantic_rules", [])
            for r in semantic_rules:
                arguments = r.arguments[1]
                arguments = [a for a in arguments if a.node == "self"]

                if len(arguments) == 0:
                    continue
                arguments = arguments[0]
                if arguments.types is not None:
                    reorder.append((r, arguments.types))

            for rule, types in reorder:
                semantic_rules.remove(rule)
                for cls_other in types:
                    _rules(cls_other).append(rule)

        @staticmethod
        def implicit_pushdown(child_name, attribute_source, attribute_target):
            return PushdownRule(
                Parser.ParsingHelper.implicit_pushdown_impl(attribute_target.name),
                arguments=[RuleArgument("self")],
                dependencies=[AttributeOccurrence("self", attribute_source.name)],
                target=AttributeOccurrence(child_name, attribute_target.name),
                name=f"{child_name}_{attribute_target.name}",
                annotations="ImplicitPushdown"
            )

        @staticmethod
        def default_pushdown(child_name, attribute_target):
            return PushdownRule(
                Parser.ParsingHelper.default_value_impl(attribute_target.default),
                arguments=[RuleArgument("self")],
                dependencies=[],
                target=AttributeOccurrence(child_name, attribute_target.name),
                name=f"{child_name}_{attribute_target.name}",
                annotations="DefaultPushdown"
            )

        @staticmethod
        def default_synthesized(attribute_target):
            return SynthesizeRule(
                Parser.ParsingHelper.default_value_impl(attribute_target.default),
                arguments=[RuleArgument("self")],
                dependencies=[],
                target=AttributeOccurrence("self", attribute_target.name),
                name=f"{attribute_target.name}",
                annotations="DefaultSynthesized"
            )

        @staticmethod
        def implicit_pushdown_impl(attribute):
            def identity(self):
                return getattr(self, attribute)

            return identity

        @staticmethod
        def default_value_impl(value):
            def default_value(self):
                if isinstance(value, Callable):
                    return value()
                return value

            return default_value

    def __call__(self, grammar, _):
        return self.ParsingHelper(grammar).result


def _rules(d):
    field = "__semantic_rules"
    if isinstance(d, type):
        if field not in d.__dict__:
            setattr(d, field, [])
        return d.__dict__[field]

    if not isinstance(d, dict):
        raise RuntimeError(type(d))

    return d.setdefault(field, [])


def __set_rule(rule, cls=None):
    # Registers a rule in the '__semantic_rules' field of cls.

    # If None is passed via cls, it is assumed that the __set_rule
    # function was called from within a class definition block. In
    # order to prevent shadowing of already declared attributes or
    # rules with identical names, the function traverses the stack
    # of frames in order to find the namespace of the class it has
    # been called from. It then looks for fields whose names match
    # the rule's name and returns their value, if found. The value
    # can be returned by a decorator so that the existing field is
    # effectively not overridden by the new definition.
    if cls is not None:
        _rules(cls).append(rule)
    else:
        class_locals = __class_locals()

        if class_locals is None:
            raise AttributeGrammarError(
                f"Rule definition of {rule} is not applicable outside of a class. \n"
                f"If defining rules outside of a class, please pass the target class "
                f"as first parameter (e.g. @synthesized(MyClass), @inherited(MyClass))."
            )

        _rules(class_locals).append(rule)

        if rule.function_name in class_locals:
            return class_locals[rule.function_name]

    return rule


@contextmanager
def rules_for(production: T) -> T:
    assert getattr(rules_for, "__current_rule__", None) is None

    try:
        productions = production if isinstance(production, list) else [production]

        for production in productions:
            if not Production.is_production(production):
                raise AttributeDefinitionError(f"{production} is not a production rule.")

        setattr(rules_for, "__current_rule__", productions)
        yield production
    finally:
        delattr(rules_for, "__current_rule__")


def synthesized(*args, default=...):
    if len(args) == 0:
        return SynthesizedAttribute(source_location=SourceLocation.current(),
                                    default=default)

    if len(args) == 1:
        arg = args[0]

        if isinstance(arg, FunctionType):
            rule = SynthesizeRuleDescriptor(arg)

            if __is_in_class_declaration():
                return __set_rule(rule, cls=None)

            if __is_in_class_context():
                for t in __context_classes():
                    __set_rule(rule, cls=t)

                return rule

    raise AttributeDefinitionError(f"Unsupported arguments {args} at {SourceLocation.current()}")


def inherited(*, default=..., implicit_pushdown=...):
    return InheritedAttribute(default,
                              implicit_pushdown,
                              source_location=SourceLocation.current())


def pushdown(*args):
    if len(args) == 1:
        arg = args[0]

        if isinstance(arg, FunctionType):
            rule = PushdownRuleDescriptor(arg)

            if __is_in_class_declaration():
                return __set_rule(rule, cls=None)

            if __is_in_class_context():
                for t in __context_classes():
                    __set_rule(rule, cls=t)

                return rule

    raise AttributeDefinitionError(f"Unsupported arguments {args} at {SourceLocation.current()}")


class _SemanticRuleDescriptor(ABC):
    def __init__(self, function):
        self.function = function
        self.function_name = function.__name__

        self.name = self.function_name
        self.source_location = SourceLocation.for_function(function)

    def __set_name__(self, owner, name):
        # Rules are not stored as attributes of a class, instead they are stored
        # in a dedicated array called '__semantic_rules'. The reason for this is
        # to make it possible to define rules with the names of their respective
        # attributes without shadowing them if they are in a base class.
        delattr(owner, name)

    def _set_owner(self, owner):
        self.owner = owner

    def __get__(self, instance, owner):
        if instance is None:
            return self

        raise RuntimeError(
            f"Semantic rule descriptors cannot not be accessible directly. "
            f"The rule was probably defined via assigment to a class attribute "
            f"at which is not supported. "
            f"({self.name} in {self.owner.__name__}, {self.source_location})")

    def __repr__(self):
        return f"SemanticRule '{self.name}' at {self.source_location}"

    @property
    @abstractmethod
    def attribute(self):
        ...

    @property
    def arguments(self):
        return _parse_dependencies(self)

    @property
    @lru_cache(None)
    def _target(self):
        func = self.function
        if "return" not in func.__annotations__:
            return None

        try:
            return ast.parse(func.__annotations__["return"], mode='eval').body
        except Exception as e:
            raise AttributeDefinitionError(
                f"Attribute targets could not be parsed for {self}.") from e

    def _parse_dependencies(self, parser_helper, production):
        if "ListElement" in production.__name__:
            production = production.get_contained_type(parser_helper.grammar)

        dependencies, dependencies_on_nodes = _parse_dependencies(self)
        dependencies_on_nodes = self._with_sub_productions(parser_helper.grammar, dependencies_on_nodes)

        accesses, _ = _parse_function_ast(self.function)

        dependencies = set(dependencies)
        dependencies |= {AttributeOccurrence(d.node, a)
                         for d in dependencies_on_nodes
                         for a in accesses.get(d.node, set()) & {
                             t.name for t in parser_helper.attributes_in_production_child(production, d.node)
                         }}

        return dependencies_on_nodes, list(dependencies)

    @staticmethod
    def _with_sub_productions(grammar, dependencies_on_nodes):
        dependencies_on_nodes_new = []
        for dependency in dependencies_on_nodes:
            types = dependency.types

            if types is not None:
                types = list(types)
                for i in range(len(types)):
                    if "ListElement" in types[i].__name__:
                        types[i] = types[i].get_contained_type(grammar)
                types = set(types)

            if types is not None:
                types = grammar.get_sub_productions(types)

            dependency = dataclasses.replace(dependency, types=types)
            dependencies_on_nodes_new.append(dependency)

        return dependencies_on_nodes_new


class SynthesizeRuleDescriptor(_SemanticRuleDescriptor):
    def __init__(self, function):
        super().__init__(function)

    @property
    def attribute(self):
        if self._attribute_target is None:
            attribute = getattr(self.owner, self.function_name, None)

            if not isinstance(attribute, SynthesizedAttribute):
                raise AttributeDefinitionError(
                    f"Attribute cannot be resolved from function name for rule {self}. \n"
                    f"Please check the function name ('{self.function_name}') against "
                    f"available attributes in '{self.owner.__name__}'' or use the explict "
                    f"definition syntax 'def rule() -> MyProduction.Attribute'"
                )

            return attribute
        else:
            return self._attribute_target

    def to_rule(self, parser_helper, production):
        dependencies_on_nodes, dependencies = self._parse_dependencies(parser_helper, production)

        return SynthesizeRule(
            self.function,
            dependencies_on_nodes,
            dependencies,
            name=self.name,
            target=self.attribute.name,
            source_location=self.source_location)

    @property
    @lru_cache(None)
    def _attribute_target(self):
        if self._target is None:
            return None

        try:
            if not isinstance(self._target, (ast.Name, ast.Attribute)):
                raise AttributeDefinitionError("Unknown syntax.")

            attribute = _eval_ast(self._target, context=self.function)

        except Exception as e:
            raise AttributeDefinitionError(
                f"Rule target not specified correctly for {self}. "
                f"Expected format is 'MyProduction.MyAttribute' or 'MyAttribute'"
                f"for synthesize rules.") from e

        if not isinstance(attribute, SynthesizedAttribute):
            raise AttributeDefinitionError(
                f"Target of {self} does not resolve to an instance of SynthesizedAttribute.")

        return attribute


class PushdownRuleDescriptor(_SemanticRuleDescriptor):

    @property
    def attribute(self):
        return self._attribute_and_targets[0]

    def is_in_targets(self, child_name):
        if self._attribute_and_targets[1] == All:
            return True
        return child_name in self._attribute_and_targets[1]

    @property
    @lru_cache(None)
    def _attribute_and_targets(self):
        if self._target is None:
            raise AttributeDefinitionError(
                f"Target child and attribute not specified for {self}.")

        try:
            if not isinstance(self._target, ast.BinOp):
                raise AttributeDefinitionError("Unknown syntax.")
            if not isinstance(self._target.op, ast.MatMult):
                raise AttributeDefinitionError("Unknown syntax.")

            attribute = self._target.left
            children = self._target.right

            attribute = _eval_ast(attribute, context=self.function)

            # TODO: Assert that children are actual elements of the grammar
            if isinstance(children, ast.Name):
                if children.id == "All":
                    targets = All
                else:
                    targets = {children.id}
            elif isinstance(children, ast.Attribute):
                targets = {children.attr}
            elif isinstance(children, ast.Set):
                targets = {
                    e.attr if isinstance(e, ast.Attribute) else e.id
                    for e in children.elts
                }
            else:
                raise AttributeDefinitionError("Unknown syntax.")

        except Exception as e:
            raise AttributeDefinitionError(
                f"Rule target not specified correctly for {self}. "
                f"Expected format is 'MyProduction.MyAttribute @ {{my_child, ...}}' "
                f"for pushdown rules.") from e

        if not isinstance(attribute, InheritedAttribute):
            raise AttributeDefinitionError(
                f"Target of {self} does not resolve to an instance of InheritedAttribute.")

        return [attribute, targets]

    def to_rule(self, parser_helper, production, child):
        dependencies_on_nodes, dependencies = self._parse_dependencies(parser_helper, production)

        return PushdownRule(
            self.function,
            dependencies_on_nodes,
            dependencies,
            AttributeOccurrence(child, self.attribute.name),
            self.name,
            self.source_location)


@lru_cache(None)
def _parse_dependencies(rule):
    func = rule.function

    arguments = []
    dependencies = []

    for _, parameter in inspect.signature(func).parameters.items():
        node = parameter.name
        hint = parameter.annotation

        attributes = set()

        try:
            if hint is inspect.Signature.empty:
                dependency_type = None
            else:
                annotation_ast = ast.parse(hint, mode='eval').body

                if isinstance(annotation_ast, ast.Compare):
                    if isinstance(annotation_ast.ops[0], ast.In):
                        attr_info = _eval_ast(annotation_ast.left, context=func)
                        type_info = _eval_ast(annotation_ast.comparators[0], context=func)

                        if not isinstance(attr_info, (list, set, tuple)):
                            attr_info = {attr_info}

                        if not isinstance(type_info, (list, set, tuple)):
                            type_info = {type_info}

                        assert all(isinstance(a, _AttributeBase) for a in attr_info)
                        assert all(isinstance(a, type) for a in type_info)

                        dependency_type = type_info
                        attributes |= attr_info

                    else:
                        raise SyntaxError()

                elif isinstance(annotation_ast, (ast.Set, ast.List, ast.Tuple)):
                    attr_info = set(_eval_ast(annotation_ast, context=func))

                    assert all(isinstance(a, _AttributeBase) for a in attr_info)

                    attributes |= attr_info
                    dependency_type = None

                elif isinstance(annotation_ast, (ast.Name, ast.Attribute, ast.NameConstant, ast.Subscript)):
                    attr_or_type = _eval_ast(annotation_ast, context=func)

                    if isinstance(attr_or_type, _AttributeBase):
                        attributes.add(attr_or_type)
                        dependency_type = None
                    elif isinstance(attr_or_type, type):
                        dependency_type = {attr_or_type}
                    elif isinstance(attr_or_type, type(None)):
                        dependency_type = {None}
                    else:
                        raise Exception()

                else:
                    raise SyntaxError("Unexpected annotation AST " + str(annotation_ast))

        except Exception as e:
            raise AttributeDefinitionError(f"Attribute dependencies could not be parsed for {rule}") from e

        for attribute in set(a.name for a in attributes):
            dependency = AttributeOccurrence(node, attribute)
            dependencies.append(dependency)

        arguments.append(RuleArgument(node, dependency_type))

    return dependencies, arguments


def _parse_function_ast(func):
    source_ast = __get_function_ast(func)

    accesses = {}
    accesses_suspicious = set()

    @singledispatch
    def walk_ast(_):
        ...

    @walk_ast.register(list)
    def _(elements):
        for e in elements:
            walk_ast(e)

    @walk_ast.register(ast.Name)
    def _(name):
        accesses_suspicious.add(name)

    @walk_ast.register(ast.Attribute)
    def _(attribute):
        if isinstance(attribute.value, ast.Name):
            accesses.setdefault(attribute.value.id, set()).add(attribute.attr)
        else:
            walk_ast(attribute.value)

    @walk_ast.register(ast.AST)
    def _(node):
        for e in node._fields:
            walk_ast(getattr(node, e))

    walk_ast(source_ast.body)

    return accesses, accesses_suspicious


@dataclass(frozen=True)
class SourceLocation:
    file: str
    line: int

    def __str__(self):
        return f"""File "{self.file}", line {self.line}"""

    def __iter__(self):
        return iter([self.file, self.line])

    @staticmethod
    def current(skip_frames=1):
        frame = get_frame(skip_frames + 1)
        return SourceLocation(
            frame.f_code.co_filename,
            frame.f_lineno)

    @staticmethod
    def for_function(func):
        return SourceLocation(
            inspect.getfile(func),
            inspect.findsource(func)[1] + 1)


def get_frame(skip_frames):
    frame = inspect.currentframe()
    for i in range(skip_frames + 1):
        frame = frame.f_back
    return frame


def __is_in_class_declaration():
    return __class_locals() is not None


def __is_in_class_context():
    return __context_classes() is not None


def __context_classes():
    return getattr(rules_for, "__current_rule__", None)


def __class_locals():
    frame = get_frame(1)

    while frame.f_back is not None:
        f_locals = frame.f_locals

        if all(f in f_locals for f in ["__qualname__", "__module__"]):
            return f_locals

        frame = frame.f_back

    return None


def __get_function_ast(func):
    source = inspect.getsourcelines(func)[0]
    indent = len(source[0]) - len(source[0].lstrip())
    source = [l[indent:] for l in source]
    source = "".join(source)

    return ast.parse(source).body[0]


def _eval_ast(ast_element, context):
    if not isinstance(context, dict):
        context = getattr(context, "__globals__")
    compiled = compile(ast.Expression(ast_element), "<internal>", "eval")
    return eval(compiled, context, context)
