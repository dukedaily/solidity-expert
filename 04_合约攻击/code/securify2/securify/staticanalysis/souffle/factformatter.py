__all__ = [
    "format_relation_decl",
    "format_facts_as_code",
    "format_facts_as_csv"
]


def format_relation_decl(decl):
    fields = [f'{f}: {t.name}' for f, t in zip(decl._fields, decl._types)]
    params = ', '.join(fields)

    return f""".decl {decl._name}({params})"""


def format_relations_decls(relations):
    types = {t for r in relations for t in r._types}  # TODO: define types in relation class
    types = {t.decl() for t in types}

    declarations = map(format_relation_decl, relations)
    inputs = map(lambda t: ".input " + t._name, relations)

    return [
        "#define ENABLE_INPUT_FROM_FILES",
        "",
        *types,
        "",
        "// -- input relations -- ",
        *declarations,
        "",
        "#ifdef ENABLE_INPUT_FROM_FILES",
        *inputs,
        "#endif",
    ]


def format_facts_as_code(facts, relations=None):
    def format_fact(fact):
        return f"""{fact._name}({', '.join(map(lambda t: f'"{t}"', fact))})."""

    result = []

    if relations:
        result += format_relations_decls(relations)
        result += [""]

    result += [
        "// -- inputs facts -- ",
        *map(format_fact, facts)
    ]

    return "\n".join(result)


def format_facts_as_csv(facts, delimiter='\t'):
    def format_fact(fact):
        return delimiter.join(map(str, fact))

    result = {}  # TODO: Find out why  groupby(facts, type) does not work

    for fact in facts:
        relation = fact.__class__
        if relation not in result:
            result[relation] = []

        result[relation].append(format_fact(fact))

    return list(result.items())
