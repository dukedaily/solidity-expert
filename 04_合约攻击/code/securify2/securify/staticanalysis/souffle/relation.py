from collections import namedtuple
from dataclasses import dataclass
from typing import Union


@dataclass(unsafe_hash=True)
class DatalogType:
    name: str
    type: Union[str, tuple, dict, None]

    info: str

    def __post_init__(self):
        if isinstance(self.type, list):
            self.type = tuple(self.type)

    def decl(self):
        declaration = None

        if self.type is None:
            return ""

        if self.type == "number":
            declaration = f".number_type {self.name}"

        if self.type == "symbol":
            declaration = f".symbol_type {self.name}"

        if isinstance(self.type, tuple):
            declaration = f".type {self.name} = {' | '.join([t.name for t in self.type])}"

        if declaration is None:
            raise NotImplementedError()

        return (declaration.ljust(25) + f"// {self.info}" if self.info else
                declaration)

    def format(self, value):
        if self.type == "number":
            return str(value)

        if self.type == "symbol":
            return f'"{value}"'

    def parse(self, string):
        if self.type == "number":
            return int(string)

        return string


SymbolType = DatalogType(name="symbol", type=None, info="Primitive Symbol Type")
NumberType = DatalogType(name="number", type=None, info="Primitive Numeric Type")


def relation(relation_name, relation_datalog_name=None, **kw_fields):
    def to_camel_case(snake_str):
        head, *tail = snake_str.split('_')
        return head + ''.join(x.title() for x in tail)

    relation_datalog_name = relation_datalog_name or to_camel_case(relation_name)

    fields = list(kw_fields)
    types = list(map(kw_fields.get, fields))

    result = namedtuple(relation_name, fields)
    result._name = relation_datalog_name
    result._types = types

    return result


if __name__ == '__main__':
    some_type = DatalogType("Label", "symbol", "Some symbol-like type")
    some_relation = relation("Test", a=some_type, b=some_type)

    print(some_relation)
    print(some_relation(1, 2) == (1, 2))
