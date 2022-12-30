import dataclasses
import itertools
from copy import copy
from dataclasses import dataclass
from typing import Any, Iterable, Set

from graphviz import Digraph

from securify.ir import cfg_ir
from securify.ir.graph import Graph
from securify.solidity.utils import filter_by_type


@dataclass(unsafe_hash=False, eq=True)
class CfgSimple:
    """A helper class for handlin """

    graph: Graph
    """Underlying graph instance"""

    terminals: Set[Any]
    """Set of sink nodes that should not be appended"""

    # region Accessors to underlying Graph
    def successor(self, element, or_else=...):
        return single_element(self.graph.successors(element), or_else)

    def predecessor(self, element, or_else=...):
        return single_element(self.graph.predecessors(element), or_else)

    # endregion

    # region Accessors
    @property
    def first(self):
        """The source node of this CFG (fails if |sources| != 1)"""
        return single_element(self.graph.sources)

    @property
    def last_appendable(self):
        """The appendable sink node of this CFG (fails if |sinks_appendable| != 1)"""
        return single_element(self.sinks_appendable)

    @property
    def sinks_appendable(self):
        """A set of all appendable sinks in this CFG"""
        return self.graph.sinks - self.terminals

    # endregion

    # region CFG Operations
    def append(self, other):
        """
        Concatenates this CFG with another CFG of IR node

        All appendable sinks of this CFG will be connected to all sources of
        the provided CFG. The terminals of the new CFG will be the terminals
        of both CFGs.
        """
        new_graph = self.graph.copy()
        new_terminals = self.terminals.copy()

        if not self.sinks_appendable and not self.graph.is_empty:
            return self

        for other in other if isinstance(other, Iterable) else [other]:
            other = self.__make_cfg(other)
            edges = itertools.product(self.sinks_appendable, other.graph.sources)

            new_graph.union(other.graph, inplace=True, assert_disjoint=True)
            new_graph.add_edges(*edges, inplace=True)

            new_terminals.update(other.terminals)

        return CfgSimple(new_graph, new_terminals)

    def replace(self, node, new_node):
        new_graph = self.graph.replace(node, new_node.graph if isinstance(new_node, CfgSimple) else new_node)
        new_terminals = self.terminals

        if node in new_terminals:
            new_terminals -= {node}
            new_terminals |= {new_node} if not isinstance(new_node, CfgSimple) else new_node.sinks

        return self.updated(graph=new_graph, terminals=new_terminals)

    def remove(self, node):
        """Removes a node from this CFG together with any edges that it shares"""
        return self.updated(graph=self.graph.remove_node(node), terminals=self.terminals - {node})

    def remove_with_connection(self, node):
        """Removes a node from this CFG and connects each of its predecessors to each of its successors"""
        p = self.graph.predecessors(node)
        s = self.graph.successors(node)
        edges = itertools.product(p, s)

        return self.updated(graph=self.graph.remove_node(node).add_edges(*edges),
                            terminals=self.terminals - {node})

    def without_appendable(self, end):
        """Marks a sink node as non-appendable"""
        assert end in self.graph.sinks
        return self.updated(terminals=self.terminals | {end})

    # endregion

    def updated(self, **kwargs):
        return dataclasses.replace(self, **kwargs)

    @staticmethod
    def __make_cfg(element):
        return element if isinstance(element, CfgSimple) else CfgSimple.statement(element)

    # region Construction
    @staticmethod
    def empty():
        """Creates an empty CFG"""
        return CfgSimple(Graph.empty(), set())

    @staticmethod
    def statement(element):
        """Creates a CFG consisting of only one IR node"""
        return CfgSimple(Graph.single_node(element), terminals=set())

    @staticmethod
    def statement_terminal(element):
        """Creates a CFG consisting of only one IR node"""
        return CfgSimple(Graph.single_node(element), terminals={element})

    @staticmethod
    def statements(*elements):
        """Concatenates a sequence of basic IR nodes"""
        return CfgSimple(Graph.linear(*elements), terminals=set())

    @staticmethod
    def concatenate(*elements):
        """
        Concatenates a sequence of CFGs or IR nodes

        Sinks will be connected to all sources of CFGs that are adjacent in the
        provided input sequence. IR nodes will be treated as CFGs with only one
        element.
        """
        cfg = CfgSimple.empty()
        for e in elements:
            cfg >>= e
        return cfg

    # endregion

    def __add__(self, element):
        """Union operation"""
        if isinstance(element, CfgSimple):
            return self.updated(graph=self.graph.union(element.graph), terminals=self.terminals | element.terminals)
        else:
            return self.updated(graph=self.graph.add_edges(element, create_nodes=False))

    def __sub__(self, element):
        """Difference Operation"""
        if isinstance(element, CfgSimple):
            return self.updated(graph=self.graph.remove_nodes(*element.graph.nodes, inplace=False),
                                terminals=self.terminals - element.graph.nodes)
        else:
            raise Exception()

    def __rrshift__(self, other):
        """Append self to other in `other >> self`"""
        return self.__lshift__(other)

    def __lshift__(self, other):
        """Prepend other to self in `self << other`"""
        return self.__make_cfg(other) >> self

    def __rshift__(self, other):
        """Append other to self in `self >> other`"""
        return self.append(other)

    # TODO: extract to separate package
    def visualize(self):
        g = Digraph('production_hierarchy')

        for n in self.graph.nodes:
            g.node(name=str(id(n)),
                   label=type(n).__name__ + ": " + str(n),
                   shape="hexagon" if isinstance(n, cfg_ir.Block) else "box")

        for s, t in self.graph.edges:
            g.edge(str(id(s)), str(id(t)))

        return g

    def visualize_and_display(self, name="cfg", format='svg'):
        g = self.visualize()

        g.format = format
        g.render(name, cleanup=True)

        return g


def check_cfg(cfg: CfgSimple):
    """Basic consistency checks for cfgs"""
    # cfg.visualize_and_display()
    for node in cfg.graph.nodes:
        predecessors = cfg.graph.predecessors(node)

        if len(predecessors) > 1:
            assert isinstance(node, cfg_ir.Block), type(node)

            for p in predecessors:
                assert isinstance(p, cfg_ir.Transfer), type(p)

    return True


def build_function_cfg(f: cfg_ir.Function):
    ir = cfg_ir
    cfg_simple: CfgSimple = f.cfg

    check_cfg(cfg_simple)

    blocks = {}

    for block in filter_by_type(cfg_simple.graph.nodes, ir.Block):
        assert block not in blocks
        new_block = ir.Block(block.ast_node, block.args, info=block.info)
        blocks[block] = new_block

    for block_original, block in blocks.items():
        successor = block_original
        while True:
            successor = cfg_simple.successor(successor)

            if isinstance(successor, ir.Expression):
                block.add_stmt(ir.Statement(successor.ast_node, successor))

            elif isinstance(successor, ir.Comment):
                block.add_stmt(ir.Statement(successor.ast_node, successor))

            elif isinstance(successor, ir.MarkerNode):
                block.add_stmt(ir.Statement(successor.ast_node, successor))

            elif isinstance(successor, ir.Placeholder):
                block.add_stmt(ir.Statement(successor.ast_node, ir.Comment(successor.ast_node, "PLACEHOLDER")))

            elif isinstance(successor, ir.Transfer):
                if isinstance(successor, ir.Goto):
                    new_goto = copy(successor)
                    new_goto.block = blocks[cfg_simple.successor(successor)]
                    block.set_transfer(new_goto)

                elif isinstance(successor, ir.Branch):
                    new_branch = copy(successor)
                    new_branch.true_block = blocks[new_branch.true_block]

                    if new_branch.false_block:
                        new_branch.false_block = blocks[new_branch.false_block]

                    block.set_transfer(new_branch)

                elif isinstance(successor, ir.Call):
                    new_call = copy(successor)
                    new_call.continuation = blocks[new_call.continuation]
                    block.set_transfer(new_call)

                elif isinstance(successor, ir.Jump):
                    new_jump = copy(successor)
                    new_jump.continuation = blocks[new_jump.continuation]
                    block.set_transfer(new_jump)

                elif isinstance(successor, ir.Return):
                    return_transfer = copy(successor)
                    block.set_transfer(return_transfer)

                elif isinstance(successor, ir.Halt):
                    return_transfer = copy(successor)
                    block.set_transfer(return_transfer)

                else:
                    raise Exception(type(successor))

                break
            elif isinstance(successor, ir.UndefinedNode):
                block.add_stmt(ir.Statement(successor.ast_node, successor))

            else:
                raise Exception(type(successor))

    function_cfg = copy(f)
    function_cfg.cfg = blocks[cfg_simple.first]

    return function_cfg, list(blocks.values())


def single_element(s, or_else=...):
    """Get the element out of a set of cardinality 1"""

    if len(s) == 0:
        if or_else is not ...:
            return or_else
        raise ValueError("Set is empty.")

    if len(s) > 1:
        set_string = "    " + "\n    ".join(map(repr, s))
        raise ValueError("Set contains more than one element."
                         f"Cannot select successor unambiguously from: \n"
                         f"{set_string}")

    for q in s:
        return q
