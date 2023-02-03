from securify.grammar.attributes import AttributeGrammarError
from securify.grammar.attributes.evaluators.evaluator_base import EvaluatorBase


class StaticEvaluator(EvaluatorBase):
    def __init__(self, grammar):
        super().__init__(grammar)

        self.order = {s: self.build_order(s) for s in self.grammar.productions}
        self.required_visits = max(map(len, self.order.values()))

    def for_tree(self, root):
        root = self._prepare_tree(root)

        for i in range(self.required_visits):
            self.visit(root, i)

        return root

    def visit(self, node, i):
        self.solve(node, i)

    def solve(self, node, visit_i):
        if node == None:
            return

        order = self.order[type(node)]
        seq_i, seq_s = order[visit_i] if visit_i < len(order) else ([], [])

        for attr in seq_i:
            self.eval_and_set_attribute(node, attr)

        for p in self.grammar.children_of(node).keys():
            nodes = self[node].resolve_node(p)

            if isinstance(nodes, (list, tuple)):
                for n in nodes:
                    self.visit(n, visit_i)
            else:
                self.visit(nodes, visit_i)

        for attr in seq_s:
            self.eval_and_set_attribute(node, attr)

    def eval_and_set_attribute(self, node, attr):
        setattr(node, attr, self.eval(node, attr))

    def eval(self, node, attribute):
        rule_info = self[node].resolve_rule(attribute)
        if rule_info is None:
            return getattr(node, attribute)

        return self._evaluate_rule(rule_info)

    def build_order(self, symbol):
        if not self.grammar.is_absolutely_acyclic:
            raise AttributeGrammarError("Attribute grammar must be absolutely non-circular for static evaluation.")

        dependencies = self.grammar.lower_dependence_combined[symbol].depends_on
        remaining_attributes = set(self.grammar.attributes[symbol])

        inherited_attributes = self.grammar.inherited_attributes[symbol]
        synthesized_attributes = self.grammar.synthesized_attributes[symbol]

        def max_inherited_group():
            sequence = []
            while True:
                inherited = {i for i in remaining_attributes
                             if i in inherited_attributes
                             if remaining_attributes.isdisjoint(dependencies.get(i, set()))}

                if len(inherited) == 0:
                    break

                remaining_attributes.difference_update(inherited)
                sequence.append(inherited)

            return [s for sub_seq in sequence for s in sub_seq]

        def max_synthesized_group():
            sequence = []
            while True:
                synthesized = {i for i in remaining_attributes
                               if i in synthesized_attributes
                               if remaining_attributes.isdisjoint(dependencies.get(i, set()))}

                if len(synthesized) == 0:
                    break

                remaining_attributes.difference_update(synthesized)
                sequence.append(synthesized)

            return [s for sub_seq in sequence for s in sub_seq]

        sequences = []

        synthesized_seq = max_synthesized_group()
        sequences.append(([], synthesized_seq))

        while len(remaining_attributes) > 0:
            inherited_seq = max_inherited_group()
            synthesized_seq = max_synthesized_group()

            sequences.append((inherited_seq, synthesized_seq))

        return sequences

    @staticmethod
    def __execute_rule(rule, arguments):
        return rule.func(**{name: node for name, (node, _) in arguments.items()})
