# 第26节：合约自杀（selfdestruct）

自杀后特点：[点击查看手册](https://docs.soliditylang.org/en/v0.8.17/introduction-to-smart-contracts.html?highlight=selfdestruct#deactivate-and-self-destruct)

1. 合约的ether会强制转入到指定地址（如果是合约，即使没有fallback函数也能转如）
2. 合约的code和stat会被remove（和delete关键字效果不同）
3. 最新版本这个关键字要废弃了



TODO

演示：https://testnet.bscscan.com/tx/0xa93711d9b16c95c69a7b0ac22f153f708b3b8577df30bf806f04d756ba3839df

