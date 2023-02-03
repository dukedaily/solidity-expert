from token import NEWLINE

from tests.grammar.grammars.scopes import *


def parse(input_string):
    from io import StringIO
    from token import NAME, OP
    from tokenize import generate_tokens

    punctuation = ["{", "}", "(", ")", "=", "/", "*"]
    tokens = list(generate_tokens(StringIO(input_string).readline))
    tokens = [t for t in tokens if t.type in [NAME, NEWLINE] or t.string in punctuation]

    def collapse_stack():
        stack.append(BlockEmpty())
        while len(stack) > 1:
            block = stack.pop()
            top = stack.pop()

            if isinstance(top, Stat):
                new_block = BlockStatList()
                new_block.stat = top
                new_block.block = block
                stack.append(new_block)
            elif isinstance(top, Decl):
                new_block = BlockDeclList()
                new_block.decl = top
                new_block.block = block
                stack.append(new_block)
            elif top == "{":
                stat = StatBlock()
                stat.block = block
                stack.append(stat)
                break
            elif isinstance(top, str):
                decl = SubDecl()
                decl.block = block
                decl.var = top.strip()
                stack.append(decl)
                break
            else:
                raise RuntimeError(names)

    stack = []
    while len(tokens) > 0:
        n = len(tokens)
        names = [t.string for t in tokens]
        types = [t.type for t in tokens]

        if n > 4 and types[:5] == [NAME, NAME, OP, OP, OP] and names[2:5] == ["(", ")", "{"]:
            tokens = tokens[5:]
            stack.append(names[1])
        elif n > 2 and types[:3] == [NAME, OP, NAME] and names[1] == "=":
            tokens = tokens[3:]
            stat = StatAssign()
            stat.var = names[0]
            stat.typ = names[2]
            stack.append(stat)
        elif n > 1 and types[:2] == [NAME, NAME]:
            tokens = tokens[2:]
            decl = VarDecl()
            decl.typ = names[0]
            decl.var = names[1]
            stack.append(decl)
        elif n > 1 and names[:2] == ["/", "*"]:
            tokens = tokens[2:]
            names = names[2:]
            while len(tokens) > 0 and names[:2] != ["*", "/"]:
                tokens.pop(0)
                names.pop(0)
            tokens = tokens[2:]
        elif names[0] == "{":
            tokens = tokens[1:]
            stack.append("{")
        elif names[0] == "}":
            tokens = tokens[1:]
            collapse_stack()
        elif types[0] == NEWLINE:
            tokens = tokens[1:]
        else:
            raise RuntimeError(names)

    collapse_stack()

    assert len(stack) == 1
    return stack.pop()
