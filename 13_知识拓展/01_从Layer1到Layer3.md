# 第1节：Blockchain Layers（L0～L3）



对于区块链行业，我们经常听到各种名词，甚至有人专门总结过：区块链黑话（比如土狗：表示国产抄袭项目；大饼🫓：指比特币）。

随着zkSync的上线（零知识证明的以太坊扩容项目、兼容EVM），我们对Layer2的关注度越来越高，我们今天不聊黑话，聊聊这些Layer1、Layer2是什么意思，科普一下～



所谓Layer，通常是对一类区块链项目的抽象，有点像web2中的TCP/IP四层协议一样，每一层专注于自己的分工，通常我们把区块链分为四层，其中每一层都有很多个项目在支撑，如下图所示：

![img](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/0*NqJ5jJgl3kR1UMge.png)



## Layer0：打通链间交互

我们从下往上说，第一层是：Layer0，它相当于互联网中的物理层，负责链接layer1上的各种链

![image-20221118181914260](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221118181914260.png)

Layer0层面实现的功能主要是：

1. 允许不同链条之间实现交互；
2. 交易更快，更便宜；
3. 提供了基础设施，方便快速开发。



**代表项目：**

1. COSMOS
2. Polkadot
3. Avalanche
4. Cardano



## Layer1：交易最终执行

Layer1层是我们最熟悉的区块链层（例如：Bitcoin和ETH），在这一层每个链会执行各自的交易，完成数据共识（POW或POS），不可能三角（去中心化、安全、扩展性）就发生在这里。

![image-20221118182013608](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221118182013608.png)

Layer1代表项目：

1. Ethereum：王者，solidity
2. Binance：fork ethereum，solidity
3. Solana：rust写合约
4. celo：没用过，evem兼容的，面向defi的区块链项目



## Layer2：基于Layer1实现扩容

以太坊的低TPS（15～45）带来的结果就是高Gas费，这让大家苦不堪言，严重影响生态建设，因此就有了社区对Layer2的诉求。

Layer2层属于第三方的产品，它们与Layer1共同协作，**从而完成对交易的扩展，即提高TPS**。我们经常提到的：zkrollup、oprollup、侧链side chain等，指的就是layer2：

![image-20221118182033426](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221118182033426.png)

代表项目包括：

1. optimism：oprollup（EVM兼容）
2. arbitrum：oprollup（EVM兼容）
3. starkNet：zkrollup（EVM不兼容）
4. polygon：zkrollup（EVM不兼容）
5. zkSync：zkrollup（EVM兼容），目前唯一兼容EVM的zkrollup



**对于Layer2，我们会专门写一篇文章来介绍，详细介绍一下当下主流的扩容方案，以及它们各自的优缺点。**



## Layer3：纯应用层面

Layer3指的就是应用层面了，面向大众用户，这个和链无关。

![image-20221118182052183](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221118182052183.png)





## 总结

花点了解了每一层所做的事，应该可以有效的避免被忽悠😄；接下来我们会介绍一下当前主流的以太坊扩容方案，总结一下各方利弊。



参考文章：https://medium.com/@nick.5montana/blockchain-layers-l0-l1-l2-l3-in-a-diagram-569162398db

