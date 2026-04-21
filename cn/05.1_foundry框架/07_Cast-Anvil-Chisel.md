# 第7节：Cast / Anvil / Chisel

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

除了 forge，Foundry 还有三个独立工具，构成完整工具链。

## Cast：链上交互瑞士军刀

### 查询链上数据

```shell
# 查地址余额
cast balance 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48

# 读 ERC20 总供应
cast call $USDC "totalSupply()(uint256)" --rpc-url $MAINNET_RPC

# 带参数的函数调用
cast call $USDC "balanceOf(address)(uint256)" $ALICE --rpc-url $MAINNET_RPC
```

### 发送交易

```shell
# 发 ETH
cast send $RECIPIENT --value 0.1ether --private-key $PK

# 调用合约函数
cast send $USDC "transfer(address,uint256)" $ALICE 1000000 --private-key $PK
```

### 解析与编码

```shell
# decode calldata 的前 4 字节（function selector）
cast 4byte-decode 0xa9059cbb000000000000000000000000...

# 算 function selector
cast sig "transfer(address,uint256)"
# 输出: 0xa9059cbb

# abi encode 参数
cast abi-encode "transfer(address,uint256)" $ALICE 1000
```

### 工具函数

```shell
cast --to-wei 1.5 ether             # → 1500000000000000000
cast --from-wei 1500000000000000000  # → 1.5
cast keccak "foo"                    # keccak256 hash
cast chain-id                        # 当前 RPC 的 chain id
```

一句话：命令行和链打交道，`cast` 基本够用。

## Anvil：本地开发链

```shell
anvil
```

默认行为：

- 监听 `127.0.0.1:8545`
- 预置 10 个测试账户，各 10000 ETH，私钥直接打印在终端
- 支持 EIP-1559，`chainId = 31337`

常用 flag：

- `--fork-url $MAINNET_RPC`：本地起一个主网分叉，秒级响应。
- `--fork-block-number 19500000`：锁定区块。
- `--accounts 20`：改账户数。
- `--block-time 2`：固定出块时间（秒），模拟真实节奏。

```shell
anvil --fork-url $MAINNET_RPC --block-time 2
```

前端 / 钱包接 `http://127.0.0.1:8545` 即可像接主网一样调试。

## Chisel：Solidity REPL

快速验证语法或做计算：

```shell
chisel
```

进入 REPL 后：

```
➜ uint256 a = 10;
➜ uint256 b = 20;
➜ a + b
Type: uint256
├ Hex: 0x1e
└ Decimal: 30

➜ keccak256("hello")
Type: bytes32
└ Data: 0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8
```

适合算 selector、测 bit 操作、试 cheatcode，不必写完整测试合约。

## 小结

forge 管项目、cast 管命令行交互、anvil 管本地链、chisel 管片段验证。四件套覆盖从开发到部署的完整链路。

至此 Foundry 章节结束。下一章回到 ethers，看看如何从链下用 JS 与合约交互。
