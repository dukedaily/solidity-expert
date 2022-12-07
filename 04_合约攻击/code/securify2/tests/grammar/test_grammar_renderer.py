from securify.grammar.attributes.visualization import AttributeGrammarRenderer
from tests.grammar.grammars.arithmetic import *

grammar = AttributeGrammar([
    Root,
    Term,
    Addition,
    Multiplication,
    Constant,
    Sum,
], Parser())

# with open("grammar.json", "w") as f:
#     import json
#     f.write(json.dumps(grammar.grammar_info()))
#     import os
#     os.startfile("grammar.json")

root = Sum(
    Multiplication(Addition(Constant(1), Constant(2)), Constant(2.5)),
    Constant(2),
    Constant(5)
)

if __name__ == '__main__':
    q = AttributeGrammarRenderer(grammar).render_tree(root, (root, "subtree_depth"))

    q.format = "png"
    q.render("test")
    # dot.render(filename=filename)
