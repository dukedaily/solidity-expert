from __future__ import annotations

from securify.grammar.attributes.annotations3 import *
from securify.ir.utils import ExclusiveDeepCopy
from .solidity_grammar_core import *


def get_constructor(source):
    if isinstance(source, list):
        return find(of_type[FunctionDefinition](source), lambda x: x.is_constructor)
    else:
        return get_constructor(source.nodes)


def uses_default_constructor(contract: ContractDefinition):
    constructor = get_constructor(contract)
    return constructor is None or not constructor.arguments


@dataclass
class ConstructorChain(ExclusiveDeepCopy):
    @property
    def dont_copy(self):
        return ["contract_ast"]

    contract_ast: ContractDefinition

    entry_arguments: List[ir.Argument]

    initializations: Dict[int, CfgSimple]
    invocations: Dict[int, CfgSimple]

    def with_arguments(self, arguments):
        return deepcopy_with_mapping(self, zip(self.entry_arguments, arguments))

    def cfg_entry_block(self, name=None):
        arguments = deepcopy(self.entry_arguments)
        block = ir.Block(self.contract_ast, arguments, name)
        return block

    def cfg_with_arguments(self, arguments, linearized_contracts):
        try:
            assert all(c in self.initializations for c in linearized_contracts)
            assert all(c in self.invocations for c in linearized_contracts)
        except:  # TODO: define behaviour
            return None

        cfg = CfgSimple.concatenate(
            *(self.initializations[c] for c in linearized_contracts),
            *(self.invocations[c] for c in reversed(linearized_contracts)))

        cfg = deepcopy_with_mapping(cfg, zip(self.entry_arguments, arguments))

        return cfg


def sort_modifier_arguments(modifier_arguments, linearized_base_contracts):
    sorted_modifiers = []

    for c in linearized_base_contracts:
        modifier = find(modifier_arguments,
                        lambda a: a[0].modifier_name.referenced_declaration == c)

        if modifier:
            sorted_modifiers.append(modifier)

    return sorted_modifiers


with rules_for(ContractDefinition):
    @synthesized
    def cfg_constructor_chain(self: ContractDefinition,
                              nodes: {FunctionDefinition.cfg,
                                      FunctionDefinition.modifier_arguments},
                              base_contracts: {InheritanceSpecifier.argument_cfgs}):

        this_constructor = get_constructor(nodes)

        arguments = []

        if this_constructor:
            arguments = deepcopy([a[1] for a in this_constructor.arguments])

        arguments_updated = arguments

        initializations = {}
        invocations = {}

        # Register invocations via InheritanceSpecifier
        inheritance_specifier: InheritanceSpecifier
        for inheritance_specifier in base_contracts:
            base_contract = inheritance_specifier.resolve()
            if inheritance_specifier.arguments or uses_default_constructor(base_contract):
                base_chain: ConstructorChain = self.cfgs_constructors[inheritance_specifier.referenced_declaration]

                (cfg, ev) = unzip2(inheritance_specifier.argument_cfgs or [])

                base_chain = base_chain.with_arguments(ev)

                initializations.update(base_chain.initializations)
                invocations.update(base_chain.invocations)

                initializations[base_contract.id] = CfgSimple.concatenate(*cfg)
                initializations[base_contract.id] <<= ir.Comment(None, base_contract.name + " INIT")

        # Register invocations via Modifier Syntax
        if this_constructor:
            sorted_modifiers = sort_modifier_arguments(
                this_constructor.modifier_arguments,
                self.linearized_base_contracts)

            for modifier, (cfg, evs) in sorted_modifiers:
                base_contract_id = modifier.modifier_name.referenced_declaration
                base_contract = modifier.modifier_name.resolve()
                base_chain: ConstructorChain = self.cfgs_constructors[base_contract_id]

                block = cfg.first
                cfg = cfg.remove(block)

                (cfg, evs) = deepcopy_with_mapping((cfg, evs), zip(block.args, arguments_updated))

                goto = cfg.last_appendable
                cfg = cfg.remove(goto)

                arguments_updated = goto.args

                base_chain = base_chain.with_arguments(evs)
                initializations.update(base_chain.initializations)
                invocations.update(base_chain.invocations)

                initializations[base_contract.id] = cfg
                initializations[base_contract.id] <<= ir.Comment(None, base_contract.name + " INIT")

        # Register invocation of this constructor's logic
        if this_constructor:
            this_continuation = ir.Block(self)
            this_dest = ir.JumpDestination(None, this_constructor.id)
            this_jump = ir.Jump(self, this_dest, this_continuation, arguments_updated)

            this_invocation = CfgSimple.statements(this_jump, this_continuation)

            invocations[self.id] = this_invocation
            initializations[self.id] = CfgSimple.empty()
        else:
            invocations[self.id] = CfgSimple.empty()
            initializations[self.id] = CfgSimple.empty()

        return ConstructorChain(self,
                                arguments,
                                initializations,
                                invocations)


    @synthesized
    def cfg_constructor(self: ContractDefinition):
        constructor_chain: ConstructorChain = self.cfg_constructor_chain

        cfg = CfgSimple.empty()

        cfg_entry_block = constructor_chain.cfg_entry_block()
        cfg_main_block = constructor_chain.cfg_with_arguments(
            cfg_entry_block.args, self.linearized_base_contracts)

        cfg >>= cfg_entry_block
        cfg >>= self.cfg_state_init

        if cfg_main_block:  # TODO: check
            cfg >>= cfg_main_block

        cfg >>= ir.Return(self)

        return cfg


    @synthesized
    def cfg_local_state_init(self, nodes: {VariableDeclaration.initialization_cfg,
                                           VariableDeclaration.initialization}):
        def get_store(s: ast.VariableDeclaration):
            store = ir.StateVariableStore(
                s, s.id, s.name,
                s.qualified_name,
                s.initialization)

            if not s.value:
                store.with_annotations(DEFAULT_INIT)

            return store

        state_variables = of_type[VariableDeclaration](nodes)
        state_inits = ((
                s.initialization_cfg >>
                get_store(s)
        ) for s in state_variables)

        return CfgSimple.concatenate(*state_inits)


    @synthesized
    def cfg_state_init(self):
        stage1_context: Stage1Context = self.stage1_context
        cfg_state_inits = stage1_context.cfg_contract_state_init

        return CfgSimple.concatenate(*(cfg_state_inits[c] for c in reversed(self.linearized_base_contracts)))
