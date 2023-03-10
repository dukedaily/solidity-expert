# 第三章：Token协议

从本章开始，我们将从语法层面跳出来，开始关注协议相关内容，由于Token协议是我们日常接触最多的落地应用，所以我们从Token合约入手。

我们将介绍主流的协议，包括：

- ERC20，这是标准的代笔协议，本质上就是一个solidity合约，代表协议如：USDT，WBTC等。
- ERC721，这个就是我们所谓的NFT（Non-Fungible Token），加密猫，无聊猿等。
- ERC1155，这是介于ERC20和ERC721之间的协议，属于半同质化合约协议（Semi Non-Fungible Token），它属于在Token层面是同质化，在Id层面是非同质化的Token
- 其他协议，待定



## 什么是EIP?

EIP：Ethereum Improvement Proposals

- https://eips.ethereum.org/all
- https://eips.ethereum.org/EIPS/eip-2535
- [TOP 10 EIP every WEB3 professional MUST know](https://medium.com/@trustchain/top-10-eip-every-web3-professional-must-to-know-677e8a7735f4)



## ERC和EIP的定义与区别？

EIP: Ethereum Improvement Proposals，[点击查看定义](https://eips.ethereum.org/)

![image-20221230153948642](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221230153948642.png)

ERC:  stands for Ethereum Request (for) Comments which outlines the set of rules and recommendations developers must follow in order to implement new features. ERCs are on-chain application layer related EIPs.

ERC是EIP的链上呈现状态，例如：标准代币的标准是`ERC20`，它的提议是：[EIP-20](https://eips.ethereum.org/EIPS/eip-20)