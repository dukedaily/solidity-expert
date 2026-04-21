# 第5节：Fuzz 与 Invariant

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

**Fuzz** 与 **Invariant** 是 Foundry 最有分量的能力：自动生成输入寻找合约的崩溃边界，是审计级测试的核心手段。

## Fuzz 测试

函数名以 `testFuzz_` 开头，参数由 Foundry 随机生成（默认每个函数跑 256 次）：

```js
function testFuzz_Deposit(uint256 amount) public {
    vm.assume(amount > 0 && amount < 1000 ether); // 过滤无意义输入
    vault.deposit{value: amount}();
    assertEq(vault.balanceOf(address(this)), amount);
}
```

`vm.assume` 过滤不关心的输入，但过度使用会降低有效样本率。优先用 bound 函数把随机值映射到目标区间：

```js
amount = bound(amount, 1, 1000 ether); // 100% 利用率
```

## Invariant 测试

Invariant 断言一条："无论对合约做什么操作，某性质永远成立"。Foundry 自动随机调用合约函数，每轮后检查 invariant。

### 无状态 invariant

直接断言数学性质：

```js
contract CounterInvariantTest is Test {
    Counter counter;

    function setUp() public {
        counter = new Counter();
    }

    function invariant_NumberNonNegative() public view {
        // uint 天然非负，这里作示例
        assertGe(counter.number(), 0);
    }
}
```

### 有状态 invariant + Handler

复杂场景用 **Handler** 合约约束调用序列：

```js
contract VaultHandler is Test {
    Vault vault;
    uint256 public totalDeposits;
    uint256 public totalWithdrawals;

    constructor(Vault _vault) {
        vault = _vault;
    }

    function deposit(uint256 amount) public {
        amount = bound(amount, 0, 100 ether);
        vault.deposit{value: amount}();
        totalDeposits += amount;
    }

    function withdraw(uint256 amount) public {
        amount = bound(amount, 0, vault.balanceOf(address(this)));
        vault.withdraw(amount);
        totalWithdrawals += amount;
    }
}

contract VaultInvariantTest is Test {
    Vault vault;
    VaultHandler handler;

    function setUp() public {
        vault = new Vault();
        handler = new VaultHandler(vault);
        targetContract(address(handler));
    }

    // 核心不变量：合约余额 ≥ 所有净存款
    function invariant_Solvency() public view {
        assertGe(
            address(vault).balance,
            handler.totalDeposits() - handler.totalWithdrawals()
        );
    }
}
```

`targetContract` 告诉 Foundry 只调用 handler 上的函数（而不是 Vault 的全部接口），通过 Handler 收束状态空间。

## 配置

`foundry.toml`:

```toml
[fuzz]
runs = 1000          # 每个 fuzz 函数跑的次数

[invariant]
runs = 256           # invariant 轮数
depth = 500          # 每轮调用多少次
fail_on_revert = false
```

默认 Revert 的调用不计入有效样本；`fail_on_revert = true` 则要求每次调用必须成功。

## 小结

Fuzz 找输入边界，Invariant 找状态机漏洞。涉及资金的核心合约应当对关键 invariant 写 Handler 测试。下一节切到部署侧：Script。
