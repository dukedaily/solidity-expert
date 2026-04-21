# 第6节：Script 部署

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

Foundry 的部署脚本用 Solidity 编写（而非 JS），通过 `forge script` 执行。同一门语言写测试和部署，心智负担小。

## Hello Script

`script/Deploy.s.sol`:

```js
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

contract DeployCounter is Script {
    function run() external returns (Counter counter) {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        counter = new Counter();
        counter.setNumber(42);

        vm.stopBroadcast();
        console.log("Counter deployed at:", address(counter));
    }
}
```

关键点：`vm.startBroadcast` 到 `vm.stopBroadcast` 之间的所有状态变更会被打包成真实交易，广播到链上。

## 本地 dry-run

不带 `--broadcast` 时，脚本只在本地模拟，不发交易：

```shell
forge script script/Deploy.s.sol:DeployCounter --rpc-url $MAINNET_RPC
```

输出显示将要发的交易与 gas 估算。部署前先跑一遍 dry-run 是好习惯。

## 广播到链上

```shell
forge script script/Deploy.s.sol:DeployCounter \
  --rpc-url $MAINNET_RPC \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_KEY
```

常用 flag：

- `--broadcast`：真正发交易。
- `--verify`：部署后自动向 Etherscan 提交源码 verify。
- `--etherscan-api-key`：verify 需要。
- `--slow`：等待前一笔上链再发下一笔，避免 nonce 冲突。
- `--gas-estimate-multiplier 120`：gas 预估打 120% 余量。

## 私钥管理

生产环境别直接用环境变量明文。Foundry 支持加密 keystore：

```shell
cast wallet import deployer --interactive
# 输入私钥与密码，生成 ~/.foundry/keystores/deployer
```

使用：

```shell
forge script ... --account deployer
```

或硬件钱包（Ledger）：

```shell
forge script ... --ledger
```

## 多合约 + 依赖编排

脚本里可以写任意 Solidity 逻辑：

```js
function run() external {
    vm.startBroadcast();

    Token token = new Token("Foo", "FOO");
    Vault vault = new Vault(address(token));
    token.mint(address(vault), 1_000_000e18);

    vm.stopBroadcast();

    console.log("token:", address(token));
    console.log("vault:", address(vault));
}
```

## 部署记录

广播结果保存在 `broadcast/<Script>/<chainId>/run-latest.json`，包含交易 hash、合约地址、日志。CI 和前端可直接读取。

## 小结

Script = "可执行的 Solidity"。整合 cheatcode + 广播控制 + verify，替代了 Hardhat 的 `deploy.js`。下一节收尾，介绍 cast / anvil / chisel 三件套。
