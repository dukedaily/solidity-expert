import sys
from collections import defaultdict

from .evaluator_demand_base import DemandDrivenBase


class DemandDrivenRecursive(DemandDrivenBase):
    def __init__(self, grammar, recursion_limit=None):
        super().__init__(grammar)

        self.__allowed_access = []
        self.__current_rule = []

        self.__cache = {}
        self.__nodes_evaluating = set()

        if recursion_limit:
            sys.setrecursionlimit(recursion_limit)

    def evaluate(self, node, attribute):
        from securify.grammar.attributes import AttributeGrammarError

        try:
            return self.__evaluate(node, attribute)
        except AttributeGrammarError as e:
            raise AttributeGrammarError(*e.args) from e.__cause__

    def __evaluate(self, node, attribute):
        from securify.grammar.attributes import AttributeGrammarError

        if (node, attribute) in self.__nodes_evaluating:
            raise AttributeGrammarError(
                f"Found cycle during evaluation of '{attribute}'. \n"
                f"Rule trace: {self.__rule_trace()}")

        cache_key = (node, attribute)
        cache = self.__cache

        if cache_key in cache:
            return cache[cache_key]

        self.__nodes_evaluating.add((node, attribute))
        result = self.__evaluate_inner(node, attribute)
        self.__nodes_evaluating.remove((node, attribute))

        cache[cache_key] = result

        return result

    def __evaluate_inner(self, node, attribute):
        rule_info = self[node].resolve_rule(attribute)

        if rule_info is None:
            return getattr(node, attribute, None)

        if len(self.__allowed_access) > 0:
            access = self.__allowed_access[-1]
            if attribute not in access[node]:  # Should always be available
                raise AttributeError(
                    f"Attribute '{attribute}' not declared as dependency in {self.__current_rule[-1]}.")

        return self._evaluate_rule(rule_info)

    def _execute_rule(self, rule, arguments):
        try:
            access = defaultdict(lambda: set())
            for node_name, attribute in rule.dependencies:
                nodes = arguments[node_name]
                for node in nodes if isinstance(nodes, (list, tuple)) else [nodes]:
                    access[node].add(attribute)

            self.__allowed_access.append(access)
            self.__current_rule.append(rule)

            for (node, attributes) in access.items():
                if node is not None:
                    for attribute in attributes:
                        self.__evaluate(node, attribute)

            try:
                return super()._execute_rule(rule, arguments)
            except Exception as e:
                from securify.grammar.attributes import AttributeGrammarError
                raise AttributeGrammarError(f"Error during evaluation of rule '{rule.name}'. \n"
                                            f"Rule trace: {self.__rule_trace()}") from e
        finally:
            self.__allowed_access.pop()
            self.__current_rule.pop()

    def __rule_trace(self):
        return '\n\t'.join([str(r) for r in self.__current_rule])
