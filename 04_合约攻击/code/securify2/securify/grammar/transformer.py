"""Module for transforming dictionary objects into class-instance representations."""
from __future__ import annotations

from typing import get_type_hints

from securify.grammar import GrammarError


class DictTransformer(object):
    """Transforms dicts into class-instance representations according to a given grammar.

    Transforms dicts to actual class instances when they define a "node type" entry
    that can be matched to a particular symbol of a specified grammar. This process
    is applied recursively to the dictionary entries.

    Dictionary entries will be available as attributes in the instantiated nodes in
    accordance to a customizable attribute naming scheme. The transformation can be
    disabled for attributes or child nodes which are not declared explicitly in the
    corresponding grammar definition. (implicit_attributes, implicit_child_nodes).
    """

    def __init__(self,
                 grammar,
                 class_identifier=None,
                 implicit_terminals=None,
                 implicit_non_terminals=None,
                 attribute_naming_scheme=None,
                 class_naming_scheme=None):
        """Instantiate a new DictTransformer with given parameters.

        Parameters
        ----------
        module Module defining the class definitions to use for instantiation.
        class_identifier Name of the class identifier field in the dictionaries.
        implicit_attributes If false, only explicitly declared attributes will be extracted. (Defaults to false)
        implicit_production_rules If false, only explicitly declared rule productions (i.e. child nodes) will be
                                  extracted. (Defaults to true)
        attribute_naming_scheme Naming scheme for attribute elements. (Defaults to SnakeCase)
        class_naming_scheme Transforms class identifier field value to actual class name. (Defaults to Identity).
        """
        self.grammar = grammar

        self.implicit_terminals = implicit_terminals or False
        self.implicit_non_terminals = implicit_non_terminals or False

        self.attribute_naming_scheme = attribute_naming_scheme or SnakeCase()
        self.class_naming_scheme = class_naming_scheme or Identity()

        self.type_field = class_identifier or "nodeType"

    def transform(self, element):
        """Apply the transformation to a dictionary and validate the new tree."""
        tree = self.transform_element(element)

        if any([isinstance(tree, c) for c in self.grammar.productions]):
            self.grammar.validate_tree(tree)
        else:
            raise GrammarError()

        return tree

    def transform_element(self, element):
        """Apply the transformation to a dictionary, a list or another entity."""
        if isinstance(element, dict):
            return self.__transform_dict(element)
        elif isinstance(element, list):
            '''
            We need to account for null elements in the AST e.g. for tuple assignment:
            (a,) = delegatecall(1);
            In this case we add a copy of a namely dummy_a in the place of the missing variable.
            '''
            res = []
            # Get the first variable that's not None and use it as a dummy one

            def get_dummy(element):
                for e in element:
                    if e is not None:
                        if isinstance(e, dict):
                            dummy = dict(e)
                            dummy['name'] = "dummy_" + dummy['name']
                            return dummy
                        else:
                            return None

            for i, e in enumerate(element):
                if e is None:
                    tmp = self.transform_element(get_dummy(element))
                else:
                    tmp = self.transform_element(e)
                res.append(tmp)
            return res
        else:
            return element

    def __transform_dict(self, dict_node):
        """Apply the transformation to a dictionary."""
        if self.type_field not in dict_node:
            return dict_node

        symbol_name = dict_node[self.type_field]
        symbol_name = self.class_naming_scheme(symbol_name)

        if symbol_name not in self.grammar.productions_by_name:
            raise GrammarError(f"Symbol '{symbol_name}' not found in grammar.")

        symbol = self.grammar.productions_by_name[symbol_name]

        node = symbol()
        node_info = get_type_hints(symbol)

        for attribute_name, value in dict_node.items():
            attribute_name = self.attribute_naming_scheme(attribute_name)
            is_node = any([
                isinstance(value, dict) and self.type_field in value,
                isinstance(value, list) and all([isinstance(e, dict) and self.type_field in e for e in value])
            ])

            is_declared = attribute_name in node_info
            is_addable = is_declared or (self.implicit_non_terminals if is_node else
                                         self.implicit_terminals)

            if is_addable:
                setattr(node, attribute_name, self.transform_element(value))

        self.grammar.validate_node(node)

        return node


class Identity(object):
    """Identity string transformation."""

    def __call__(self, *args, **kwargs):
        """Return original string."""
        return args[0]


class SnakeCase(object):
    """Snake case string transformer."""

    import re
    first_cap_re = re.compile('(.)([A-Z][a-z]+)')
    all_cap_re = re.compile('([a-z0-9])([A-Z])')

    def __call__(self, *args, **kwargs) -> str:
        """Transform string to snake case."""
        s0 = args[0]
        s1 = self.first_cap_re.sub(r'\1_\2', s0)
        return self.all_cap_re.sub(r'\1_\2', s1).lower()
