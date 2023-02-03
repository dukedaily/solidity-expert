from abc import ABC

from securify.grammar.attributes.evaluators.evaluator_base import EvaluatorBase


class DemandDrivenBase(EvaluatorBase, ABC):
    def __init__(self, grammar):
        super().__init__(grammar)

        self.grammar = grammar

        self.__interfaces = self.__build_attribute_interfaces()
        self._cache = {}

    def for_tree(self, root):
        self.grammar.validate_tree(root)

        root = self._prepare_tree(root)
        self.__inject_interfaces(root)

        return root

    def __inject_interfaces(self, root):
        nodes = []

        def inject_attributes(node, _, context):
            nodes.append((node, context.is_root))

        self.grammar.traverse(root, inject_attributes)

        for node, is_root in nodes:
            node_type = type(node)
            a, s, _ = self.__interfaces[node_type]
            node.__class__ = s if is_root else a

    def __build_attribute_interfaces(self):
        interfaces = {}

        for symbol in self.grammar.productions:
            sym_type = symbol
            sym_name = symbol.__name__
            gen_type = sym_type.__class__

            def new_interface(name, attributes):
                t_symbol = DemandDrivenBase.SymbolInterface
                t_attribute = DemandDrivenBase.EvaluableAttribute

                name = f"{sym_name}__{name}Mixin"
                base = (sym_type, t_symbol)
                cls = gen_type(name, base, {
                    "__original_type__": sym_type,
                    "__attributes__": {}
                })

                for attribute in attributes:
                    evaluable_attribute = t_attribute(self, attribute)
                    setattr(cls, attribute, evaluable_attribute)
                    getattr(cls, "__attributes__")[attribute] = evaluable_attribute

                return cls

            g = self.grammar

            cls_i = new_interface("InheritedAttrs", g.inherited_attributes[symbol])
            cls_s = new_interface("SyntheticAttrs", g.synthesized_attributes[symbol])
            cls_a = new_interface("AllAttrs", g.attributes[symbol])

            interfaces[symbol] = (cls_a, cls_s, cls_i)

        return interfaces

    # def __rule_trace(self):
    #     return '\n\t'.join([str(r) for r in self.__current_rule])

    class EvaluableAttribute:
        def __init__(self, evaluator, name):
            self.__evaluator = evaluator
            self.__name = name

        def __get__(self, instance, owner):
            if self.__name in instance.__dict__:
                return instance.__dict__[self.__name]

            return self.__evaluator.evaluate(instance, self.__name)

        def __set__(self):
            raise AttributeError("Cannot override attributes")

    class SymbolInterface:
        __attributes__: dict

        def __setattr__(self, name, value):
            raise self.ImmutableError(
                f"Cannot set {name} on {self.__class__.__qualname__} object. "
                f"The object has been marked immutable.")

        def __delattr__(self, item):
            raise self.ImmutableError(
                f"Cannot delete {item} on {self.__class__.__qualname__} object. "
                f"The object has been marked immutable.")

        def __is_intrinsic_attribute__(self, attribute):
            if attribute in self.__dict__:
                return True

            return False

        class ImmutableError(AttributeError):
            pass
