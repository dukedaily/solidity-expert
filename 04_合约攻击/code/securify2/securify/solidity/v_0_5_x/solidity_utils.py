from copy import deepcopy
from dataclasses import dataclass
from typing import Iterable, Dict

from ...ir import cfg_ir as ir
from ...ir.cfgutils import CfgSimple


@dataclass
class Stage1Context:
    cfg_contract_state_init: Dict[int, CfgSimple]
    cfg_modifiers: Dict[int, CfgSimple]


@dataclass
class Stage2Context:
    cfg_functions: Dict[int, CfgSimple]


def deepcopy_with_mapping(obj, mapping):
    if isinstance(mapping, dict):
        mapping = mapping.items()

    if isinstance(mapping, tuple):
        mapping = zip(*mapping)

    if isinstance(mapping, Iterable):
        mapping = {id(k): v for k, v in mapping}

    return deepcopy(obj, memo=mapping)


def link_functions(functions, functions_mro):
    functions_by_name = {f.ast_node.name: f for f, _ in reversed(functions_mro)}
    functions_by_id = {f.ast_node.id: f for f, _ in reversed(functions_mro)}

    for _, blocks in functions.values():
        for block in blocks:
            if isinstance(block.transfer, ir.Jump):
                assert isinstance(block.transfer.dst, ir.JumpDestination), block.transfer.dst

                function_id = block.transfer.dst.function

                if isinstance(function_id, int):
                    block.transfer.dst = functions_by_id.get(function_id, None)
                elif isinstance(function_id, str):
                    block.transfer.dst = functions_by_name.get(function_id, None)
                else:
                    raise NotImplementedError("Unexpected function id type", function_id)

                assert block.transfer.dst is not None

            elif isinstance(block.transfer, ir.Call):
                assert isinstance(block.transfer.dst, ir.CallTarget), block.transfer.dst

                # if isinstance(target.function, int):
                #     pass


def link_state_vars(functions, variables):
    for _, blocks in functions.values():
        for block in blocks:
            for stmt in block.stmts:
                if isinstance(stmt.expr, ir.StateVariableLoad):
                    stmt.expr.variable = variables[stmt.expr.id]

                if isinstance(stmt.expr, ir.StateVariableStore):
                    stmt.expr.variable = variables[stmt.expr.id]
