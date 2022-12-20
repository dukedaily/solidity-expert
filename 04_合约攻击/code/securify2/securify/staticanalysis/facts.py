from securify.staticanalysis.souffle.relation import DatalogType, relation, SymbolType, NumberType

__all__ = [
    "SSAType", "BlockType", "FunctionType",
    "TransferType", "ArgIndexType", "NameType", "ElementType",

    "ContractFact", "ContractFunctionFact",
    "FunctionFact",
    "BlockFact", "BlockStmtFact", "FollowsFact",
    "ArgumentFact", "StatementFact", "ContractStateVarFact",
    "AssignFact", "ConstFact", "UnaryOpFact", "BinaryOpFact",
    "LoadFact", "StoreFact", "ArrayLoadFact", "ArrayStoreFact", "ArrayPushFact",
    "MapLoadFact", "MapStoreFact", "StructLoadFact", "StructStoreFact",
    "GotoFact", "BranchFact", "ReturnFact", "JumpFact", "CallFact",
    "TransferArgumentFact", "UnknownBlockFact",
    "SourceInfoFact", "AnnotationFact",

    "EmitFact", "BalanceFact",

    "RevertFact", "StopFact",

    "BuiltinVariableFact", "BuiltinFunctionFact", "SelfDestructFact",
    "CallGasFact", "CallValueFact", "CallInfoFact",

    "fact_types", "statement_facts",
]

# region Fact Types

SSAType, BlockType, ContractType, TransferType, ArgIndexType, NameType, StateVarType = [
    DatalogType("SSA", "symbol", info="ID of a statement or block argument and its value"),
    DatalogType("Block", "symbol", info="ID of a basic block"),
    DatalogType("Contract", "symbol", info="ID of a contract"),
    DatalogType("Transfer", "symbol", info="ID of a transfer between blocks"),
    DatalogType("ArgIndex", "number", info="Index used to qualify block arguments"),
    DatalogType("Name", "symbol", info="Name associated to an object"),
    DatalogType("StateVar", "symbol", info="Identifier for state variables"),
]

FunctionType = DatalogType("Function", (BlockType,), info="Type alias for referring to function blocks")
ElementType = DatalogType("Element", (SSAType,
                                      BlockType,
                                      TransferType,
                                      StateVarType,
                                      ContractType), info="Any Program Element")

# Blocks and args
FunctionFact = relation("function", id_block=FunctionType, name=NameType)

BlockFact = relation("block", id_block=BlockType)
BlockStmtFact = relation("block_stmt", id_block=BlockType, id_stmt=SSAType)

FollowsFact = relation("follows", id_next=SSAType, id_prev=SSAType)

ArgumentFact = relation("argument", id_arg=SSAType, id_block=BlockType, index=ArgIndexType)
StatementFact = relation("statement", id=SSAType)

# Statements
AssignFact = relation("assign", id=SSAType, var_id=SSAType)
ConstFact = relation("const", id=SSAType, value=SSAType)
UnaryOpFact = relation("uop", id=SSAType, id_var=SSAType, op=SSAType)
BinaryOpFact = relation("bop", id=SSAType, id_lhs=SSAType, id_rhs=SSAType, op=NameType)

LoadFact = relation("load", id=SSAType, field=StateVarType)
StoreFact = relation("store", id=SSAType, field=StateVarType, var_id=SSAType)

ArrayLoadFact = relation("array_load", id=SSAType, id_array=SSAType, id_index=SSAType)
ArrayStoreFact = relation("array_store", id=SSAType, id_array=SSAType, id_index=SSAType, id_var=SSAType)
ArrayPushFact = relation("array_push", id=SSAType, id_array=SSAType, id_var=SSAType)

MapLoadFact = relation("map_load", id=SSAType, id_map=SSAType, id_key=SSAType)
MapStoreFact = relation("map_store", id=SSAType, id_map=SSAType, id_key=SSAType, id_var=SSAType)

StructLoadFact = relation("struct_load", id=SSAType, id_struct=SSAType, field=NameType)
StructStoreFact = relation("struct_store", id=SSAType, id_struct=SSAType, field=NameType, id_var=SSAType)

BuiltinVariableFact = relation("builtin_variable", id=SSAType, name=NameType)
BuiltinFunctionFact = relation("builtin_function", id=SSAType, name=NameType, arg=SSAType, arg_index=NumberType)

SelfDestructFact = relation("selfdestruct", id=SSAType, id_address=SSAType)

EmitFact = relation("emit", id=SSAType, event_name=NameType, arg=SSAType, arg_index=NumberType)
BalanceFact = relation("balance", id=SSAType, id_address=SSAType)

# Transfers
GotoFact = relation("goto",
                    id_transfer=TransferType,
                    id_block_from=BlockType,
                    id_block_to=BlockType)

BranchFact = relation("branch",
                      id_transfer_true=TransferType,
                      id_transfer_false=TransferType,
                      id_block_from=BlockType,
                      id_block_true=BlockType,
                      id_block_false=BlockType,
                      var_cond_id=SSAType)

ReturnFact = relation("return_",
                      id_transfer=TransferType,
                      id_block_from=BlockType)

StopFact = relation("stop", id_transfer=TransferType, id_block_from=BlockType)

RevertFact = relation("revert", id_transfer=TransferType, id_block_from=BlockType)

JumpFact = relation("jump",
                    id_transfer=TransferType,
                    id_block_from=BlockType,
                    id_block_to=FunctionType,
                    id_continuation=BlockType)

CallFact = relation("call",
                    id_transfer=TransferType,
                    id_block_from=BlockType,
                    id_block_to=SSAType,
                    id_continuation=BlockType)

TransferArgumentFact = relation("transfer_argument",
                                id_transfer=TransferType,
                                id_argument_value=SSAType,
                                index=ArgIndexType)

UnknownBlockFact = relation("unknown_block", id_block=BlockType)

SourceInfoFact = relation("source_info",
                          id=ElementType,
                          tag=SymbolType,
                          info=SymbolType)

AnnotationFact = relation("annotation", id=ElementType, tag=SymbolType, value=SymbolType)

CallGasFact = relation("call_gas", id_transfer=TransferType, gas=SSAType)
CallValueFact = relation("call_value", id_transfer=TransferType, value=SSAType)
CallInfoFact = relation("call_info", id_transfer=TransferType, address=SSAType, kind=SymbolType)

ContractFact = relation("contract", id_contract=ContractType, name=SymbolType)
ContractFunctionFact = relation("contract_function", id_contract=ContractType, id_function=FunctionType)

ContractStateVarFact = relation("state_variable",
                                id_variable=StateVarType,
                                id_contract=ContractType)

# endregion

statement_facts = (
    AssignFact, ConstFact, UnaryOpFact, BinaryOpFact,
    LoadFact, ArrayLoadFact, MapLoadFact, StructLoadFact,
    StoreFact, ArrayStoreFact, MapStoreFact, StructStoreFact, ArrayPushFact,
    BuiltinVariableFact, BuiltinFunctionFact, SelfDestructFact, EmitFact,
    BalanceFact
)

fact_types = [
    ContractFact, ContractFunctionFact,
    FunctionFact,
    BlockFact, BlockStmtFact, FollowsFact,
    ArgumentFact, ContractStateVarFact,
    StatementFact, *statement_facts,
    GotoFact, BranchFact, ReturnFact, JumpFact, CallFact,
    TransferArgumentFact, UnknownBlockFact,
    SourceInfoFact, AnnotationFact,
    CallGasFact, CallValueFact, CallInfoFact,
    RevertFact, StopFact
]
