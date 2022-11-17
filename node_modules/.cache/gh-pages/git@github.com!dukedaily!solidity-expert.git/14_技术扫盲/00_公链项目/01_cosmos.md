# Cosmos

参考链接：https://learnblockchain.cn/2019/05/21/what-is-cosmos/

**Cosmos是一个独立并行区块链的去中心化网络，每个区块链都由[Tendermint](https://cosmos.network/intro#what-is-tendermint-core-and-the-abci)共识这样的BFT共识算法构建**。

Cosmos的愿景是让开发人员轻松构建区块链，并通过允许他们彼此进行交易（通信）来打破区块链之间的障碍。 最终目标是创建一个**区块链网络，一个能够以去中心化方式相互通信的区块链网络，**通过Cosmos，区块链可以保持主权，快速处理交易并与生态系统中的其他区块链进行通信，使其成为各种场景的最佳选择。

## 概述：

- Comsmos的作用是让开发构建区块链，而不是构建dapp
- Comsmos的目的是创建一个区块链生态，让每一条链之间可以自由互通

## 实现：

Cosmos通过一系列开源工具打造自己的生态：Tendermint，Cosmos SDK和IBC，旨在让人们快速构建定义、安全、可扩展和客户操作的区块链应用。

- **T\*endermint\***是一个**共识引擎和BFT共识算法，**在Tendermint之上可以使用任何编程语言构建一个状态机，Tendermint 将负责信息的（按照共识要求的一致性和安全性）复制。
- ***Cosmos SDK***是一个**模块化框架**，用来简化构建安全的区块链应用。
- ***IBC***是区块链之间的**通信协议**，可以被认为是区块链的TCP/IP。 它允许快速最终性（fast-finality）的区块链以去中心化的方式相互交换价值和数据。