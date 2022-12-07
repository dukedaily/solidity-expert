# from __future__ import annotations

import itertools
from builtins import classmethod
from copy import copy
from dataclasses import dataclass
from functools import wraps
from typing import Dict, Any, Set, Tuple

from graphviz import Digraph


def inplace_op(f):
    @wraps(f)
    def inplace_wrapper(self, *args, inplace=False, **kwargs):
        if not inplace:
            self = copy(self)

        f(self, *args, **kwargs)

        return self

    return inplace_wrapper


@dataclass
class Graph:
    TNode = Any

    nodes: Set[TNode]

    out_edges: Dict[TNode, Set[TNode]]
    in_edges: Dict[TNode, Set[TNode]]

    edges: Set[Tuple[TNode, TNode]]

    @classmethod
    def _constructor(cls):
        return Graph

    @property
    def is_empty(self):
        return len(self.nodes) == 0

    def __bool__(self):
        return not self.is_empty

    # region Node Accessors
    @property
    def sources(self):
        return {n for n, sources in self.in_edges.items() if not sources}

    @property
    def sinks(self):
        return {n for n, sinks in self.out_edges.items() if not sinks}

    def predecessors(self, node):
        return self.in_edges[node]

    def successors(self, node):
        return self.out_edges[node]

    # endregion Node Accessors

    # region Primitive Ops
    @inplace_op
    def add_node(self, node, ignore_existing=False):
        if node in self.nodes:
            if ignore_existing:
                return
            raise ValueError("Node already in graph")

        self.nodes.add(node)
        self.out_edges[node] = set()
        self.in_edges[node] = set()

    @inplace_op
    def add_nodes(self, *nodes, ignore_existing=False):
        for node in nodes:
            self.add_node(node, inplace=True, ignore_existing=ignore_existing)

    @inplace_op
    def add_edge(self, s, t, create_nodes=False):
        if not create_nodes:
            if s not in self.nodes:
                raise ValueError("Node not in graph")
            if t not in self.nodes:
                raise ValueError("Node not in graph")
        else:
            self.add_nodes(s, t, inplace=True, ignore_existing=True)

        self.out_edges[s].add(t)
        self.in_edges[t].add(s)
        self.edges.add((s, t))

    @inplace_op
    def add_edges(self, *edges, create_nodes=False):
        for s, t in edges:
            self.add_edge(s, t, create_nodes=create_nodes, inplace=True)

    @inplace_op
    def remove_node(self, node):
        if node not in self.nodes:
            return

        in_edges = ((s, node) for s in self.in_edges[node])
        out_edges = ((node, t) for t in self.out_edges[node])

        self.remove_edges(*itertools.chain(in_edges, out_edges), inplace=True)

        self.in_edges.pop(node)
        self.out_edges.pop(node)
        self.nodes.remove(node)

    @inplace_op
    def remove_nodes(self, *nodes):
        for n in nodes:
            self.remove_node(n, inplace=True)

    @inplace_op
    def remove_edge(self, s, t):
        self.edges.remove((s, t))
        self.in_edges[t].remove(s)
        self.out_edges[s].remove(t)

    @inplace_op
    def remove_edges(self, *edges):
        for s, t in edges:
            self.remove_edge(s, t, inplace=True)

    # endregion

    @inplace_op
    def union(self, other, assert_disjoint=False):
        if not isinstance(other, Graph):
            raise TypeError()

        if assert_disjoint and not self.nodes.isdisjoint(other.nodes):
            raise ValueError("Graphs not disjoint", self.nodes.intersection(other.nodes))

        self.nodes.update(other.nodes)
        self.edges.update(other.edges)

        self.out_edges.update({n: (self.out_edges.get(n, set()) |
                                   other.out_edges.get(n, set())) for n in self.nodes})

        self.in_edges.update({n: (self.in_edges.get(n, set()) |
                                  other.in_edges.get(n, set())) for n in self.nodes})

    @inplace_op
    def replace(self, old_node, new_graph_or_node):
        new_graph = (new_graph_or_node if isinstance(new_graph_or_node, Graph) else
                     self.single_node(new_graph_or_node))

        old_node_predecessors = list(self.predecessors(old_node))
        old_node_successors = list(self.successors(old_node))

        self.remove_node(old_node, inplace=True)
        self.union(new_graph, inplace=True, assert_disjoint=True)

        if new_graph.is_empty:
            self.add_edges(*itertools.product(old_node_predecessors, old_node_successors), inplace=True)
        else:
            self.add_edges(*itertools.product(old_node_predecessors, new_graph.sources), inplace=True)
            self.add_edges(*itertools.product(new_graph.sinks, old_node_successors), inplace=True)

    def copy(self):
        return copy(self)

    def __copy__(self):
        return self._constructor()(
            nodes=self.nodes.copy(),
            edges=self.edges.copy(),
            out_edges={n: succ.copy() for n, succ in self.out_edges.items()},
            in_edges={n: prev.copy() for n, prev in self.in_edges.items()},
        )

    # region Printing and Visualization
    def pprint(self, f=None):
        print("Nodes:", file=f)
        for n in self.nodes:
            print(f"  {n}", file=f)

        print("Edges:", file=f)
        for s, t in self.edges:
            print(f"  {s} -> {t}", file=f)

    def to_dot(self):
        digraph = Digraph()

        for n in self.nodes:
            digraph.node(str(id(n)), str(n))

        for s, t in self.edges:
            digraph.edge(str(id(s)), str(id(t)))

        return digraph

    # endregion

    @classmethod
    def empty(cls):
        return cls._constructor()(set(), dict(), dict(), set())

    @classmethod
    def single_node(cls, node):
        return cls.empty().add_node(node, inplace=True)

    @classmethod
    def linear(cls, *nodes):
        return (cls.empty()
                .add_nodes(*nodes, inplace=True)
                .add_edges(*zip(nodes[:-1], nodes[1:]), inplace=True))


if __name__ == '__main__':
    graph = Graph.empty()
    graph2 = Graph.empty()

    graph = graph.add_edge(1, 2, create_nodes=True)
    graph = graph.add_edge(1, 3, create_nodes=True)
    graph = graph.add_edge(3, 2, create_nodes=True)
    graph = graph.add_edge(3, 2, create_nodes=True)

    graph2.add_edge(1 + 20, 2 + 20, create_nodes=True, inplace=True)
    graph2.add_edge(1 + 20, 3 + 20, create_nodes=True, inplace=True)
    graph2.add_edge(3 + 20, 2 + 20, create_nodes=True, inplace=True)
    graph2.add_edge(3 + 20, 2 + 20, create_nodes=True, inplace=True)

    graph.union(graph2, inplace=True)

    # graph.remove_node(1, inplace=True)

    graph = Graph.empty()
    graph = graph.add_edges((1, 2), (2, 3), (3, 4), (3, 5), (5, 6), create_nodes=True)

    graph.to_dot().render("q1", format="svg", cleanup=True)

    graph = graph.replace(3, 3)
    graph = graph.replace(3, graph2)

    graph.pprint()
    graph.to_dot().render("q2", format="svg", cleanup=True)
