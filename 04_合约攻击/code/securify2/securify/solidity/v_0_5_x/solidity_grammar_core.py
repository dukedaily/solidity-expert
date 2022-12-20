from __future__ import annotations

from decimal import Decimal
from itertools import takewhile
from typing import Set

from .solidity_builtins import *
from .solidity_modifiers import *
from .solidity_utils import *
from ..base import AstNodeBase
from ..utils import *
from ..utils import __
from ...grammar import production, abstract_production, ProductionOps
from ...grammar.attributes import ListElement
from ...grammar.attributes.annotations3 import pushdown, synthesized, inherited, All
from ...ir import cfg_ir as ir
from ...ir.cfgutils import CfgSimple, build_function_cfg

RETURN_PLACEHOLDER_ID = -24011994
"""ID of the return value dummy variable"""

SEND_TRANSFER_GAS = 2300
"""Standard amount of gas used for .send() and .transfer()"""

DEFAULT_INIT = "defaultInit"
"""Marker for default initializations"""

DEFAULT_FALLBACK_NAME = "$_default_fallback_$"

INHERITED_FLAG = "inherited"
"""Annotation flag for inherited elements"""


@abstract_production
class AstNode(AstNodeBase, ProductionOps):
    id: int

    cfg = synthesized(default=UndefinedAttribute("CFG not defined"))

    stage1_context: Stage1Context = inherited()
    stage2_context: Stage2Context = inherited()

    _solc_version = inherited()

    def resolve_reference(self, node_id):
        return self.root().ast_nodes_by_id().get(node_id, None)

    def __str__(self):
        return f"{self.__class__.__qualname__} [{self.src}; line {self.src_line}]"


@abstract_production
class ContractPart(AstNode):
    pass


class VarStateMixin:
    variables_pre: Dict[int, ir.Expression] = inherited(default=lambda: {})
    """Mapping of variable ids to CFG nodes before this statement"""

    variables_post: Dict[int, ir.Expression] = synthesized()
    """Mapping of variable ids to CFG nodes after this statement"""

    scope_pre: Set[int] = inherited(default=set)
    """Set of local variable ids that are visible in the scope of this element"""

    scope_post: Set[int] = synthesized()
    """Set of local variable ids that are visible in the scope after this element"""

    changed_variables: Set[int] = synthesized(default=set)
    """Set of ids of changed local variable in the current expression / statement"""

    @synthesized
    def variables_post(self): return self.variables_pre

    @pushdown
    def variables_pre(self) -> VarStateMixin.variables_pre @ All: return self.variables_pre  # TODO: VARIABLES WTF

    @synthesized
    def scope_post(self): return self.scope_pre

    @pushdown
    def scope_pre(self) -> VarStateMixin.scope_pre @ All: return self.scope_post

    # noinspection PyUnresolvedReferences
    def is_local_variable(self, identifier):
        if not isinstance(identifier, Identifier):
            return False

        decl = self.resolve_reference(identifier.referenced_declaration)

        return isinstance(decl, VariableDeclaration) and not decl.state_variable


@abstract_production
class Statement(AstNode, VarStateMixin):
    required_arguments_continue = inherited(default=UndefinedAttribute("Statement not in loop."))
    """Ids of variables that are required as arguments for a continue statement"""

    required_arguments_break = inherited(default=UndefinedAttribute("Statement not in loop."))
    """Ids of variables that are required as arguments for a break statement"""

    is_reachable = inherited(default=True)
    """Indicates that this statement is part of some program path"""

    is_reachable_next = synthesized()
    """Indicates that a directly following statement is reachable"""

    control_flow_statements = synthesized(default=lambda: set())
    """Set of break and continue statements in this statement and its children"""

    is_part_of_modifier = inherited(default=False)
    """Is this statement defined in the body of a modifier"""

    @synthesized
    def is_reachable_next(self): return self.is_reachable


@abstract_production
class SimpleStatement(Statement):
    pass


@abstract_production
class Expression(AstNode, VarStateMixin):
    expression_value = synthesized(default=fail_on_access)
    """Current symbolic value of the expression"""

    expression_value_used = inherited(default=True, implicit_pushdown=False)
    """Is the result of this expression used?"""

    @property
    def type_string(self) -> str:
        return self.type_descriptions["typeString"]

    @property
    def type_identifier(self) -> str:
        return self.type_descriptions["typeIdentifier"]


@abstract_production
class PrimaryExpression(Expression):
    pass


@abstract_production
class TypeName(AstNode):
    default_value = synthesized(default=fail_on_access)
    """Default initialization value of this type"""


@production
class SourceUnit(AstNode):
    nodes: List[TopLevelNode]

    stage1_context = synthesized()
    stage2_context = synthesized()

    @lru_cache(None)
    def ast_nodes_by_id(self):
        return {d.id: d for d in self.descendants() if d is not None}

    @pushdown
    def push_cfgs(self,
                  nodes: ContractDefinition.contract_cfg_unlinked) -> ContractDefinition.cfgs_unlinked @ nodes:
        return [c.contract_cfg_unlinked for c in of_type[ContractDefinition](self.nodes)]

    @synthesized
    def stage1_context(self, nodes: {ContractDefinition.cfg_local_state_init,
                                     ContractDefinition.contract_modifier_cfgs}):
        contracts = list(of_type[ContractDefinition](nodes))
        return Stage1Context(
            {c.id: c.cfg_local_state_init for c in contracts},
            {i: m for c in contracts for i, m in c.contract_modifier_cfgs.items()},
        )

    @synthesized
    def stage2_context(self, nodes: {ContractDefinition.contract_function_cfgs}):
        contracts = list(of_type[ContractDefinition](nodes))
        return Stage2Context(
            {i: m for c in contracts for i, m in c.contract_function_cfgs.items()}
        )

    @pushdown
    def _(self) -> AstNode.stage1_context @ nodes:
        return self.stage1_context

    @pushdown
    def _(self) -> AstNode.stage2_context @ nodes:
        return self.stage2_context

    @pushdown
    def _(self: ListElement[SourceUnit, "nodes"]) -> TopLevelNode.cfgs_constructors @ next:
        if isinstance(self, ContractDefinition):
            return {**self.cfgs_constructors, self.id: self.cfg_constructor_chain}

        return self.cfgs_constructors

    @synthesized
    def cfg(self, nodes: AstNode.cfg):
        return ir.SourceUnit(self, [node.cfg for node
                                    in of_type[ContractDefinition](nodes)
                                    if not isinstance(node.cfg, UndefinedAttribute)])


@abstract_production
class TopLevelNode(AstNode):
    """Abstract base class for top-level AST nodes"""

    cfgs_unlinked = inherited()
    """All contract cfgs with unlinked function calls"""

    cfgs_constructors = inherited(default=dict)
    """All constructor CFGs"""

    cfg_constructor_chain = synthesized(default=UndefinedAttribute("Not a contract"))


@production
class PragmaDirective(TopLevelNode):
    pass


@production
class ImportDirective(TopLevelNode):
    pass


@production
class ContractDefinition(TopLevelNode):
    name: str
    nodes: List[ContractPart]
    base_contracts: Optional[List[InheritanceSpecifier]]
    linearized_base_contracts: List[int]

    contract_cfg_unlinked = synthesized()
    """CFG of this contract without linked functions"""

    contract_modifier_cfgs = synthesized()
    """CFGs of modifier defined in this contract (indexed by declaring node id)"""

    contract_function_cfgs = synthesized()
    """CFGs of functions defined in this contract (indexed by declaring node id)"""

    cfg_local_state_init = synthesized()
    """CFG for initialization of local state variables"""

    cfg_state_init = synthesized()
    """CFG for initialization of state variables"""

    cfg_constructor = synthesized()
    """CFG of this contract's constructor"""

    @synthesized
    def contract_function_cfgs(self, nodes: {FunctionDefinition.cfg}):
        return {f.id: f.cfg for f in of_type[FunctionDefinition](nodes)}

    @synthesized
    def contract_cfg_unlinked(self, nodes: {ContractPart.cfg}):
        cfgs = of_type[FunctionDefinition](nodes)
        cfgs = {node.id: build_function_cfg(node.cfg) for node in cfgs if node.implemented}

        state_vars = of_type[VariableDeclaration](nodes)
        state_vars = {var.id: ir.StateVariable(var, var.name, var.qualified_name, var.constant) for var in state_vars}

        return ir.Contract(self, self.name, cfgs, state_vars)

    @synthesized
    def contract_modifier_cfgs(self, nodes: {ModifierDefinition.modifier_cfg}):
        return {node.id: node.modifier_cfg for node in filter_by_type(nodes, ModifierDefinition)}

    @synthesized
    def cfg(self):
        if not self.fully_implemented:
            return UndefinedAttribute("Contract not fully implemented")

        if self.contract_kind == "library":
            return UndefinedAttribute("Contract is a library")

        unlinked_cfgs = self.cfgs_unlinked
        inherited_contracts = [c for c in unlinked_cfgs if c.ast_node.id in self.linearized_base_contracts]
        inherited_libraries = [c for c in unlinked_cfgs if c.ast_node.contract_kind == "library"]

        variables = {}
        functions = {}
        functions_mro = []

        for cc in inherited_contracts + inherited_libraries:
            inherited_functions = deepcopy(cc.functions)
            inherited_variables = deepcopy(cc.variables)

            for _, (f, _) in inherited_functions.items():
                # Note that we are including base constructor implementations
                # here which cannot be called directly in order to deploy the
                # contract. We set their visibility to internal such that the
                # only visible constructor is the one created below.
                if f.constructor:
                    f.visibility = "internal"

                # Update names of inherited functions
                if self.id != cc.ast_node.id:
                    f.name = f"{cc.name}.{f.name}"
                    f.with_annotations(INHERITED_FLAG)

            for _, v in inherited_variables.items():
                if self.id != cc.ast_node.id:
                    v.with_annotations(INHERITED_FLAG)

            functions = {**functions, **inherited_functions}
            functions_mro += inherited_functions.values()

            variables = {**variables, **inherited_variables}

        # Build constructor function
        functions[self.id] = build_function_cfg(
            ir.Function(self, "Constructor", deepcopy(self.cfg_constructor), "public", constructor=True))

        link_functions(functions, functions_mro)
        link_state_vars(functions, variables)

        return ir.Contract(self, self.name,
                           {f: c for f, (c, _) in functions.items()}, variables)


@production
class InheritanceSpecifier(ContractPart):
    base_name: UserDefinedTypeName
    arguments: Optional[List[Expression]]

    argument_cfgs = synthesized()

    @synthesized
    def argument_cfgs(self, arguments: {Expression.cfg,
                                        Expression.expression_value}):
        if arguments:
            return [(a.cfg, a.expression_value) for a in arguments]

        return UndefinedAttribute("InheritanceSpecifier has no arguments.")

    @property
    def referenced_declaration(self):
        return self.base_name.referenced_declaration

    def resolve(self) -> ContractDefinition:
        return self.resolve_reference(self.referenced_declaration)


@production
class UsingForDirective(ContractPart):
    library_name: UserDefinedTypeName
    type_name: Optional[TypeName]


@production
class StructDefinition(ContractPart):
    members: List[VariableDeclaration]

    @synthesized
    def cfg(self): return CfgSimple.empty()


@production
class EnumDefinition(ContractPart):
    members: Optional[List[EnumValue]]

    def canonical_name_of(self, member_name_or_id):
        if isinstance(member_name_or_id, str):
            return f"{self.canonical_name}.{member_name_or_id}"

        if isinstance(member_name_or_id, int):
            return self.canonical_name_of(self.members[member_name_or_id].name)

    def default_member(self):
        return ir.Const(self, self.canonical_name_of(0))


@production
class EnumValue(AstNode):
    pass


@production
class ParameterList(AstNode):
    parameters: List[VariableDeclaration]

    default_values = synthesized()
    """List of default values for the parameters"""

    @synthesized
    def default_values(self, parameters: {VariableDeclaration.default_value}):
        return [(p, p.default_value) for p in parameters]


@production
class FunctionDefinition(ContractPart):
    parameters: ParameterList
    return_parameters: ParameterList
    modifiers: List[ModifierInvocation]
    body: Optional[Block]

    name: str

    returns = synthesized()
    """Parameter and return initializations"""

    implicit_return = synthesized()
    """Implicit return cfg; appended if cfg paths not terminated by explicit return"""

    arguments = synthesized()
    """Placeholders for the function's arguments"""

    arguments_return = synthesized()
    """Placeholders for the function's return arguments"""

    modifier_arguments = synthesized()
    """Placeholders for the function's return arguments"""

    cfg_body = synthesized()
    """Cfg of the body with implicit return statement"""

    cfg_return_inits = synthesized()
    """Initializations for return values"""

    cfg_unmodified = synthesized()
    """Cfg of this function without modifiers"""

    cfg_modified = synthesized()
    """Cfg of this function with modifiers"""

    @property
    def is_payable(self):
        return self.state_mutability == "payable"

    @property
    def is_view(self):
        return self.state_mutability == "view"

    @property
    def is_constructor(self):
        return self.kind == "constructor"

    @property
    def signature(self):
        return (tuple(p.type_string for p in self.parameters.parameters),
                tuple(p.type_string for p in self.return_parameters.parameters))

    @pushdown
    def push_variables(self) -> VarStateMixin.variables_pre @ {body, modifiers}:
        return {d.id: a for d, a in self.returns + self.arguments}

    @pushdown
    def push_scope(self) -> VarStateMixin.scope_pre @ {body, modifiers}:
        return {d.id for d, _ in self.returns + self.arguments}

    @pushdown
    def push_arguments_to_modifier(self) -> ModifierInvocation.function_arguments @ modifiers:
        return [a for _, a in self.returns + self.arguments]

    @pushdown
    def push_argument_ids_to_modifier(self) -> ModifierInvocation.function_argument_ids @ modifiers:
        return [a.id for a, _ in self.returns + self.arguments]

    @synthesized
    def returns(self, return_parameters):
        return [
            *((d, ir.Assignment(d, value, d.name, type_string=value.type_string)) for d, value in
              return_parameters.default_values)]  # TODO: if d.name != '')]

    @synthesized
    def arguments(self, parameters):
        return [(p, ir.Parameter(p, name=p.name, info=p.name)) for p in parameters.parameters]

    @synthesized
    def arguments_return(self, return_parameters):
        return [(p, ir.Parameter(p, name=p.name, info=p.name)) for p in return_parameters.parameters]

    @synthesized
    def modifier_arguments(self, modifiers: {ModifierInvocation.modifier_arguments}):
        return [(m, m.modifier_arguments) for m in modifiers]

    @synthesized
    def implicit_return(self, body, return_parameters):
        if not self.implemented:
            return UndefinedAttribute("Implicit return not applicable to unimplemented methods.")

        variables_post = body.variables_post
        return_arguments = [variables_post[d.id] if d.name != '' else
                            default_value for (d, default_value) in return_parameters.default_values]

        return ir.Return(self, return_arguments, variables_post)

    @synthesized
    def cfg_return_inits(self, return_parameters):
        cfg = CfgSimple.empty()
        cfg >>= CfgSimple.statements(*map(__[1], return_parameters.default_values))
        cfg >>= CfgSimple.concatenate(*map(__[1], self.returns))

        return cfg

    @synthesized
    def cfg_body(self, body):
        if not self.implemented:
            return UndefinedAttribute("Cfg not available for unimplemented method.")

        return body.cfg >> self.implicit_return

    @synthesized
    def cfg_unmodified(self):
        if not self.implemented:
            return UndefinedAttribute("Cfg not available for unimplemented method.")

        return (self.cfg_body <<
                self.cfg_return_inits <<
                ir.Block(self, args=list(map(__[1], self.arguments)), info="Function"))

    @synthesized
    def cfg_modified(self: {FunctionDefinition.cfg_body,
                            FunctionDefinition.cfg_return_inits,
                            FunctionDefinition.arguments,
                            FunctionDefinition.returns},
                     modifiers: {ModifierInvocation.is_constructor,
                                 ModifierInvocation.modifier_template,
                                 ModifierInvocation.modifier_arguments}):
        if not self.implemented:
            return UndefinedAttribute("Cfg not available for unimplemented method.")

        return modify_function_body(self, modifiers)

    @synthesized
    def cfg(self, modifiers):
        if not self.implemented:
            return UndefinedAttribute("Function not implemented.")

        cfg = (self.cfg_unmodified if not modifiers else
               self.cfg_modified)

        if self.is_constructor:
            name = "constr_impl"
        elif self.name == "":
            name = DEFAULT_FALLBACK_NAME
        else:
            name = self.name

        return ir.Function(self, name, cfg,
                           visibility=self.visibility,
                           payable=self.is_payable,
                           signature=self.signature,
                           constructor=self.is_constructor,
                           view=self.is_view)


@production
class VariableDeclaration(ContractPart):
    value: Optional[Expression]
    type_name: TypeName

    name: str

    default_value = synthesized()
    """Default value inferred from the underlying type"""

    initialization = synthesized()
    """Initialization value"""

    initialization_cfg = synthesized()
    """Initialization CFG"""

    @property
    def qualified_name(self):
        if not self.state_variable or not isinstance(self.parent(), ContractDefinition):
            raise CfgCompilationError("Qualified name was requested for a non-state variable.")

        return f"{self.parent().name}.{self.name}"

    @synthesized
    def default_value(self, type_name: TypeName.default_value):
        return type_name.default_value

    @synthesized
    def initialization(self, value):
        if value is not None:
            '''
            Consider the contract:
            contract C{
                uint[] a = [1,2];
            }
            In this case, the expression value will be undefined attribute, so according to 
            the documentation we should be using the flattened_expression_values. 
            flattened_expression_variables return an array which probably contrains only one element
            so we should get the first element. If we don't then the expression inside the array will not
            be handled correctly
            '''
            if not isinstance(value.expression_value, UndefinedAttribute):
                return value.expression_value

            return value.flattened_expression_values[0]

        return self.default_value

    @synthesized
    def initialization_cfg(self, value):
        if value is not None:
            return value.cfg

        return CfgSimple.statement(self.default_value)

    @property
    def type_string(self):
        return self.type_descriptions["typeString"]

    @synthesized
    def cfg(self):
        return self.initialization_cfg


class PlaceholderArg(ir.CFGNode):
    def __init__(self, name: str):
        super().__init__(None)
        self.name = name

    def __str__(self):
        return " _ "

    def __repr__(self):
        return " _ "


@production
class ModifierDefinition(ContractPart):
    parameters: ParameterList
    body: Block

    name: str

    arguments = synthesized()
    """Placeholders for the modifiers's arguments"""

    modifier_cfg = synthesized()
    """CFG of this modifier"""

    implicit_return = synthesized()
    """Implicit return statement"""

    initial_placeholder_arg = synthesized()

    @synthesized_once
    def initial_placeholder_arg(self):
        return PlaceholderArg(" _ ")

    @pushdown
    def push_is_part_of_modifier(self) -> Block.is_part_of_modifier @ body:
        return True

    @pushdown
    def push_variables(self) -> VarStateMixin.variables_pre @ body:
        return {**{d.id: a for d, a in self.arguments},
                RETURN_PLACEHOLDER_ID: self.initial_placeholder_arg}

    @pushdown
    def push_scope(self) -> VarStateMixin.scope_pre @ body:
        return {*{d.id for d, _ in self.arguments}, RETURN_PLACEHOLDER_ID}

    @synthesized
    def arguments(self, parameters):
        return [(p, ir.Argument(p, info=p.name + " (modifier)"))
                for p in parameters.parameters]

    @synthesized
    def implicit_return(self, body):
        placeholder = body.variables_post[RETURN_PLACEHOLDER_ID]
        return ir.Return(self, [placeholder], body.variables_post)

    @synthesized
    def modifier_cfg(self, body):
        cfg = CfgSimple.empty()

        # cfg >>= ir.Block(self, args=list(map(__[1], self.arguments)), info="Modifier " + self.name)
        cfg >>= body.cfg
        cfg >>= self.implicit_return

        return cfg, self.arguments, self.initial_placeholder_arg

    @synthesized
    def cfg(self):
        return UndefinedAttribute("Use modifier_cfg instead.")


@production
class ModifierInvocation(AstNode, VarStateMixin):
    modifier_name: Identifier
    arguments: Optional[List[Expression]]

    is_constructor = synthesized()
    """Is this invocation a call to a super constructor?"""

    modifier_arguments = synthesized()
    """Lists of tuples consisting of cfgs and expression values for each argument. CFGs are complete blocks."""

    modifier_template = synthesized()

    function_arguments = inherited()
    """Arguments of the function (including return arguments)"""

    function_argument_ids = inherited()

    @synthesized
    def variables_post(self, arguments: {VarStateMixin.variables_post}):
        if arguments:
            return arguments[-1].variables_post

        return self.variables_pre

    @pushdown
    def push_variables(self: ListElement[ModifierInvocation, "arguments"]) -> Expression.variables_pre @ next:
        return self.variables_post

    @synthesized
    def is_constructor(self):
        return self.modifier_name.referenced_declaration not in self.stage1_context.cfg_modifiers

    @synthesized
    def modifier_arguments(self, arguments: {Expression.cfg,
                                             Expression.expression_value}):
        updated_parameters = [self.variables_post[t] for t in self.function_argument_ids]

        return wrap_modifier_args(arguments,
                                  updated_parameters,
                                  self.function_arguments)

    @synthesized
    def modifier_template(self):
        if self.is_constructor:
            return UndefinedAttribute(
                "Modifier template not available for super-constructor call. "
                "The implementation will insert calls to base constructors instead. "
                "Base constructors that are not called via modifier syntax will be "
                "added in ContractDefinition logic.")

        return expand_placeholders(
            self.stage1_context.cfg_modifiers[self.modifier_name.referenced_declaration],
            self.function_arguments,
            self)


@production
class EventDefinition(ContractPart):
    qualified_name = synthesized()
    @property
    def qualified_name(self):
        contract_name = self.find_ancestor_of_type(ContractDefinition).name
        return f"{contract_name}.{self.name}"
    parameters: ParameterList


@production
class ElementaryTypeName(TypeName):
    name: str

    @synthesized
    def default_value(self):
        if self.name.startswith('int') or self.name.startswith('uint'):
            return ir.Const(self, 0)

        if self.name.startswith('bool'):
            return ir.Const(self, False)

        if self.name.startswith('address'):
            return ir.Const(self, 0)

        if self.name.startswith('string'):
            return ir.Const(self, '')

        return ir.Const(self, 0)


@production
class UserDefinedTypeName(TypeName):
    @synthesized
    def default_value(self):
        decl = self.resolve_reference(self.referenced_declaration)
        if isinstance(decl, EnumDefinition):
            return decl.default_member()

        return ir.Const(self, "UDT")


@production
class FunctionTypeName(TypeName):
    @synthesized
    def default_value(self):
        return UndefinedAttribute("Function types have no default value")


@production
class Mapping(TypeName):
    @synthesized
    def default_value(self):
        return ir.Mapping(self, "N/A")


@production
class ArrayTypeName(TypeName):
    @synthesized
    def default_value(self):
        return ir.Array(self, [], 'N/A')


@production
class InlineAssembly(Statement):
    @synthesized
    def cfg(self):
        # TODO: Log a warning here
        return ir.IgnoredNode(self, "Inline Assembly is not supported yet "
                                    "and will be ignored.")


# noinspection PyMethodOverriding
@production
class Block(Statement):
    statements: List[Statement]

    # region VarStateMixin
    @pushdown
    def variables_map(self) -> Statement.variables_pre @ statements:
        return self.variables_pre

    @pushdown
    def variables_map_step(self: ListElement[Block, "statements"]) -> Statement.variables_pre @ next:
        return self.variables_post

    @synthesized
    def variables_post(self, statements: {Statement.is_reachable, Statement.variables_post}):
        if self.is_empty or not self.is_reachable:
            return self.variables_pre

        final_variables = self.reachable(statements)[-1].variables_post

        # Return the most recent assignments for variables,
        # but only those that were available outside of this block
        return {i: final_variables[i] for i in self.variables_pre.keys()}

    @synthesized
    def changed_variables(self, statements: {Statement.is_reachable, VarStateMixin.changed_variables}):
        return set().union(*(s.changed_variables for s in self.reachable(statements))) & self.scope_pre

    # endregion

    @property
    def is_empty(self):
        return len(self.statements) == 0

    @staticmethod
    def reachable(statements):
        return list(takewhile(lambda x: x.is_reachable, statements))

    @pushdown
    def push_reachable(self: ListElement[Block, "statements"]) -> Statement.is_reachable @ next:
        return self.is_reachable_next

    @synthesized
    def is_reachable_next(self, statements: {Statement.is_reachable_next}):
        return self.is_empty or statements[-1].is_reachable_next

    @synthesized
    def control_flow_statements(self, statements: {Statement.is_reachable,
                                                   Statement.control_flow_statements}):
        return set().union(*(s.control_flow_statements for s in self.reachable(statements)))

    @synthesized
    def cfg(self, statements: {Statement.cfg,
                               Statement.is_reachable,
                               Statement.is_reachable_next}):
        if self.is_empty:
            return CfgSimple.empty()

        return CfgSimple.concatenate(*(s.cfg for s in self.reachable(statements)))


@production
class PlaceholderStatement(Statement):
    post_placeholder_arg = synthesized()

    @synthesized
    def changed_variables(self):
        return {RETURN_PLACEHOLDER_ID}

    @synthesized
    def variables_post(self): return {**self.variables_pre,
                                      RETURN_PLACEHOLDER_ID: self.post_placeholder_arg}

    @synthesized
    def post_placeholder_arg(self):
        return PlaceholderArg(" _ ")

    @synthesized
    def cfg(self):
        return CfgSimple.statements(
            ir.Goto(self, None, args=[self.variables_pre.get(RETURN_PLACEHOLDER_ID)]),
            ir.Placeholder(self),
            ir.Block(self, [self.post_placeholder_arg])
        )


class GotoMixin(VarStateMixin):
    """Mixin for handling transfer arguments for changed local variables"""

    # noinspection PyUnresolvedReferences
    def transfer_arguments(self, variables):
        result = []

        for var_id in variables:
            variable = self.resolve_reference(var_id)
            variable_name = (variable.name if variable else None)

            assert variable_name is not None or var_id == RETURN_PLACEHOLDER_ID

            argument = ir.Argument(self, info=variable_name, name=variable_name)

            if var_id == RETURN_PLACEHOLDER_ID:
                variable_name = "ResultPlaceholder"
                argument = PlaceholderArg(" _ ")  # TODO Fix naming
                argument.type_string = " _ "

            assignment = ir.Assignment(self, argument, variable_name, type_string=argument.type_string)
            result.append((var_id, argument, assignment))

        return result

    @staticmethod
    def get_arguments(variable_map, arguments):
        return [variable_map[a] for a, _, __ in arguments]

    def add_goto(self, cfg_builder, cfg_from, target, arg_values, only_if_appendable=False):
        if only_if_appendable and len(cfg_from.sinks_appendable) == 0:
            return cfg_builder

        goto = ir.Goto(self, target, arg_values)
        cfg_builder += CfgSimple.statement(goto)
        cfg_builder += (cfg_from.last_appendable, goto)
        cfg_builder += (goto, target)

        return cfg_builder


# region Control Flow

# noinspection PyMethodOverriding
@production
class IfStatement(Statement, GotoMixin):
    condition: Expression

    true_body: Statement
    false_body: Optional[Statement]

    arguments_join = synthesized()

    # region VarStateMixin
    @pushdown
    def push_variables(self, condition) -> VarStateMixin.variables_pre @ {true_body, false_body}:
        return condition.variables_post

    @synthesized
    def variables_post(self):
        if self.is_reachable_next:
            return {**self.variables_pre, **to_map(self.arguments_join, value=2)}

        # No common join available, variables_post makes no sense in this case
        # Return something anyway, since some rules still depend on reasonable
        # data being returned regardless of execution paths
        return {**self.variables_pre}

    @synthesized
    def changed_variables(self, true_body, false_body):
        # TODO: Variables can be considered as not changed if one of the branches returns from the function
        return (true_body.changed_variables if false_body is None else
                true_body.changed_variables | false_body.changed_variables)

    # endregion

    @synthesized
    def is_reachable_next(self, true_body, false_body):
        return true_body.is_reachable_next or (false_body is None or false_body.is_reachable_next)

    @synthesized
    def control_flow_statements(self, true_body, false_body):
        return (true_body.control_flow_statements if false_body is None else
                true_body.control_flow_statements | false_body.control_flow_statements)

    @synthesized
    def arguments_join(self):
        return self.transfer_arguments(self.changed_variables)

    @synthesized
    def cfg(self, condition, true_body, false_body):
        block_join = ir.Block(self, info="IF_JOIN", args=list(map(__[1], self.arguments_join)))
        block_true = ir.Block(true_body, info="IF_TRUE")
        block_false = ir.Block(false_body, info="IF_FALSE")

        args_true = self.get_arguments(true_body.variables_post, self.arguments_join)
        args_false = self.get_arguments(false_body.variables_post, self.arguments_join) if false_body else None
        args_false = args_false or self.get_arguments(condition.variables_post, self.arguments_join)

        branch = ir.Branch(self, condition.expression_value, block_true, block_false, [], [])

        cfg_true = true_body.cfg << block_true
        cfg_false = (false_body.cfg if false_body else CfgSimple.empty()) << block_false

        cfg_builder = condition.cfg >> branch >> (cfg_true, cfg_false)

        if self.is_reachable_next:
            cfg_builder += CfgSimple.statement(block_join)

            cfg_builder = self.add_goto(cfg_builder, cfg_true, block_join, args_true, only_if_appendable=True)
            cfg_builder = self.add_goto(cfg_builder, cfg_false, block_join, args_false, only_if_appendable=True)

            cfg_builder >>= CfgSimple.statements(*map(__[2], self.arguments_join))

        return cfg_builder


class LoopMixin(GotoMixin):
    continue_statements = synthesized()
    break_statements = synthesized()

    @synthesized
    def continue_statements(self, body):
        return [s for s in body.control_flow_statements if
                isinstance(s, ir.Goto) and
                isinstance(s.ast_node, Continue)]

    @synthesized
    def break_statements(self, body):
        return [s for s in body.control_flow_statements if
                isinstance(s, ir.Goto) and
                isinstance(s.ast_node, Break)]

    def join_breaks_and_continues(self, cfg_builder, block_cont, block_break):
        for cfs in self.continue_statements:
            cfg_builder += (cfs, block_cont)

        for cfs in self.break_statements:
            cfg_builder += (cfs, block_break)

        return cfg_builder


# noinspection PyMethodOverriding
@production
class WhileStatement(Statement, LoopMixin, GotoMixin):
    condition: Expression
    body: Statement

    # region VarStateMixin
    @pushdown
    def push_variables_to_condition(self, condition) -> VarStateMixin.variables_pre @ condition:
        return {**self.variables_pre, **to_map(self.arguments_cond, value=2)}

    @pushdown
    def push_variables_to_body(self, condition) -> VarStateMixin.variables_pre @ body:
        return condition.variables_post

    @synthesized
    def variables_post(self, body):
        if self.is_reachable_next:
            return {**body.variables_post, **to_map(self.arguments_join, value=2)}

        # No common join available, variables_post makes no sense in this case
        # Return something anyway, since some rules still depend on reasonable
        # data being returned regardless of execution paths
        return {**self.variables_pre}

    @synthesized
    def changed_variables(self, condition, body):
        return condition.changed_variables | body.changed_variables

    # endregion

    arguments_cond = synthesized()
    arguments_join = synthesized()

    @synthesized
    def arguments_cond(self):
        return self.transfer_arguments(self.changed_variables)

    @synthesized
    def arguments_join(self):
        return self.transfer_arguments(self.changed_variables)

    @pushdown
    def push_args_continue(self) -> Statement.required_arguments_continue @ All:
        return list(map(__[0], self.arguments_cond))

    @pushdown
    def push_args_break(self) -> Statement.required_arguments_break @ All:
        return list(map(__[0], self.arguments_join))

    @synthesized
    def cfg(self: {LoopMixin.break_statements, LoopMixin.continue_statements}, condition, body):
        block_loop = ir.Block(body, info="LOOP_BODY", args=[])
        block_cond = ir.Block(self, info="LOOP_COND", args=list(map(__[1], self.arguments_cond)))
        block_join = ir.Block(self, info="LOOP_JOIN", args=list(map(__[1], self.arguments_join)))

        args = self.get_arguments(condition.variables_post, self.arguments_join)
        branch = ir.Branch(self, condition.expression_value, block_loop, block_join, [], args)

        # Build Cond CFG
        cfg_cond = CfgSimple.statements(block_cond, *map(__[2], self.arguments_cond))
        cfg_cond >>= condition.cfg >> branch

        # Build Join CFG
        cfg_join_assignments = CfgSimple.statements(*map(__[2], self.arguments_join))
        cfg_join = cfg_join_assignments << block_join

        # Build Loop CFG
        cfg_loop = body.cfg << block_loop

        args = self.get_arguments(self.variables_pre, self.arguments_cond)
        cfg_builder = CfgSimple.statement(ir.Goto(self, block_loop, args))
        cfg_builder >>= cfg_cond
        cfg_builder >>= (cfg_loop, cfg_join)

        if body.is_reachable_next:  # Loop if end of loop is reachable
            args = self.get_arguments(body.variables_post, self.arguments_join)
            cfg_builder = self.add_goto(cfg_builder, cfg_loop, block_cond, args)

        return self.join_breaks_and_continues(cfg_builder, block_cond, block_join)


@production
class DoWhileStatement(Statement, LoopMixin, GotoMixin):
    condition: Expression
    body: Statement

    # region VarStateMixin
    @pushdown
    def push_variables_to_condition(self, condition) -> VarStateMixin.variables_pre @ condition:
        return self.body.variables_post # TODO: More testing

    @pushdown
    def push_variables_to_body(self, condition) -> VarStateMixin.variables_pre @ body:
        return {**self.variables_pre, **to_map(self.arguments_cond, value=2)} # TODO: More testing
        # return {**self.variables_pre, **to_map(self.arguments_cond, value=2)}

    @synthesized
    def variables_post(self, body):
        if self.is_reachable_next:
            return {**body.variables_post, **to_map(self.arguments_join, value=2)}

        # No common join available, variables_post makes no sense in this case
        # Return something anyway, since some rules still depend on reasonable
        # data being returned regardless of execution paths
        return {**self.variables_pre}

    @synthesized
    def changed_variables(self, condition, body):
        return condition.changed_variables | body.changed_variables

    # endregion

    arguments_cond = synthesized()
    arguments_join = synthesized()

    @synthesized
    def arguments_cond(self):
        return self.transfer_arguments(self.changed_variables)

    @synthesized
    def arguments_join(self):
        return self.transfer_arguments(self.changed_variables)

    @pushdown
    def push_args_continue(self) -> Statement.required_arguments_continue @ All:
        return list(map(__[0], self.arguments_cond))

    @pushdown
    def push_args_break(self) -> Statement.required_arguments_break @ All:
        return list(map(__[0], self.arguments_join))

    @synthesized
    def cfg(self: {LoopMixin.break_statements, LoopMixin.continue_statements}, condition, body):
        block_loop = ir.Block(body, info="LOOP_BODY", args=[])
        block_cond = ir.Block(self, info="LOOP_COND", args=list(map(__[1], self.arguments_cond)))
        block_join = ir.Block(self, info="LOOP_JOIN", args=list(map(__[1], self.arguments_join)))

        args = self.get_arguments(condition.variables_post, self.arguments_join)
        branch = ir.Branch(self, condition.expression_value, block_loop, block_join, [], args)

        # Build Cond CFG
        cfg_cond = CfgSimple.statements(block_cond, *map(__[2], self.arguments_cond))
        cfg_cond >>= condition.cfg >> branch

        # Build Join CFG
        cfg_join_assignments = CfgSimple.statements(*map(__[2], self.arguments_join))
        cfg_join = cfg_join_assignments << block_join

        # Build Loop CFG
        cfg_loop = body.cfg << block_loop

        args = self.get_arguments(self.variables_pre, self.arguments_cond)
        '''
        The graph should start with a goto expression. Notice that we need a second go to from the body to
        the condition otherwise the condition will be part of the body.
        '''

        cfg_builder = CfgSimple.statement(ir.Goto(self, block_loop, args))
        cfg_builder >>= cfg_loop
        cfg_builder >>= CfgSimple.statement(ir.Goto(self, block_cond, args))
        cfg_builder >>= cfg_cond
        cfg_builder >>= cfg_join

        if body.is_reachable_next:  # Loop if end of loop is reachable
            args = self.get_arguments(body.variables_post, self.arguments_join)
            cfg_builder = self.add_goto(cfg_builder, cfg_cond, block_loop, args)

        return self.join_breaks_and_continues(cfg_builder, block_cond, block_join)




# noinspection PyMethodOverriding
@production
class ForStatement(Statement, LoopMixin, GotoMixin):
    initialization_expression: Optional[SimpleStatement]
    loop_expression: Optional[ExpressionStatement]
    condition: Optional[Expression]
    body: Statement

    # region VarStateMixin
    variables_post_initialization = synthesized()
    variables_post_condition = synthesized()
    variables_post_body = synthesized()
    variables_post_step = synthesized()

    @synthesized
    def variables_post_initialization(self, initialization_expression):
        return initialization_expression.variables_post if initialization_expression else self.variables_pre

    @synthesized
    def variables_post_condition(self, condition):
        return condition.variables_post if condition else self.variables_post_initialization

    @synthesized
    def variables_post_body(self, body):
        return body.variables_post

    @synthesized
    def variables_post_step(self, loop_expression):
        return loop_expression.variables_post if loop_expression else self.variables_post_body

    @pushdown
    def push_vars_to_init(self) -> VarStateMixin.variables_pre @ initialization_expression:
        return self.variables_pre

    @pushdown
    def push_vars_to_cond(self) -> VarStateMixin.variables_pre @ condition:
        return {**self.variables_post_initialization, **to_map(self.arguments_cond, value=2)}

    @pushdown
    def push_vars_to_body(self) -> VarStateMixin.variables_pre @ body:
        return self.variables_post_condition

    @pushdown
    def push_vars_to_step(self) -> VarStateMixin.variables_pre @ loop_expression:
        return {**self.variables_post_body, **to_map(self.arguments_step, value=2)}

    @synthesized
    def variables_post(self, body: {VarStateMixin.variables_post}, loop_expression: {VarStateMixin.variables_post}):
        if self.is_reachable_next:
            return {**(loop_expression or body).variables_post, **to_map(self.arguments_join, value=2)}

        # No common join available, variables_post makes no sense in this case
        # Return something anyway, since some rules still depend on reasonable
        # data being returned regardless of execution paths
        return {**self.variables_pre}

    @pushdown
    def push_scope(self, initialization_expression) -> VarStateMixin.scope_pre @ {condition, body, loop_expression}:
        return initialization_expression.scope_post if initialization_expression else self.scope_pre

    @synthesized
    def changed_variables(self, initialization_expression, condition, body, loop_expression):
        changed_variables = set()

        if initialization_expression:
            changed_variables |= initialization_expression.changed_variables
        if condition:
            changed_variables |= condition.changed_variables
        if body:
            changed_variables |= body.changed_variables
        if loop_expression:
            changed_variables |= loop_expression.changed_variables

        return changed_variables

    # endregion

    arguments_cond = synthesized()
    arguments_step = synthesized()
    arguments_join = synthesized()

    @synthesized
    def arguments_cond(self):
        return self.transfer_arguments(self.changed_variables)

    @synthesized
    def arguments_step(self):
        return self.transfer_arguments(self.changed_variables)

    @synthesized
    def arguments_join(self):
        return self.transfer_arguments(self.changed_variables)

    @pushdown
    def push_args_continue(self) -> Statement.required_arguments_continue @ All:
        return list(map(__[0], self.arguments_step))

    @pushdown
    def push_args_break(self) -> Statement.required_arguments_break @ All:
        return list(map(__[0], self.arguments_join))

    @synthesized
    def cfg(self: {LoopMixin.break_statements, LoopMixin.continue_statements},
            initialization_expression, condition, body, loop_expression):
        condition_expression = condition.expression_value if condition else ir.Const(self, True)
        condition_cfg = condition.cfg if condition else CfgSimple.statement(condition_expression)

        block_body = ir.Block(body, info="FOR_BODY")  # Single in-edge, so no arguments
        block_step = ir.Block(body, info="FOR_STEP", args=list(map(__[1], self.arguments_step)))
        block_cond = ir.Block(self, info="FOR_COND", args=list(map(__[1], self.arguments_cond)))
        block_join = ir.Block(self, info="FOR_JOIN", args=list(map(__[1], self.arguments_join)))

        args_join = self.get_arguments(self.variables_post_condition, self.arguments_join)
        branch = ir.Branch(self, condition_expression, block_body, block_join, [], args_join)

        cfg_join_assignments = CfgSimple.statements(*(map(__[2], self.arguments_join)))
        cfg_step_assignments = CfgSimple.statements(*(map(__[2], self.arguments_step)))

        cfg_body = body.cfg << block_body
        cfg_join = cfg_join_assignments << block_join
        cfg_step = cfg_step_assignments << block_step
        cfg_step >>= (loop_expression.cfg if loop_expression else CfgSimple.empty())

        cfg_builder = CfgSimple.statement(ir.Comment(self, "FOR LOOP BEGIN"))
        if initialization_expression:
            cfg_builder >>= ir.Comment(self, "INITIALIZATION")
            cfg_builder >>= initialization_expression.cfg

        args_begin = self.get_arguments(self.variables_post_initialization, self.arguments_cond)
        cfg_builder >>= CfgSimple.statement(ir.Goto(self, block_cond, args_begin))
        cfg_builder >>= CfgSimple.statements(block_cond, *(map(__[2], self.arguments_cond)))
        cfg_builder >>= condition_cfg
        cfg_builder >>= branch
        cfg_builder >>= (cfg_body, cfg_join)

        step_reachable = body.is_reachable_next or self.continue_statements
        if step_reachable:
            cfg_builder += cfg_step
            args = self.get_arguments(self.variables_post_step, self.arguments_join)
            cfg_builder = self.add_goto(cfg_builder, cfg_step, block_cond, args)

            if body.is_reachable_next:  # Loop if end of loop is reachable
                args = self.get_arguments(body.variables_post, self.arguments_step)
                cfg_builder = self.add_goto(cfg_builder, cfg_body, block_step, args)

        cfg_builder = self.join_breaks_and_continues(cfg_builder, block_step, block_join)
        cfg_builder >>= ir.Comment(self, "FOR LOOP END")

        return cfg_builder


# @abstract_production
class FlowControlStatement(Statement):
    argument_values = synthesized()
    control_flow_statement = synthesized()

    @synthesized_once
    def control_flow_statement(self: FlowControlStatement.argument_values):
        return ir.Goto(self, None, args=[self.variables_pre[a] for a in self.argument_values])

    @synthesized
    def is_reachable_next(self): return False

    @synthesized
    def control_flow_statements(self): return {self.control_flow_statement}

    @synthesized
    def cfg(self): return CfgSimple.statement_terminal(self.control_flow_statement)


@production
class Continue(FlowControlStatement):
    @synthesized
    def argument_values(self): return self.required_arguments_continue


@production
class Break(FlowControlStatement):
    @synthesized
    def argument_values(self): return self.required_arguments_break


# endregion

@production
class Return(Statement):
    expression: Optional[Expression]

    @synthesized
    def changed_variables(self, expression):
        return set() if expression is None else expression.changed_variables

    @synthesized
    def is_reachable_next(self):
        return False

    @synthesized
    def cfg(self, expression: {TupleMixin.flattened_expression_values}):
        if self.is_part_of_modifier:
            placeholder = self.variables_pre[RETURN_PLACEHOLDER_ID]
            return CfgSimple.statement_terminal(ir.Return(self, [placeholder], self.variables_pre))

        if not expression:
            return CfgSimple.statement_terminal(ir.Return(self, [], self.variables_pre))

        return_arguments = as_array(
            expression.flattened_expression_values if isinstance(expression, TupleMixin) else
            expression.expression_value)

        return expression.cfg >> CfgSimple.statement_terminal(
            ir.Return(self, return_arguments, self.variables_pre))


@production
class Throw(Statement):
    @synthesized
    def is_reachable_next(self): return False

    @synthesized
    def cfg(self): return ir.NotImplementedNode("Throw")


@production
class EmitStatement(Statement):
    event_call: FunctionCall

    @synthesized
    def cfg(self, event_call):
        return event_call.cfg


# noinspection PyMethodOverriding
@production
class VariableDeclarationStatement(SimpleStatement):
    initial_value: Optional[Expression]
    declarations: List[Optional[VariableDeclaration]]

    new_variables = synthesized()
    """Variable map including newly introduced variables"""

    initializations = synthesized()
    """"""

    # region VarStateMixin
    @synthesized
    def new_variables(self, declarations: VariableDeclaration.default_value):
        return {**self.variables_pre, **{decl.id: decl.default_value
                                         for decl in declarations
                                         if decl is not None}}

    @pushdown
    def push_variables(self) -> VarStateMixin.variables_pre @ declarations:
        return self.new_variables

    @synthesized
    def variables_post(self, declarations):
        new_map = self.variables_pre.copy()
        for decl, value in reversed(list(zip(declarations, self.initializations))):
            if decl is not None:
                new_map[decl.id] = value

        return new_map

    @synthesized
    def scope_post(self, declarations):
        return self.scope_pre | {d.id for d in declarations if d is not None}

    @synthesized
    def changed_variables(self, initial_value):
        return initial_value.changed_variables if initial_value is not None else set()

    # endregion VarStateMixin

    @synthesized
    def initializations(self,
                        initial_value: {TupleMixin.flattened_expression_values},
                        declarations: {VariableDeclaration.default_value}):
        if initial_value is None:
            return [ir.Assignment(d, d.default_value, d.name, type_string=d.type_string)
                    for d in declarations if d is not None]

        initial_values = as_array(
            initial_value.flattened_expression_values if isinstance(initial_value, TupleMixin) else
            initial_value.expression_value)

        assert len(declarations) == len(initial_values), (len(declarations), len(initial_values))
        return [ir.Assignment(decl, init, decl.name, type_string=decl.type_string) for decl, init in
                zip(declarations, initial_values) if decl is not None]

    @synthesized
    def cfg(self, initial_value, declarations: {TypeName.default_value}):
        return (CfgSimple.statements(*self.initializations) << initial_value.cfg if initial_value else
                CfgSimple.statements(*self.initializations) << CfgSimple.concatenate(
                    *(d.default_value for d in declarations if d is not None)))


@production
class ExpressionStatement(SimpleStatement):
    expression: Expression

    @synthesized
    def cfg(self, expression):
        return expression.cfg

    # noinspection PyMethodOverriding
    @synthesized
    def variables_post(self, expression):
        return expression.variables_post

    @synthesized
    def changed_variables(self, expression):
        return expression.changed_variables

    @pushdown
    def expression_value_used(self) -> Expression.expression_value_used @ expression:
        return False


class TupleMixin:
    type_descriptions: dict

    flattened_expression_values = synthesized()
    """Flattened expression values of a (nested) tuple like expression"""

    result_arity = synthesized()

    @synthesized
    def result_arity(self):
        return parse_tuple_components(self.type_descriptions["typeString"])


# noinspection PyMethodOverriding
@production
class Conditional(Expression, TupleMixin, GotoMixin):
    true_expression: Expression
    false_expression: Expression
    condition: Expression

    # region VarStateMixin
    @pushdown
    def push_variables(self, condition) -> VarStateMixin.variables_pre @ {true_expression, false_expression}:
        return condition.variables_post

    @synthesized
    def variables_post(self, condition):
        return {**condition.variables_post}

    @synthesized
    def changed_variables(self, condition, true_expression, false_expression):
        return condition.changed_variables | true_expression.changed_variables | false_expression.changed_variables

    # endregion

    @synthesized
    def expression_value(self):
        if len(self.flattened_expression_values) == 1:
            return self.flattened_expression_values[0]

        return UndefinedAttribute("Use flattened_expression_values instead")

    @synthesized
    def flattened_expression_values(self):
        return [ir.Argument(self) for _ in range(self.result_arity)]

    @synthesized
    def cfg(self, condition,
            true_expression: {TupleMixin.flattened_expression_values},
            false_expression: {TupleMixin.flattened_expression_values}):
        block_true = ir.Block(self, info="?: TRUE")
        block_false = ir.Block(self, info="?: FALSE")
        block_join = ir.Block(self, info="?: JOIN", args=self.flattened_expression_values)
        branch = ir.Branch(self, condition.expression_value, block_true, block_false, [], [])

        cfg_true = true_expression.cfg << block_true
        cfg_false = false_expression.cfg << block_false

        cfg_builder = condition.cfg >> branch
        cfg_builder >>= (cfg_true, cfg_false)

        cfg_builder += CfgSimple.statement(block_join)

        values_true = true_expression.expression_value or true_expression.flattened_expression_values
        values_false = false_expression.expression_value or false_expression.flattened_expression_values

        cfg_builder = self.add_goto(cfg_builder, cfg_true, block_join, as_array(values_true))
        cfg_builder = self.add_goto(cfg_builder, cfg_false, block_join, as_array(values_false))

        return cfg_builder


# TODO:
# def add_rule_pass_variables(node_from, node_to):
#     def push_variables(self, node_from):
#
#         return variables
#
#     inherited(push_variables)


# noinspection PyMethodOverriding
@production
class Assignment(Expression):
    left_hand_side: Expression
    right_hand_side: Expression

    operator: str

    assignments = synthesized()
    """Assignments objects"""

    assignments_local = synthesized()
    """Assignments to local variables without mapping / array / storage indirections"""

    lvalue_operation = synthesized()
    """Operation object associated to this assignment (+=, -=, etc.) if applicable"""

    # TODO: add_rule_pass_variables("left_hand_side", "Assignment.right_hand_side")

    @property
    def is_l_value_operator(self):
        return self.operator != '='

    # region VarStateMixin
    @synthesized
    def variables_post(self):
        new_variables = self.variables_pre.copy()

        for identifier, assignment in self.assignments_local:
            new_variables[identifier.referenced_declaration] = assignment

        return new_variables

    @synthesized
    def changed_variables(self, left_hand_side: {TupleExpression.flattened_expressions}):
        lhs = as_array(left_hand_side.flattened_expressions if isinstance(left_hand_side, TupleExpression) else
                       left_hand_side)

        return {i.referenced_declaration for i in lhs if self.is_local_variable(i)}

    # endregion

    @synthesized
    def lvalue_operation(self, left_hand_side, right_hand_side):
        if not self.is_l_value_operator:
            return UndefinedAttribute("Assignment is not an LValue-Operator")

        return ir.BinaryOp(self, self.operator[:-1],
                           left_hand_side.expression_value,
                           right_hand_side.expression_value, self.type_string)

    @synthesized
    def assignments(self,
                    left_hand_side: {TupleExpression.flattened_assignment_generators,
                                     TupleExpression.assignment_generator},
                    right_hand_side: {TupleExpression.flattened_expression_values,
                                      TupleExpression.expression_value}):
        lhs = left_hand_side
        rhs = right_hand_side

        lhs_flattened = as_array(
            lhs.flattened_assignment_generators if isinstance(lhs, TupleExpression) else
            lhs.assignment_generator)

        rhs_flattened = as_array(
            rhs.flattened_expression_values if isinstance(rhs, TupleMixin) else
            rhs.expression_value)

        if not isinstance(self.lvalue_operation, UndefinedAttribute):
            rhs_flattened = [self.lvalue_operation]

        assert len(lhs_flattened) == len(rhs_flattened)

        # Solidity does the assignment in reverse order
        # due to the order of rhs expression values on the stack
        lhs_gen_rhs = reversed(list(zip(lhs_flattened, rhs_flattened)))

        return [gen_assignment(self, rhs) for gen_assignment, rhs in lhs_gen_rhs]

    @synthesized
    def assignments_local(self, left_hand_side: {TupleExpression.flattened_expressions}):
        lhs = left_hand_side
        lhs = as_array(lhs.flattened_expressions if isinstance(lhs, TupleExpression) else
                       lhs)

        lhs = reversed(lhs)  # Don't forget to reverse!! (c.f. reverse in assignments)

        return [(i, a) for i, a in zip(lhs, self.assignments)
                if isinstance(i, Identifier) and i.referenced_declaration in self.variables_pre]

    @synthesized
    def expression_value(self):
        if len(self.assignments) == 1:
            return self.assignments[0]

        return UndefinedAttribute("Tuple-typed assignments cannot be used as RHS for an assignment")

    @synthesized
    def cfg(self, left_hand_side: {LValueMixin.cfg_lhs}, right_hand_side):
        cfg = CfgSimple.empty()

        cfg >>= right_hand_side.cfg
        cfg >>= left_hand_side.cfg_lhs

        if self.is_l_value_operator:
            cfg >>= left_hand_side.cfg - left_hand_side.cfg_lhs  # TODO: Review this
            cfg >>= self.lvalue_operation

        cfg >>= CfgSimple.statements(*self.assignments)

        return cfg


class LValueMixin:
    assignment_generator = synthesized()
    """A function that returns an assignment expression for this l-value"""

    cfg_lhs = synthesized(default=UndefinedAttribute("LHS cfg not applicable"))
    """CFG of this expression used as l-value (i.e. CFG of the expression w/out value retrieval)"""


# noinspection PyMethodOverriding
@production
class TupleExpression(PrimaryExpression, TupleMixin, LValueMixin):
    components: List[Expression]

    flattened_expressions = synthesized()
    flattened_expression_values = synthesized()
    flattened_assignment_generators = synthesized()

    # region VarStateMixin
    @pushdown
    def variables_map(self) -> Statement.variables_pre @ components:
        return self.variables_pre

    @pushdown
    def variables_map_step(self: ListElement[TupleExpression, "components"]) -> Expression.variables_pre @ next:
        return self.variables_post

    @synthesized
    def variables_post(self, components: {Statement.variables_post}):
        if len(components) == 0:
            return self.variables_pre

        return components[-1].variables_post

    @synthesized
    def changed_variables(self, components: {VarStateMixin.changed_variables}):
        return set().union(*(c.changed_variables for c in components))

    # endregion

    @synthesized
    def flattened_expressions(self, components: {TupleExpression.flattened_expressions}):
        if self.is_inline_array:
            return [self]

        return flatten(*(c.flattened_expressions if isinstance(c, TupleExpression) else
                         c for c in components))

    @synthesized
    def flattened_expression_values(self, components: {TupleMixin.flattened_expression_values,
                                                       Expression.expression_value}):
        values = flatten(*(
            c.flattened_expression_values if isinstance(c, TupleMixin) else
            c.expression_value for c in components))

        if self.is_inline_array:
            return [ir.Array(self, values)]

        return values

    @synthesized
    def flattened_assignment_generators(self, components: {TupleExpression.flattened_assignment_generators,
                                                           LValueMixin.assignment_generator}):
        if self.is_inline_array:
            return []

        return flatten(*(
            c.flattened_assignment_generators if isinstance(c, TupleExpression) else
            c.assignment_generator for c in components))

    @synthesized
    def expression_value(self, components: {Expression.expression_value}):
        if len(components) == 1:
            return components[0].expression_value

        return UndefinedAttribute(
            info="Tuple expression_value must not be used directly. "
                 "Use flattened_expression_values instead.")

    @synthesized
    def assignment_generator(self):
        return UndefinedAttribute(info="Use flattened_assignment_generators instead.")

    @synthesized
    def cfg(self, components: AstNode.cfg):
        if self.is_inline_array:
            return CfgSimple.concatenate(*[c.cfg for c in components]) >> \
                   self.flattened_expression_values[0]

        return CfgSimple.concatenate(*[c.cfg for c in components])

    @synthesized
    def cfg_lhs(self, components: LValueMixin.cfg_lhs):
        return CfgSimple.concatenate(*[c.cfg_lhs for c in filter_by_type(components, LValueMixin)])


# noinspection PyMethodOverriding
@production
class UnaryOperation(Expression):
    sub_expression: Expression
    operator: str
    prefix: bool

    expression_value_post = synthesized()
    """Expression value after operator application"""

    cfg_assignment = synthesized()
    """Expression value after operator application"""

    is_local_variable_altered = synthesized()
    """Id of changed local variable or none"""

    @synthesized
    def is_local_variable_altered(self):
        return self.operator in {'++', '--'} and self.is_local_variable(self.sub_expression)

    # region VarStateMixin
    @synthesized
    def variables_post(self, sub_expression):
        if not self.is_local_variable_altered:
            return self.variables_pre

        return {**self.variables_pre, sub_expression.referenced_declaration: self.cfg_assignment}

    @synthesized
    def changed_variables(self, sub_expression):
        return {sub_expression.referenced_declaration} if self.is_local_variable_altered else set()

    # endregion

    @synthesized
    def expression_value_post(self, sub_expression):
        op = self.operator
        if op in {'++', '--'}:
            return ir.BinaryOp(self, op[0],
                               sub_expression.expression_value,
                               ir.Const(self, 1, "int_const 1"), self.type_string)  # x + 1
        elif op in {'-'}:
            return ir.BinaryOp(self, op,
                               ir.Const(self, 0, "int_const 1"),
                               sub_expression.expression_value, self.type_string)  # 0 - x

        elif op in {'!', '~'}:
            return ir.UnaryOp(self, op, sub_expression.expression_value, self.type_string)
        elif op == 'delete':
            return ir.UnaryOp(self, op, sub_expression.expression_value, None)  # delete x

        raise NotImplementedError(f"Unknown unary operator {op}")

    @synthesized
    def expression_value(self, sub_expression):
        return self.expression_value_post if self.prefix else sub_expression.expression_value

    @synthesized
    def cfg_assignment(self, sub_expression: LValueMixin.assignment_generator):
        if self.operator in {'++', '--'}:
            return sub_expression.assignment_generator(self, self.expression_value_post)

        return CfgSimple.empty()  # Operation does not affect anything

    @synthesized
    def cfg(self, sub_expression):
        cfg = CfgSimple.empty()

        # Include CFG for literals
        if self.operator in {'++', '--'}:
            cfg >>= self.expression_value_post.rhs
        elif self.operator in {'-'}:
            cfg >>= self.expression_value_post.lhs

        return cfg >> CfgSimple.concatenate(
            sub_expression.cfg,
            self.expression_value_post,
            self.cfg_assignment
        )


# noinspection PyMethodOverriding
@production
class BinaryOperation(Expression):
    left_expression: Expression
    right_expression: Expression

    operator: str

    # region VarStateMixin
    @pushdown
    def push_variables(self, left_expression) -> VarStateMixin.variables_pre @ right_expression:
        return left_expression.variables_post

    @synthesized
    def variables_post(self, right_expression):
        return right_expression.variables_post

    @synthesized
    def changed_variables(self, left_expression, right_expression):
        return left_expression.changed_variables | right_expression.changed_variables

    # endregion

    @synthesized_once
    def expression_value(self, left_expression, right_expression):
        return ir.BinaryOp(self,
                           self.operator,
                           left_expression.expression_value,
                           right_expression.expression_value, self.type_string)

    @synthesized
    def cfg(self, left_expression, right_expression):
        return left_expression.cfg >> right_expression.cfg >> self.expression_value


@production
class FunctionCall(Expression, TupleMixin):
    expression: Expression
    arguments: List[Expression]
    names: List[str]  # TODO: Named arguments

    # TODO: Propagate and update variables

    is_local = synthesized()
    """Does this call translate to an internal jump?"""

    call_type = synthesized()
    """Function invocation, global function invocation, new expr, struct constructor or typecast?"""

    call_info = synthesized()

    @synthesized
    def call_info(self, arguments: {Expression.expression_value,
                                    Expression.cfg}):
        argument_values = [a.expression_value for a in arguments]
        argument_cfgs = [a.cfg for a in arguments]

        return FunctionCallInfo(self, argument_values, argument_cfgs, self.result_arity)

    @synthesized
    def is_local(self, expression):
        return expression.type_descriptions["typeIdentifier"].startswith("t_function_internal")

    @synthesized
    def call_type(self, expression: {Expression.expression_value}):
        return ('conversion' if self.kind == 'typeConversion' else
                'constructor' if self.kind == 'structConstructorCall' else
                'builtin' if isinstance(expression.expression_value, CallableImpl) else
                'new' if isinstance(expression, NewExpression) else
                'jump')

    @synthesized
    def expression_value(self):
        if self.result_arity == 1:
            return self.flattened_expression_values[0]

        return UndefinedAttribute(
            "expression_value is not applicable for "
            "FunctionCalls with tuple-typed return values. "
            "Please use flattened_expression_values instead.")

    @synthesized
    def flattened_expression_values(self, expression, arguments: {TupleMixin.flattened_expression_values,
                                                                  Expression.expression_value}):
        if self.call_type == 'conversion':
            assert len(arguments) == 1

            return as_array(
                arguments[0].flattened_expression_values if isinstance(arguments[0], TupleMixin) else
                arguments[0].expression_value)

        if self.call_type == 'constructor':
            return [ir.Const(self, "New Struct")]  # TODO

        if self.call_type == 'new':
            return [expression.expression_value]

        if self.call_type == 'builtin':
            builtin: CallableImpl = expression.expression_value
            builtin.setup(self.call_info)

            return builtin.flattened_expression_values

        return [ir.Argument(self) for _ in range(self.result_arity)]

    @synthesized
    def cfg(self,
            expression: {MemberAccess.base_expression_value,
                         MemberAccess.base_expression_cfg},
            arguments: {Expression.expression_value,
                        Expression.cfg}):
        cfg = CfgSimple.concatenate(*map(__.cfg, arguments))

        if self.call_type == 'conversion':
            pass
        elif self.call_type == 'constructor':
            cfg >>= expression.cfg
            cfg >>= self.flattened_expression_values[0]  # TODO: Implement correct behaviour
        elif self.call_type == 'new':
            cfg >>= expression.cfg
            cfg >>= self.flattened_expression_values[0]  # TODO: Implement correct behaviour
        elif self.call_type == 'builtin':
            builtin: CallableImpl = expression.expression_value
            builtin.setup(self.call_info)
            cfg >>= builtin.cfg
        elif self.call_type == 'jump':
            assert self.is_local

            cont = ir.Block(self, self.flattened_expression_values, info="CONTINUATION")
            arg_values = [arg.expression_value for arg in arguments]

            pre, transfer, continuation = self.cfg_jump(expression, cont, arg_values)

            cfg >>= pre >> CfgSimple.statements(transfer, continuation)
        else:
            raise NotImplementedError()

        return cfg

    def cfg_jump(self, expression, cont, arg_values):
        if isinstance(expression, MemberAccess):
            base = expression.expression

            if isinstance(base, Identifier) and base.name == "this":
                dest = ir.JumpDestination(expression, expression.expression.name)
            else:
                dest = ir.JumpDestination(expression, expression.member_name)

        elif isinstance(expression, Identifier):
            if isinstance(expression.resolve(), FunctionDefinition):
                dest = ir.JumpDestination(expression, expression.name)
            else:
                raise CfgCompilationNotSupportedError("Function variables not yet supported")

        else:
            raise NotImplementedError("Function call to unexpected element", expression)

        transfer = ir.Jump(self, dest, cont, arg_values, self.names)

        return CfgSimple.empty(), transfer, cont


@production
class NewExpression(Expression):
    @synthesized
    def expression_value(self):
        return ir.Const(self, "NEW", self.type_string)

    @synthesized
    def cfg(self):
        return CfgSimple.empty()


@production
class MemberAccess(Expression, LValueMixin):
    expression: Expression
    member_name: str

    base_expression_cfg = synthesized()
    base_expression_value = synthesized()

    @synthesized
    def base_expression_value(self, expression):
        return expression.expression_value

    @synthesized
    def base_expression_cfg(self, expression):
        return expression.cfg

    @synthesized
    def expression_value(self, expression: {Expression.expression_value}):
        expression_value = expression.expression_value

        # This would be the standard MemberLoad node for this MemberAccess
        # However there might be situations where we want to return something
        # more specific (e.g. bound functions, magic variables, array-builtins,
        # address-builtins, etc.)
        member_load_args = {
            "ast_node": self,
            "base": expression_value,
            "member": self.member_name,
            "type_string": self.type_string,
        }
        member_load = ir.MemberLoad(**member_load_args)

        if expression.type_string in {"address", "address payable"}:
            if self.member_name == "balance":
                return ir.Balance(self, expression_value)

        bound_function_args = (self,
                               self.base_expression_value,
                               self.base_expression_cfg,
                               member_load_args)

        if isinstance(expression_value, BoundFunctionBase):
            if self.member_name == "value":
                return ValueSpecifier(*bound_function_args)

            if self.member_name == "gas":
                return GasSpecifier(*bound_function_args)

        if hasattr(expression_value, "value") and expression_value.value == "NEW":
            if self.member_name == "value":
                return BoundLowLevelValueCall(*bound_function_args)

        if hasattr(self, "referenced_declaration") and self.resolve_reference(self.referenced_declaration) is not None:
            declaration = self.resolve_reference(self.referenced_declaration)
            defining_contract = declaration.find_ancestor_of_type(ContractDefinition)

            if isinstance(declaration, FunctionDefinition):
                if defining_contract.contract_kind == "library":
                    if self.expression.type_identifier.startswith("t_type$_t_"):  # direct library call
                        return LibraryFunction(self)
                    else:
                        return BoundLibraryFunction(*bound_function_args)

                is_internal = self.type_descriptions["typeIdentifier"].startswith("t_function_internal")

                if is_internal:
                    # TODO: returning any non-BoundFunctionBase node will make the FunctionCall
                    #       logic default to standard jumps. This should be handled better though
                    return ir.NotImplementedNode(self, "FunctionRef")
                else:
                    if isinstance(declaration, FunctionDefinition):
                        return BoundFunction(*bound_function_args)

            elif isinstance(declaration, VariableDeclaration):
                parent = self.parent()

                # Public Accessors
                if isinstance(declaration, VariableDeclaration) and isinstance(parent, ast.FunctionCall):
                    if parent.expression == self:  # exclude the case that we're in the arguments
                        # return ExternalMemberAccess(member_load, self.base_expression_cfg >> member_load)
                        return BoundFunction(*bound_function_args)

            elif isinstance(declaration, EventDefinition):
                return EventCallable(declaration)

        # TODO: does this require soem more checks?
        builtin_call_types = {
            "send": BoundSendCall,
            "transfer": BoundTransferCall,
            "call": BoundLowLevelCall,
            "delegatecall": BoundDelegateCallable,
        }

        if self.member_name in builtin_call_types:
            return builtin_call_types[self.member_name](*bound_function_args)

        # Resolve Enums
        if isinstance(expression, (Identifier, MemberAccess)):
            declaration = self.resolve_reference(expression.referenced_declaration)
            if isinstance(declaration, EnumDefinition):
                return ir.Const(self, declaration.canonical_name_of(self.member_name))

        # Array builtins
        if expression.type_identifier.startswith("t_array$") or expression.type_identifier.startswith("t_bytes"):
            if self.member_name == "push":
                return PushBuiltin(expression_value, expression.cfg)
            elif self.member_name == "length":
                return ir.UnaryOp(self, "length", expression_value)

        # Magic Variables msg._, tx._, block._, abi._
        if isinstance(expression_value, ir.MagicVariable):
            magic = expression_value

            prop_struct = builtin_map_nested[magic.variable]
            prop = prop_struct.get(self.member_name, None)

            if prop is None:
                raise CfgCompilationError(f"Could not resolve property '{self.member_name}' in '{self.src_code}'")

            if issubclass(prop, SolidityBuiltInFunction):
                return prop()

            return prop(self)

        return member_load

    @synthesized
    def assignment_generator(self, expression):
        ev = expression.expression_value

        def assignment(ast_node, expression):
            return ir.MemberStore(ast_node, ev, self.member_name, expression)

        return assignment

    @synthesized
    def cfg(self, expression):
        # TODO: This is a hack that prevents the creation of CFG nodes for
        #       Contract-Qualified enum values. E.g. for `Contract.Enum.value`
        #       we only want to generate the CFG containing the Constant enum
        #       value and no nodes for `Contract.Enum`
        if isinstance(expression, (Identifier, MemberAccess)):
            declaration = self.resolve_reference(expression.referenced_declaration)
            if isinstance(declaration, EnumDefinition):
                return CfgSimple.statement(self.expression_value)

        return expression.cfg >> self.expression_value

    @synthesized
    def cfg_lhs(self, expression):
        return expression.cfg


@production
class IndexAccess(Expression, LValueMixin):
    base_expression: Expression
    index_expression: Expression

    # region VarStateMixin
    # TODO: track changed variables here
    # endregion

    @synthesized
    def expression_value(self, base_expression, index_expression):
        if base_expression.type_descriptions['typeString'].startswith('mapping'):
            return ir.MappingLoad(self,
                                  base_expression.expression_value,
                                  index_expression.expression_value, self.type_string)
        else:
            return ir.ArrayLoad(self,
                                base_expression.expression_value,
                                index_expression.expression_value, self.type_string)

    @synthesized
    def assignment_generator(self, base_expression, index_expression):
        bev = base_expression.expression_value
        iev = index_expression.expression_value

        if base_expression.type_descriptions['typeString'].startswith('mapping'):
            def assignment(ast_node, expression):
                return ir.MappingStore(ast_node, bev, iev, expression)
        else:
            def assignment(ast_node, expression):
                return ir.ArrayStore(ast_node, bev, iev, expression)

        return assignment

    @synthesized
    def cfg(self, base_expression, index_expression):
        return index_expression.cfg >> base_expression.cfg >> self.expression_value

    @synthesized
    def cfg_lhs(self, base_expression, index_expression):
        return index_expression.cfg >> base_expression.cfg


# noinspection PyMethodOverriding
@production
class Identifier(PrimaryExpression, LValueMixin):
    name: str
    referenced_declaration: int

    is_local = synthesized()
    """Is this a local variable?"""

    def resolve(self) -> AstNode:
        return self.resolve_reference(self.referenced_declaration)

    @synthesized
    def is_local(self):
        return self.referenced_declaration in self.variables_pre

    @synthesized
    def expression_value(self):
        declaration = self.resolve()

        if not declaration:  # Magic variable or global function
            if self.name in builtin_map:
                return builtin_map[self.name]()

            if self.name == "now":
                return ir.Timestamp(self)

            if self.name == "this":
                return ir.This(self)

            if self.name in {"msg", "tx", "block", "abi"}:
                return ir.MagicVariable(self, self.name)

            if self.name in {"super"}:
                return ir.MagicVariable(self, self.name)

            raise CfgCompilationError(f"Unresolvable symbol {self.name}")

        if isinstance(declaration, VariableDeclaration):
            if declaration.state_variable:
                return ir.StateVariableLoad(self,
                                            declaration.id,
                                            declaration.name,
                                            declaration.qualified_name,
                                            self.type_string)
            else:
                if self.referenced_declaration not in self.variables_pre:
                    raise CfgCompilationError(
                        f"Unresolvable reference '{self.name}' with ID {self.referenced_declaration}")

                return self.variables_pre[self.referenced_declaration]

        if isinstance(declaration, FunctionDefinition):
            return ir.NotImplementedNode(self, "FunctionRef")

        if isinstance(declaration, ContractDefinition):
            return ir.NotImplementedNode(self, "ContractRef")

        if isinstance(declaration, EnumDefinition):
            return ir.NotImplementedNode(self, "EnumRef")

        if isinstance(declaration, StructDefinition):
            return ir.NotImplementedNode(self, "StructRef")

        if isinstance(declaration, EventDefinition):
            return EventCallable(declaration)

        raise CfgCompilationError(f"Unknown declaration {self.name}")

    @synthesized
    def assignment_generator(self):
        is_local = self.is_local

        def assignment(ast_node, expression_value):
            if is_local:
                return ir.Assignment(ast_node, expression_value, self.name, type_string=self.type_string)
            else:
                # noinspection PyTypeChecker
                declaration: VariableDeclaration = self.resolve()

                return ir.StateVariableStore(
                    ast_node,
                    declaration.id,
                    declaration.name,
                    declaration.qualified_name,
                    expression_value,
                    type_string=self.type_string)

        assignment.__qualname__ = f"Assignment_Generator_{self.name}"

        return assignment

    @synthesized
    def cfg(self):
        declaration = self.resolve_reference(self.referenced_declaration)

        if not declaration:  # Magic variable or global function
            # TODO: handle this better
            if isinstance(self.expression_value, ir.MagicVariable):
                return CfgSimple.statement(self.expression_value)

            return CfgSimple.empty()

        if isinstance(declaration, VariableDeclaration):
            if declaration.state_variable:
                return CfgSimple.statement(self.expression_value)
            else:
                return CfgSimple.empty()

        return CfgSimple.empty()

    @synthesized
    def cfg_lhs(self):
        return CfgSimple.empty()


@production
class ElementaryTypeNameExpression(PrimaryExpression):
    # TODO: what do we return here?
    #       note: this is used in `abi.decode(returndata, (bool))`
    @synthesized
    def expression_value(self):
        if str(self._solc_version).startswith('0.6.'):
            # TODO: We need a better way
            return ir.TypeRef(self, self.src_code)
        return ir.TypeRef(self, self.type_name)

    @synthesized
    def cfg(self):
        return self.expression_value


@production
class Literal(PrimaryExpression):
    @synthesized
    def expression_value(self):
        if "string" in self.type_descriptions["typeString"]:
            return ir.Const(self, self.value, self.type_string)
        elif "rational" in self.type_descriptions["typeString"] or is_float(self.value):
            return ir.Const(self, Decimal(self.value), self.type_string)
        elif "int" in self.type_descriptions["typeString"] \
                or "address payable" in self.type_descriptions["typeString"] \
                or "address" in self.type_descriptions["typeString"]:
            if self.value.startswith("0x"):
                return ir.Const(self, int(self.value, 16), self.type_string)
            else:
                return ir.Const(self, int(self.value, 10), self.type_string)
        elif "bool" in self.type_descriptions["typeString"]:
            return ir.Const(self, self.value.strip().lower() == "true", self.type_string)

        raise NotImplementedError(self.type_descriptions)

    @synthesized
    def cfg(self):
        return CfgSimple.statement(self.expression_value)  # CfgSimple.empty()
