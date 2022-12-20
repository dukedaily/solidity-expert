from pathlib import Path
from time import time

from graphviz import Digraph

from securify.solidity import compile_cfg
from securify.staticanalysis import souffle
from securify.staticanalysis.factencoder import encode
from securify.staticanalysis.static_analysis import analyze_cfg
from securify.staticanalysis.visualization import visualize


def graph(data, name, engine=None, inv=False):
    g = Digraph()
    g.attr('graph', fontname='mono')
    g.attr('node', fontname='mono')
    g.attr('node', shape='box')
    if engine:
        g.engine = engine

    for next, prev in data:
        if inv:
            g.edge(next.strip(), prev.strip())
        else:
            g.edge(prev.strip(), next.strip())

    g.render("out/" + name, format="png", cleanup=True)


if __name__ == '__main__':
    cfg = compile_cfg("testContract.sol").cfg
    # visualizer.draw_cfg(cfg, file='out/cfg', format='png', only_blocks=True, view=False)

    result = analyze_cfg(
        cfg=cfg,
        logger=print,
        **{
            "library_dir": Path(__file__).parent / "libfunctors",
            "profile_out": "souffle-profile.json",
            # "profile_use": "souffle-profile.json",
            # "report_out": "souffle-report.html"
        })

    visualize(result.facts).render("out/dl", format="svg", cleanup=True)

    # print(result.stderr)
    # print(result.stdout)

    # graph(facts_out["programFlow.followsInBlockWithContextToString"], "wtf3")
    # graph(facts_out["followsWithContextToString"], "wtf2")
    # graph(facts_out["followsBlockWithContextToString"], "wtf")
    # graph(facts_out["programFlow.mustPrecedeToString"], "dom", "circo", inv=True)

    for error in result.facts_out["errors"]:
        raise Exception(error)
