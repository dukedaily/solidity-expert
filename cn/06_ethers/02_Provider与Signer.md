# 第2节：Provider 与 Signer

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

Provider 提供"读"的能力，Signer 提供"写"的能力。本节覆盖三类 Provider、Signer 的两种来源，以及 v6 中必须掌握的 `bigint` 语义。

## 三类 Provider

### JsonRpcProvider —— 后端 / 脚本常用

```js
import { ethers } from "ethers";

const provider = new ethers.JsonRpcProvider("https://eth.llamarpc.com");

const block = await provider.getBlockNumber();
console.log("当前块:", block);
```

### BrowserProvider —— 前端 dApp

浏览器环境，接 MetaMask / Rabby / OKX Wallet：

```js
const provider = new ethers.BrowserProvider(window.ethereum);

// 请求钱包连接
await provider.send("eth_requestAccounts", []);

// 获取当前账户 Signer
const signer = await provider.getSigner(); // v6: async
const addr = await signer.getAddress();
```

**v6 重要变化**：`provider.getSigner()` 在 BrowserProvider 下返回 Promise（v5 是同步）。

### WebSocketProvider —— 订阅事件

```js
const ws = new ethers.WebSocketProvider(
  "wss://eth-mainnet.g.alchemy.com/v2/<KEY>",
);

ws.on("block", (n) => console.log("new block:", n));
```

## 两种 Signer 来源

### Wallet（脚本端）

从私钥构造，常用于后端脚本、部署、bot：

```js
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

const addr = await wallet.getAddress();
const bal = await provider.getBalance(addr);
```

### BrowserProvider.getSigner()（前端）

由浏览器钱包（MetaMask 等）代为管理密钥，如上一节示例。

## `bigint` 是 v6 的通行货币

v6 不再使用 `BigNumber`，所有金额、block number、nonce 都用原生 **bigint**：

```js
const wei = await provider.getBalance(addr);
// wei 的类型是 bigint，不是 BigNumber

const ethValue = ethers.formatEther(wei); // 字符串 "1.234"
const weiValue = ethers.parseEther("1.0"); // 1000000000000000000n

// 运算直接用 bigint 语法
const twice = wei * 2n;
const half = wei / 2n;
```

bigint 与 number 不能混用，`1n + 1` 会抛 `TypeError`。需要显式转换：

```js
const { chainId } = await provider.getNetwork();
const id = Number(chainId); // chainId 本身是 bigint
```

## 小结

Provider 读、Signer 写、bigint 算。下一节把三者组合起来读合约。
