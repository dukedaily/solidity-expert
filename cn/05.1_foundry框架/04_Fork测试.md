# 第4节：Fork 测试

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

Fork 测试指在本地复制主网状态，直接与真实合约（Uniswap、Aave、USDC 等）交互。对集成测试和攻击复现极为有用。

## 启动 Fork

两种方式：命令行 flag 或代码内切换。

### 命令行方式

```shell
forge test --fork-url $MAINNET_RPC
```

所有测试都在 mainnet fork 上跑。

### 代码内切换（推荐）

```js
import {Test} from "forge-std/Test.sol";

contract ForkTest is Test {
    uint256 mainnetFork;

    function setUp() public {
        mainnetFork = vm.createSelectFork(vm.envString("MAINNET_RPC"));
    }
    // ...
}
```

更灵活：可同时 fork 多条链并在测试中切换。

## 指定区块高度

锁定区块保证测试可复现：

```js
vm.createSelectFork(vm.envString("MAINNET_RPC"), 19_500_000);
```

也可在命令行加 `--fork-block-number 19500000`。

## 与真实合约交互

示例：读取 USDC 总供应量。

```js
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UsdcTest is Test {
    IERC20 usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    function setUp() public {
        vm.createSelectFork(vm.envString("MAINNET_RPC"));
    }

    function test_UsdcTotalSupply() public view {
        uint256 supply = usdc.totalSupply();
        assertGt(supply, 0);
    }
}
```

## 伪装链上鲸鱼

从鲸鱼地址 `prank` 转走资金，免去复杂的 swap 逻辑：

```js
address whale = 0x40B38765696e3d5d8d9d834D8AaD4bB6e418E489;

function test_TransferFromWhale() public {
    vm.prank(whale);
    usdc.transfer(alice, 10_000e6);
    assertEq(usdc.balanceOf(alice), 10_000e6);
}
```

## 多 Fork 切换

```js
uint256 mainnet = vm.createFork(vm.envString("MAINNET_RPC"));
uint256 arbitrum = vm.createFork(vm.envString("ARB_RPC"));

vm.selectFork(mainnet);
// 在 mainnet 上执行

vm.selectFork(arbitrum);
// 切到 arbitrum
```

适合测试跨链桥、多链部署。

## RPC 与环境变量

在项目根目录 `.env` 中配置：

```shell
MAINNET_RPC=https://eth-mainnet.g.alchemy.com/v2/<KEY>
ARB_RPC=https://arb-mainnet.g.alchemy.com/v2/<KEY>
```

`forge test` 自动加载 `.env`。确保 `.env` 已加入 `.gitignore`，勿把密钥提交到仓库。

## 小结

Fork 测试把"链上生产环境"当作一个可控测试夹具，是审计与集成测试的利器。下一节讲如何用 Fuzz / Invariant 让测试自动生成挑战性输入。
