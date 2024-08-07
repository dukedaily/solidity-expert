# SOLANA ITSELF

## The Sequence

Rust Code -> LLVM-IR -> BPF (bytecode) -> Insturctions to run

1. Stage1:

   - `LLVM-IR`: Low Level Virtual Machine Intermediate Representation

   - `BPF`: Berkeley Packet Filter

2. Stage2:
   - The validators `JIT` (Just In Time) compile the `BPF` to the insturction set compatible with their hardware.

