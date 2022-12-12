# 第1节：OPCode手册

https://www.evm.codes/?fork=grayGlacier

https://www.ethervm.io/



## 概览

<img src="https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221104163118696.png" alt="image-20221104163118696" style="zoom:50%;" />



## 分类

- **算术运算**：ADD, MUL, SUB, DIV, SDIV, MOD, SMOD, ADDMOD, MULMOD, EXP, SIGNEXTEND
- **逻辑运算：**LT, GT, SLT, SGT, EQ, ISZERO
- **位运算**：AND, OR, XOR, NOT, BYTE, SHL, SHR, SAR



- **当前交易状态信息**：ADDRESS, SELFBALANCE, ORGIN, CALLER, CALLVALUE
- **当前块状态信息**：COINBASE, TIMESTAMP, NUMBER, DIFFICULTY, GASLIMIT, GASPRICE, BASEFEE
- **其他信息读取**：BALANCE, BLOCKHASH



- **栈相关**：POP, PUSH[1-32], DUP[1-16], SWAP[1-16], PUSH, DUP, SWAP
- **CALLDATA相关：**CALLDATALOAD, CALLDATASIZE, CALLDATACOPY
- **内存相关**：MLOAD, MSTORE, MSTORE8
- **持久存储相关**：SLOAD, SSTORE
- **流控制相关**：JUMP, JUMPI, PC, JUMPDEST, RETURN, REVERT
- **执行时环境信息**：MSIZE, GAS
- **日志相关：**LOG[0-4]



- **合约创建相关**：CREATE, CREATE2
- **CODE相关**：CODESIZE, CODECOPY, EXTCODESIZE, EXTCODECOPY, EXTCODEHASH
- **外部调用相关**：CALL, CALLCODE, DELEGATECALL, STATICCALL, RETURNDATASIZE, RETURNDATACOPY
- **其他**：STOP, SELFDESTRUCT, SHA3



## 完整

| OPCODE | NAME           | MINIMUM GAS | STACK OUPUT    | DESCRIPTIONExpand                                            |
| ------ | -------------- | ----------- | -------------- | ------------------------------------------------------------ |
| 00     | STOP           | 0           |                | Halts execution                                              |
| 01     | ADD            | 3           | a + b          | Addition operation                                           |
| 02     | MUL            | 5           | a * b          | Multiplication operation                                     |
| 03     | SUB            | 3           | a - b          | Subtraction operation                                        |
| 04     | DIV            | 5           | a // b         | Integer division operation                                   |
| 05     | SDIV           | 5           | a // b         | Signed integer division operation (truncated)                |
| 06     | MOD            | 5           | a % b          | Modulo remainder operation                                   |
| 07     | SMOD           | 5           | a % b          | Signed modulo remainder operation                            |
| 08     | ADDMOD         | 8           | (a + b) % N    | Modulo addition operation                                    |
| 09     | MULMOD         | 8           | (a * b) % N    | Modulo multiplication operation                              |
| 0A     | EXP            | 10          | a ** exponent  | Exponential operation                                        |
| 0B     | SIGNEXTEND     | 5           | y              | Extend length of two’s complement signed integer             |
| 10     | LT             | 3           | a < b          | Less-than comparison                                         |
| 11     | GT             | 3           | a > b          | Greater-than comparison                                      |
| 12     | SLT            | 3           | a < b          | Signed less-than comparison                                  |
| 13     | SGT            | 3           | a > b          | Signed greater-than comparison                               |
| 14     | EQ             | 3           | a == b         | Equality comparison                                          |
| 15     | ISZERO         | 3           | a == 0         | Simple not operator                                          |
| 16     | AND            | 3           | a & b          | Bitwise AND operation                                        |
| 17     | OR             | 3           | a \| b         | Bitwise OR operation                                         |
| 18     | XOR            | 3           | a ^ b          | Bitwise XOR operation                                        |
| 19     | NOT            | 3           | ~a             | Bitwise NOT operation                                        |
| 1A     | BYTE           | 3           | y              | Retrieve single byte from word                               |
| 1B     | SHL            | 3           | value << shift | Left shift operation                                         |
| 1C     | SHR            | 3           | value >> shift | Logical right shift operation                                |
| 1D     | SAR            | 3           | value >> shift | Arithmetic (signed) right shift operation                    |
| 20     | SHA3           | 30          | hash           | Compute Keccak-256 hash                                      |
| 30     | ADDRESS        | 2           | address        | Get address of currently executing account                   |
| 31     | BALANCE        | 100         | balance        | Get balance of the given account                             |
| 32     | ORIGIN         | 2           | address        | Get execution origination address                            |
| 33     | CALLER         | 2           | address        | Get caller address                                           |
| 34     | CALLVALUE      | 2           | value          | Get deposited value by the instruction/transaction responsible for this execution |
| 35     | CALLDATALOAD   | 3           | data[i]        | Get input data of current environment                        |
| 36     | CALLDATASIZE   | 2           | size           | Get size of input data in current environment                |
| 37     | CALLDATACOPY   | 3           |                | Copy input data in current environment to memory             |
| 38     | CODESIZE       | 2           | size           | Get size of code running in current environment              |
| 39     | CODECOPY       | 3           |                | Copy code running in current environment to memory           |
| 3A     | GASPRICE       | 2           | price          | Get price of gas in current environment                      |
| 3B     | EXTCODESIZE    | 100         | size           | Get size of an account’s code                                |
| 3C     | EXTCODECOPY    | 100         |                | Copy an account’s code to memory                             |
| 3D     | RETURNDATASIZE | 2           | size           | Get size of output data from the previous call from the current environment |
| 3E     | RETURNDATACOPY | 3           |                | Copy output data from the previous call to memory            |
| 3F     | EXTCODEHASH    | 100         | hash           | Get hash of an account’s code                                |
| 40     | BLOCKHASH      | 20          | hash           | Get the hash of one of the 256 most recent complete blocks   |
| 41     | COINBASE       | 2           | address        | Get the block’s beneficiary address                          |
| 42     | TIMESTAMP      | 2           | timestamp      | Get the block’s timestamp                                    |
| 43     | NUMBER         | 2           | blockNumber    | Get the block’s number                                       |
| 44     | DIFFICULTY     | 2           | difficulty     | Get the block’s difficulty                                   |
| 45     | GASLIMIT       | 2           | gasLimit       | Get the block’s gas limit                                    |
| 46     | CHAINID        | 2           | chainId        | Get the chain ID                                             |
| 47     | SELFBALANCE    | 5           | balance        | Get balance of currently executing account                   |
| 48     | BASEFEE        | 2           | baseFee        | Get the base fee                                             |
| 50     | POP            | 2           |                | Remove item from stack                                       |
| 51     | MLOAD          | 3           | value          | Load word from memory                                        |
| 52     | MSTORE         | 3           |                | Save word to memory                                          |
| 53     | MSTORE8        | 3           |                | Save byte to memory                                          |
| 54     | SLOAD          | 100         | value          | Load word from storage                                       |
| 55     | SSTORE         | 100         |                | Save word to storage                                         |
| 56     | JUMP           | 8           |                | Alter the program counter                                    |
| 57     | JUMPI          | 10          |                | Conditionally alter the program counter                      |
| 58     | PC             | 2           | counter        | Get the value of the program counter prior to the increment corresponding to this instruction |
| 59     | MSIZE          | 2           | size           | Get the size of active memory in bytes                       |
| 5A     | GAS            | 2           | gas            | Get the amount of available gas, including the corresponding reduction for the cost of this instruction |
| 5B     | JUMPDEST       | 1           |                | Mark a valid destination for jumps                           |
| 60     | PUSH1          | 3           | value          | Place 1 byte item on stack                                   |
| 61     | PUSH2          | 3           | value          | Place 2 byte item on stack                                   |
| 62     | PUSH3          | 3           | value          | Place 3 byte item on stack                                   |
| 63     | PUSH4          | 3           | value          | Place 4 byte item on stack                                   |
| 64     | PUSH5          | 3           | value          | Place 5 byte item on stack                                   |
| 65     | PUSH6          | 3           | value          | Place 6 byte item on stack                                   |
| 66     | PUSH7          | 3           | value          | Place 7 byte item on stack                                   |
| 67     | PUSH8          | 3           | value          | Place 8 byte item on stack                                   |
| 68     | PUSH9          | 3           | value          | Place 9 byte item on stack                                   |
| 69     | PUSH10         | 3           | value          | Place 10 byte item on stack                                  |
| 6A     | PUSH11         | 3           | value          | Place 11 byte item on stack                                  |
| 6B     | PUSH12         | 3           | value          | Place 12 byte item on stack                                  |
| 6C     | PUSH13         | 3           | value          | Place 13 byte item on stack                                  |
| 6D     | PUSH14         | 3           | value          | Place 14 byte item on stack                                  |
| 6E     | PUSH15         | 3           | value          | Place 15 byte item on stack                                  |
| 6F     | PUSH16         | 3           | value          | Place 16 byte item on stack                                  |
| 70     | PUSH17         | 3           | value          | Place 17 byte item on stack                                  |
| 71     | PUSH18         | 3           | value          | Place 18 byte item on stack                                  |
| 72     | PUSH19         | 3           | value          | Place 19 byte item on stack                                  |
| 73     | PUSH20         | 3           | value          | Place 20 byte item on stack                                  |
| 74     | PUSH21         | 3           | value          | Place 21 byte item on stack                                  |
| 75     | PUSH22         | 3           | value          | Place 22 byte item on stack                                  |
| 76     | PUSH23         | 3           | value          | Place 23 byte item on stack                                  |
| 77     | PUSH24         | 3           | value          | Place 24 byte item on stack                                  |
| 78     | PUSH25         | 3           | value          | Place 25 byte item on stack                                  |
| 79     | PUSH26         | 3           | value          | Place 26 byte item on stack                                  |
| 7A     | PUSH27         | 3           | value          | Place 27 byte item on stack                                  |
| 7B     | PUSH28         | 3           | value          | Place 28 byte item on stack                                  |
| 7C     | PUSH29         | 3           | value          | Place 29 byte item on stack                                  |
| 7D     | PUSH30         | 3           | value          | Place 30 byte item on stack                                  |
| 7E     | PUSH31         | 3           | value          | Place 31 byte item on stack                                  |
| 7F     | PUSH32         | 3           | value          | Place 32 byte (full word) item on stack                      |
| 80     | DUP1           | 3           | valuevalue     | Duplicate 1st stack item                                     |
| 81     | DUP2           | 3           | bab            | Duplicate 2nd stack item                                     |
| 82     | DUP3           | 3           | cabc           | Duplicate 3rd stack item                                     |
| 83     | DUP4           | 3           | value...value  | Duplicate 4th stack item                                     |
| 84     | DUP5           | 3           | value...value  | Duplicate 5th stack item                                     |
| 85     | DUP6           | 3           | value...value  | Duplicate 6th stack item                                     |
| 86     | DUP7           | 3           | value...value  | Duplicate 7th stack item                                     |
| 87     | DUP8           | 3           | value...value  | Duplicate 8th stack item                                     |
| 88     | DUP9           | 3           | value...value  | Duplicate 9th stack item                                     |
| 89     | DUP10          | 3           | value...value  | Duplicate 10th stack item                                    |
| 8A     | DUP11          | 3           | value...value  | Duplicate 11th stack item                                    |
| 8B     | DUP12          | 3           | value...value  | Duplicate 12th stack item                                    |
| 8C     | DUP13          | 3           | value...value  | Duplicate 13th stack item                                    |
| 8D     | DUP14          | 3           | value...value  | Duplicate 14th stack item                                    |
| 8E     | DUP15          | 3           | value...value  | Duplicate 15th stack item                                    |
| 8F     | DUP16          | 3           | value...value  | Duplicate 16th stack item                                    |
| 90     | SWAP1          | 3           | ba             | Exchange 1st and 2nd stack items                             |
| 91     | SWAP2          | 3           | cba            | Exchange 1st and 3rd stack items                             |
| 92     | SWAP3          | 3           | b...a          | Exchange 1st and 4th stack items                             |
| 93     | SWAP4          | 3           | b...a          | Exchange 1st and 5th stack items                             |
| 94     | SWAP5          | 3           | b...a          | Exchange 1st and 6th stack items                             |
| 95     | SWAP6          | 3           | b...a          | Exchange 1st and 7th stack items                             |
| 96     | SWAP7          | 3           | b...a          | Exchange 1st and 8th stack items                             |
| 97     | SWAP8          | 3           | b...a          | Exchange 1st and 9th stack items                             |
| 98     | SWAP9          | 3           | b...a          | Exchange 1st and 10th stack items                            |
| 99     | SWAP10         | 3           | b...a          | Exchange 1st and 11th stack items                            |
| 9A     | SWAP11         | 3           | b...a          | Exchange 1st and 12th stack items                            |
| 9B     | SWAP12         | 3           | b...a          | Exchange 1st and 13th stack items                            |
| 9C     | SWAP13         | 3           | b...a          | Exchange 1st and 14th stack items                            |
| 9D     | SWAP14         | 3           | b...a          | Exchange 1st and 15th stack items                            |
| 9E     | SWAP15         | 3           | b...a          | Exchange 1st and 16th stack items                            |
| 9F     | SWAP16         | 3           | b...a          | Exchange 1st and 17th stack items                            |
| A0     | LOG0           | 375         |                | Append log record with no topics                             |
| A1     | LOG1           | 750         |                | Append log record with one topic                             |
| A2     | LOG2           | 1125        |                | Append log record with two topics                            |
| A3     | LOG3           | 1500        |                | Append log record with three topics                          |
| A4     | LOG4           | 1875        |                | Append log record with four topics                           |
| F0     | CREATE         | 32000       | address        | Create a new account with associated code                    |
| F1     | CALL           | 100         | success        | Message-call into an account                                 |
| F2     | CALLCODE       | 100         | success        | Message-call into this account with alternative account’s code |
| F3     | RETURN         | 0           |                | Halt execution returning output data                         |
| F4     | DELEGATECALL   | 100         | success        | Message-call into this account with an alternative account’s code, but persisting the current values for sender and value |
| F5     | CREATE2        | 32000       | address        | Create a new account with associated code at a predictable address |
| FA     | STATICCALL     | 100         | success        | Static message-call into an account                          |
| FD     | REVERT         | 0           |                | Halt execution reverting state changes but returning data and remaining gas |
| FE     | INVALID        | NaN         |                | Designated invalid instruction                               |
| FF     | SELFDESTRUCT   | 5000        |                | Halt execution and register account for later deletion       |
