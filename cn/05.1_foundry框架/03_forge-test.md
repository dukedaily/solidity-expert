# 第3节：forge test

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

本节覆盖 `forge test` 的核心用法：assertion、setUp、常用 cheatcode 与异常断言。

## Assertion 系列

`forge-std` 提供丰富的断言函数：

```js
assertEq(uint256(1), 1);                    // 相等
assertEq(addr1, addr2, "address mismatch"); // 带错误信息
assertGt(a, b);                             // a > b
assertLt(a, b);                             // a < b
assertTrue(x);
assertApproxEqAbs(a, b, 100);               // 绝对误差内相等
assertApproxEqRel(a, b, 0.01e18);           // 相对误差 1% 内相等
```

## setUp 与状态隔离

每个 `test_` 函数运行前都会先执行 `setUp()`，函数间状态完全隔离：

```js
contract MyTest is Test {
    Vault vault;
    address alice = makeAddr("alice");

    function setUp() public {
        vault = new Vault();
        deal(address(vault), 100 ether); // 给 vault 注资
    }

    function test_A() public {
        /* 不影响 test_B 的 vault 状态 */
    }

    function test_B() public {
        /* setUp 会重新跑一次 */
    }
}
```

`makeAddr("alice")` 按字符串生成确定性地址并自动打标签，便于 trace 输出可读。

## 核心 Cheatcode

Cheatcode 通过 forge-std 暴露的 `vm` 对象调用：

```js
// 伪装调用者
vm.prank(alice);              // 仅下一次调用
vm.startPrank(alice);         // 持续直到 stopPrank
vm.stopPrank();

// 操纵区块
vm.warp(block.timestamp + 1 days);  // 推进时间戳
vm.roll(block.number + 100);        // 推进区块号

// 操纵余额与存储
deal(address(token), user, 1_000 ether);  // 直接给地址分发 token
vm.store(target, slot, value);            // 直接写 storage slot

// 快照与回滚
uint256 snap = vm.snapshotState();
// ... 做一些操作
vm.revertToState(snap);
```

## Revert 断言

```js
// 期望下一条调用回滚
vm.expectRevert();
vault.withdraw(tooMuch);

// 期望带指定 message
vm.expectRevert("Insufficient balance");
vault.withdraw(tooMuch);

// 期望带 custom error selector
vm.expectRevert(Vault.InsufficientBalance.selector);
vault.withdraw(tooMuch);
```

## Event 断言

```js
vm.expectEmit(true, true, false, true);     // topic1, topic2, topic3, data 是否校验
emit Vault.Deposit(alice, 1 ether);          // 预期的事件
vault.deposit{value: 1 ether}();             // 触发事件的调用
```

## 日志输出

```js
import {console} from "forge-std/Test.sol";

console.log("balance:", vault.balanceOf(alice));
```

需要用 `-vv` 或更高 verbosity 才会显示。

## 小结

掌握 setUp + prank + warp + expectRevert 就能写出大部分单测。下一节把视野扩展到主网——Fork 测试。
