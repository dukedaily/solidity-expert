import copy
from abc import ABC, abstractmethod
from typing import TypeVar

from securify.grammar.attributes import AttributeGrammar, AttributeGrammarError, AttributedTree

T = TypeVar('T')


class EvaluatorBase(ABC):

    def __init__(self, grammar):
        self.grammar: AttributeGrammar = grammar

    @abstractmethod
    def for_tree(self, root: T) -> T:
        ...

    def _prepare_tree(self, root):
        root = copy.deepcopy(root)
        info = AttributedTree(self.grammar, root)

        def inject_reference(node, _, __):
            node.__attr_info = info[node]

        self.grammar.traverse(root, inject_reference)

        return root

    def __getitem__(self, node) -> AttributedTree.AttributedNodeInfo:
        return node.__attr_info

    def _evaluate_rule(self, rule_info):
        result = self._execute_rule(
            rule_info.rule,
            rule_info.node_dependencies)

        return result

    def _execute_rule(self, rule, arguments):
        try:
            return rule.func(**{name: node for name, node in arguments.items()})
        except AttributeGrammarError as e:
            raise AttributeGrammarError(f"Error during evaluation of rule '{rule.name}'.") from e
