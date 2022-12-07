from .evaluator_demand_base import DemandDrivenBase


class DemandDrivenIterative(DemandDrivenBase):
    PRE = 0
    POST = 1

    def evaluate(self, node, attribute):
        cache = self._cache
        cache_key = (node, attribute)

        if cache_key in cache:
            return cache[cache_key]

        dependency_stack = [(self.PRE, cache_key)]

        dependency_path_set = set()
        dependency_path = []

        while dependency_stack:
            (state, data) = dependency_stack.pop()

            if state == self.PRE:
                if data not in cache:
                    node, attribute = data
                    rule_info = self[node].resolve_rule(attribute)

                    if rule_info is None:
                        cache[data] = getattr(node, attribute, None)
                        continue

                    if data in dependency_path_set:
                        from securify.grammar.attributes import AttributeGrammarError
                        raise AttributeGrammarError(
                            f"Found cycle during evaluation of '{attribute}'. \n"
                            f"Rule trace: {self.__rule_trace(dependency_path)}")

                    dependency_path.append(rule_info.rule)
                    dependency_path_set.add(data)

                    dependency_stack.append((self.POST, (rule_info, data)))

                    for target in rule_info.attribute_dependencies:
                        dependency_stack.append((self.PRE, target))

            elif state == self.POST:
                rule_info, current_dependency = data

                rule = rule_info.rule
                arguments = rule_info.node_dependencies

                try:
                    result = super()._execute_rule(rule, arguments)
                except Exception as e:
                    from securify.grammar.attributes import AttributeGrammarError
                    raise AttributeGrammarError(f"Error during evaluation of rule '{rule.name}'. \n"
                                                f"Rule trace: {self.__rule_trace(dependency_path)}") from e

                cache[current_dependency] = result

                dependency_path.pop()
                dependency_path_set.remove(current_dependency)

        return cache[cache_key]

    @staticmethod
    def __rule_trace(rules):
        return '\n\t'.join([""] + [str(r) for r in rules])
