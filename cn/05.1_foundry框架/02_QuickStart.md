# 第2节：QuickStart

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

从 0 开始：初始化 → 编译 → 测试，10 分钟跑通。

## 初始化项目

```shell
forge init hello_foundry
cd hello_foundry
```

生成的目录结构：

```
hello_foundry/
├── foundry.toml      # 配置文件
├── lib/              # 依赖（git submodule）
│   └── forge-std/    # 标准测试库
├── src/              # 合约源码
│   └── Counter.sol
├── test/             # 测试
│   └── Counter.t.sol
└── script/           # 部署脚本
    └── Counter.s.sol
```

## 编译

```shell
forge build
```

产物在 `out/` 目录。增量编译，第二次极快。

## 跑测试

```shell
forge test
```

示例输出：

```
Ran 3 tests for test/Counter.t.sol:CounterTest
[PASS] testFuzz_SetNumber(uint256) (runs: 256, μ: 31235, ~: 31577)
[PASS] test_Increment() (gas: 31303)
[PASS] test_SetNumber(uint256) (gas: 27338)
```

常用 flag：

- `forge test -vv`：显示 `console.log` 日志。
- `forge test -vvvv`：完整 trace（失败排查利器）。
- `forge test --match-test testFoo`：按名字过滤。
- `forge test --match-contract CounterTest`：按合约过滤。
- `forge test --gas-report`：输出 gas 报告。

## 基本测试样例

`test/Counter.t.sol`:

```js
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
```

## 测试函数命名约定

- `test_` 开头：普通单元测试，一次运行。
- `testFuzz_` 开头：参数化模糊测试，每个参数自动跑 256 次（可调）。
- `invariant_` 后续章节展开。Fork 测试沿用 `test_` 命名，无特殊前缀。

## 小结

90% 的日常开发只要用到 `forge build` 和 `forge test`。下一节深入 `forge test` 的 assertion、cheatcode 与 revert 断言。
