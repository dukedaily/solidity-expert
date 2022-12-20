import itertools
from dataclasses import dataclass
from functools import lru_cache
from io import StringIO
from tokenize import generate_tokens
from typing import List, Iterable, TypeVar, Callable, Type, Optional

from securify.grammar.attributes.annotations3 import synthesized

T = TypeVar("T")


@dataclass
class UndefinedAttribute:
    info: str

    def __bool__(self):
        return False


def fail_on_access():
    raise NotImplementedError("")


def fail_with(exception):
    raise exception


def find(iterable: Iterable[T], predicate) -> Optional[T]:
    return next((i for i in iterable if predicate(i)), None)


def find_index(iterable: Iterable, predicate) -> Optional[int]:
    return next((i for i, p in enumerate(iterable) if predicate(p)), None)


class __OfType:
    def __getitem__(self, item: Type[T]) -> Callable[[Iterable], Iterable[T]]:
        return lambda x: filter_by_type(x, item)


of_type = __OfType()


def filter_by_type(elements, tpe: Type[T]) -> Iterable[T]:
    yield from (e for e in elements if isinstance(e, tpe))


def unzip(tuple_list, n):
    if not tuple_list:
        return [[] for _ in range(n)]

    return zip(*tuple_list)


def unzip2(tuple_list):
    if not tuple_list:
        return [], []

    return zip(*tuple_list)


def synthesized_once(f):  # TODO lru_cache(None)(
    return synthesized(f)


# def generators_to_lists(*elements):
#     return [e if isinstance(e, Generator) else e for e in elements]
#
#
# def union(*elements):
#     return set().union(*generators_to_lists(*elements))


def flatten(*elements):
    return list(itertools.chain(*(e if isinstance(e, Iterable) else [e] for e in elements)))


def as_array(element):
    return list(element) if isinstance(element, Iterable) else [element]


def to_map(tuple_list, key=0, value=1):
    result = {t[key]: t[value] for t in tuple_list}
    assert len(result) == len(tuple_list)
    return result


class FieldSelector:
    def __getattribute__(self, item):
        return lambda x: getattr(x, item)

    def __getitem__(self, item):
        return lambda x: x[item]


__ = FieldSelector()


def parse_tuple_components(type_string):
    token_iterator = generate_tokens(StringIO(type_string).readline)

    def next_token():
        return next(token_iterator).string

    components = 0
    mode_stack = []

    if next_token() == 'tuple':
        mode_stack.append('tuple')
        assert next_token() == '('
    else:
        return 1

    while True:
        token = next_token()

        mode = mode_stack[-1]
        ignore_next = mode == 'ignore'

        if ignore_next:
            if token == '(':
                mode_stack.append('ignore')
            elif token == ')':
                mode_stack.pop()
        else:
            if token == ',':
                assert mode == 'wait_for_comma', mode
                mode_stack.pop()
            elif token == ')':
                if mode == 'wait_for_comma':
                    mode_stack.pop()
                mode_stack.pop()

                if len(mode_stack) == 0:
                    try:
                        next_token()
                        assert False, "No further tokens expected"
                    except:
                        break
                else:
                    mode_stack.append('wait_for_comma')

            elif token == 'tuple':
                mode_stack.append('tuple')
                assert next_token() == '('
            elif token == '(':
                mode_stack.append('ignore')
            else:
                if mode != 'wait_for_comma':
                    components += 1
                    mode_stack.append('wait_for_comma')

    return components


class CfgCompilationError(Exception):
    pass


class CfgCompilationNotSupportedError(CfgCompilationError):
    pass


def is_float(value):
    try:
        float(value)
        return True
    except:
        return False


if __name__ == '__main__':
    print(parse_tuple_components("tuple(uint256, uint256)"))
    print()
    print(parse_tuple_components("tuple(uint256, tuple(tuple(uint, func () (()) return ()), uint256))"))
    print()

# if __name__ == '__main__':
#     print(*generators_to_lists(e for e in [{1}, {2}, {3, 4}]))
