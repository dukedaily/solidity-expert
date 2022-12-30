from __future__ import annotations

import hashlib
from dataclasses import dataclass, field
from typing import List, Any, Optional, Dict, Type, Tuple, Iterator, Union

from securify.ir.utils import ExclusiveDeepCopy


def id_str(self, length):
    node_id = str(id(self)).encode('utf-8')
    hash_id = hashlib.sha256(node_id)
    return hash_id.hexdigest()[-length:]


@dataclass(eq=False)
class CFGNode(ExclusiveDeepCopy):
    ast_node: Any

    annotations = {}

    def __post_init__(self):
        self.annotations = {}

    @property
    def dont_copy(self):
        return ["ast_node"]

    def with_annotations(self, *args, **kwargs):
        self.annotations.update({
            **{a: True for a in args},
            **kwargs}
        )

        return self


@dataclass(eq=False)
class UndefinedNode(CFGNode):
    info: str


@dataclass(eq=False)
class NotImplementedNode(UndefinedNode):
    def __str__(self):
        return f"Not implemented {self.info}"


@dataclass(eq=False)
class IgnoredNode(UndefinedNode):
    def __str__(self):
        return f"Ignored Node {self.info}"


class MetadataNode(CFGNode):
    pass


class CompilationHelperNode(CFGNode):
    pass


class SSALink(CompilationHelperNode):
    pass


class MarkerNode(MetadataNode):
    pass


@dataclass(eq=False)
class Comment(MetadataNode):
    comment: str

    def __str__(self):
        return self.comment


@dataclass(eq=False)
class NodeGroup:
    name: str

    start: BeginGroup
    end: EndGroup

    def __iter__(self) -> Iterator[Union[BeginGroup, EndGroup]]:
        return iter([self.start, self.end])

    @staticmethod
    def generate(ast_node, name):
        group = NodeGroup(name, ..., ...)

        start = BeginGroup(ast_node, group)
        end = EndGroup(ast_node, group)

        group.start = start
        group.end = end

        return group


@dataclass(eq=False)
class BeginGroup(MarkerNode):
    group: NodeGroup

    def __str__(self) -> str:
        return f"BEGIN {self.group.name} [{id_str(self.group, 3)}]"


@dataclass(eq=False)
class EndGroup(MarkerNode):
    group: NodeGroup

    def __str__(self) -> str:
        return f"END {self.group.name} [{id_str(self.group, 3)}]"


@dataclass(eq=False)
class Contract(CFGNode):
    name: str
    functions: Dict[int, Function]
    variables: Dict[int, StateVariable]


@dataclass(eq=False)
class StateVariable(CFGNode):
    name: str
    qualified_name: str
    is_constant: bool

    def __post_init__(self):
        super().__post_init__()
        self.with_annotations(
            name=self.name,
            qualifiedName=self.qualified_name,
            isConstant=self.is_constant)


@dataclass(eq=False)
class SourceUnit(CFGNode):
    contracts: List[Contract]


class Block(CFGNode):
    def __init__(self, ast_node, args=None, stmts=None, transfer=None, info=None):
        super().__init__(ast_node)
        self.args: List[Argument] = args or []
        self.stmts: List[Statement] = stmts or []
        self.transfer: Transfer = transfer
        self.info = info

    def add_args(self, args):
        self.args.extend(args if type(args) is list else [args])

    def add_stmt(self, stmt):
        self.stmts.extend(stmt if type(stmt) is list else [stmt])

    def set_transfer(self, transfer):
        if self.transfer is None:
            self.transfer = transfer

    @property
    def id(self):
        return id_str(self, 6)

    def __str__(self):
        return (self.info or "") + str(self.args) or "N/A"


@dataclass(eq=False)
class Function(CFGNode):
    name: str
    cfg: Block
    visibility: str
    payable: bool = False
    constructor: bool = False
    view: bool = False

    signature: Tuple[tuple, tuple] = None

    def __str__(self):
        return self.name


@dataclass(eq=False)
class Statement(CFGNode):
    expr: Expression


class Expression(CFGNode):
    pass


@dataclass(eq=False)
class Assignment(Expression):
    expr: Expression
    info: str = ''
    type_string: Optional[str] = None

    def __str__(self):
        return f'({self.info}={self.expr})'


@dataclass(eq=False)
class Argument(Expression):
    info: str = ''
    type_string: Optional[str] = None
    name: Optional[str] = None

    @property
    def id(self):
        return id_str(self, 3)

    def __str__(self):
        arg = self.name if self.name else f'arg_{self.id}'
        return f"{{{arg}}}"

    # TODO: Fix
    __repr__ = __str__


class Parameter(Argument):
    pass


@dataclass(eq=False)
class Emit(Expression):
    event_name: str
    arguments: List[Expression]

    def __str__(self):
        return f'Emit({self.arguments})'


@dataclass(eq=False)
class Const(Expression):
    value: Any
    type_string: Optional[str] = None

    def __str__(self):
        return f'{self.value}'


@dataclass(eq=False)
class Mapping(Expression):
    name: Optional[str]
    type_string: Optional[str] = None

    def __str__(self):
        return f'Mapping {self.name}'


class Array(Expression):
    def __init__(self, ast_node, expressions, name=None, type_string=None):
        super().__init__(ast_node)
        self.type_string = type_string
        self.name: str = name
        self.expressions = expressions

    def __str__(self):
        return f'Array {self.name}'


@dataclass(eq=False)
class MemberStore(Expression):
    base: Expression
    member: str
    expr: Expression
    type_string: Optional[str] = None

    def __str__(self):
        return f'(STORE {self.member})'


@dataclass(eq=False)
class MemberLoad(Expression):
    base: Expression
    member: str
    type_string: Optional[str] = None

    def __str__(self):
        return f'(LOAD {self.member})'


@dataclass(eq=False)
class BinaryOp(Expression):
    op: str
    lhs: Expression
    rhs: Expression
    type_string: Optional[str] = None

    def __str__(self):
        label = f'({self.lhs} {self.op} {self.rhs})'
        label = label.replace('<', '&lt;')
        label = label.replace('>', '&gt;')
        return label


@dataclass(eq=False)
class UnaryOp(Expression):
    op: str
    sub: Expression
    type_string: Optional[str] = None

    def __str__(self):
        return f'({self.op} {self.sub})'


@dataclass(eq=False)
class TypeRef(Expression):
    name: str


@dataclass(eq=False)
class StateVariableLoad(Expression):
    id: int
    name: str
    qualified_name: str
    type_string: Optional[str] = None
    variable = None

    def __str__(self):
        return f'LOAD {self.name}'


@dataclass(eq=False)
class StateVariableStore(Expression):
    id: int
    name: str
    qualified_name: str
    expr: Expression
    type_string: Optional[str] = None
    variable = None

    def __str__(self):
        return f'STORE {self.qualified_name} = {self.expr}'


@dataclass(eq=False)
class ArrayLoad(Expression):
    base: Expression
    index: Expression
    type_string: Optional[str] = None

    def __str__(self):
        return f'LOAD ARRAY {self.base}[{self.index}]'


@dataclass(eq=False)
class ArrayStore(Expression):
    base: Expression
    index: Expression
    expr: Expression
    type_string: Optional[str] = None

    def __str__(self):
        return f'STORE ARRAY {self.base}[{self.index}] = {self.expr}'


@dataclass(eq=False)
class ArrayPush(Expression):
    base: Expression
    expr: Expression
    type_string: Optional[str] = None

    def __str__(self):
        return f'PUSH {self.expr} += [{self.expr}]'


@dataclass(eq=False)
class MappingLoad(Expression):
    mapping: Expression
    index: Expression
    type_string: Optional[str] = None

    def __str__(self):
        return f'LOAD MAPPING {self.mapping}[{self.index}]'


@dataclass(eq=False)
class MappingStore(Expression):
    mapping: Expression
    index: Expression
    expr: Expression
    type_string: Optional[str] = None

    def __str__(self):
        return f'STORE MAPPING {self.mapping}[{self.index}] = {self.expr}'


class Transfer(CFGNode):
    pass


@dataclass(eq=False)
class Goto(Transfer):
    block: Optional[Block]
    args: List[Expression] = field(default_factory=list)

    def __str__(self):
        return ", ".join([str(a) for a in self.args])


@dataclass(eq=False)
class JumpDestination(CFGNode):
    function: Union[int, str]

    def __str__(self):
        return f"{self.function}"


@dataclass(eq=False)
class CallTarget(CFGNode, ExclusiveDeepCopy):
    address: Expression
    function: Optional[str] = None

    def __str__(self):
        return f"{self.address}.{self.function}"


@dataclass(eq=False)
class Jump(Transfer):
    dst: JumpDestination
    continuation: Block
    args: Optional[List[Any]] = field(default_factory=list)
    names: Optional[List[str]] = field(default_factory=list)

    def __str__(self):
        return f"{self.dst}({self.args})"


@dataclass(eq=False)
class Call(Transfer):
    dst: CallTarget
    continuation: Block
    args: Optional[List[Any]] = field(default_factory=list)
    names: Optional[List[str]] = field(default_factory=list)
    ether: Optional[Expression] = None
    gas: Optional[Expression] = None
    kind: Optional[str] = "call"  # TODO


@dataclass(eq=False)
class Branch(Transfer):
    cond: Expression
    true_block: Block
    false_block: Block
    true_args: Optional[List[Any]]
    false_args: Optional[List[Any]]

    def __str__(self):
        return f'cond=[{self.cond}] ' \
               f'\n [{",".join([str(s) for s in self.true_args])}]' \
               f'\n [{",".join([str(s) for s in self.false_args])}]'


@dataclass(eq=False)
class Return(Transfer):
    returns: Optional[List[Expression]] = field(default_factory=list)
    variable_map: Optional[Dict[int, Expression]] = field(default_factory=dict)  # TODO: Remove

    def __str__(self):
        ret_string = ', '.join([str(ret) for ret in self.returns])
        return f'RET [{ret_string}]'


@dataclass(eq=False)
class Halt(Transfer):
    revert: bool

    def __str__(self):
        return ["REVERT", "HALT"][self.revert]


@dataclass(eq=False)
class Placeholder(Expression):
    def __str__(self):
        return id_str(self, 5).upper()


@dataclass(eq=False)
class SelfDestruct(Expression):
    address: Expression
    type_string: Optional[str] = None

    def __str__(self):
        return f'SELFDESTRUCT'


@dataclass(eq=False)
class MagicVariable(Expression):
    variable: str
    type_string: Optional[str] = None

    def __str__(self):
        return f'{self.variable}'

    @staticmethod
    def build_class(name: str, type_string: str) -> Type[MagicVariable]:
        # noinspection PyTypeChecker
        return type(name, (MagicVariable,), {
            "__init__": lambda self, ast_node: MagicVariable.__init__(self, ast_node, name, type_string)
        })


This = MagicVariable.build_class("THIS", "address")
GasLeft = MagicVariable.build_class("GAS", "uint256")
Sender = MagicVariable.build_class("SENDER", "address")
Origin = MagicVariable.build_class("ORIGIN", "address")
Coinbase = MagicVariable.build_class("COINBASE", "address")
Difficulty = MagicVariable.build_class("DIFFICULTY", "uint256")
GasPrice = MagicVariable.build_class("GASPRICE", "uint256")
GasLimit = MagicVariable.build_class("GASLIMIT", "uint256")
Timestamp = MagicVariable.build_class("TIMESTAMP", "uint256")
BlockNumber = MagicVariable.build_class("NUMBER", "uint256")
Data = MagicVariable.build_class("DATA", "bytes")
Signature = MagicVariable.build_class("SIG", "bytes4")
Value = MagicVariable.build_class("VALUE", "uint256")


@dataclass(eq=False)
class Balance(Expression):
    address: Expression
    type_string: Optional[str] = None

    def __str__(self):
        return f'BALANCE({self.address})'


@dataclass(eq=False)
class BuiltinFunction(Expression):
    name: str
    arguments: List[Expression]
