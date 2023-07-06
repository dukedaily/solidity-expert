# 第5节：跨链桥anyswap

参考文档：https://docs.multichain.org/getting-startted

# 链下依赖：SMPC

multichain有一个MPC network自己的网络，这个网络主要是用来维护签名私钥的

# Bridge&Router

在跨链过程中，可以选择不同的router，有点类似于uniswap的兑换路由。需要sign，跨链免费，但是gasfee为0.03（当前），跨链是时间为10～30分钟，最小跨链金额0.004ETH，最大1700ETH

![image-20221105112209697](https://duke-typora.s3.amazonaws.com/ipic/2022-11-20-021542.png)

存款流程

![image-20221105112905413](https://duke-typora.s3.amazonaws.com/ipic/2022-11-20-021755.png)

取款流程

![image-20221105112922970](https://duke-typora.s3.amazonaws.com/ipic/2022-11-20-21756.png)

## Cross-Bridge

>  **The Cross-Chain Bridges are a foundation block of Multichain**: A Bridge allows an asset on one chain to be 'sent' to another chain.

每次创建bridge的时候，所有桥上的资产有node来共同维护，创建持有，并在跨链的时候，转给目标用户的钱包地址。



## Cross-Router

> Enables any assets to be transferred between multiple chains, no matter if they are native or created with Multichain's Bridge.

### 1. NATIVE Assets

对于已经存在的Token资产，使用liquidate pool来解决，为了防止流动性不足，使用自己发行的anyToken来进行过渡（用于处理pool资金不足的情况）

![image-20221105124234564](https://duke-typora.s3.amazonaws.com/ipic/2022-11-20-021757.png)

### 2. Bridged Assets

使用AnyswapV5ERC20.sol新创建的token，此时不需要lp池子

### 3. Hybird Native/Bridge Assets

混合模式，有token，也要新mint的，For FTM, The Router uses native FTM on Ethereum, Binance Smart Chain and Fantom Opera, but is Bridged to Cronos, Telos, Boba, Celo and Harmony.



# 测试网络（不可用）

目前测试网络仅支持rinkeby和FTM，测试没成功：https://docs.multichain.org/developer-guide/token-router-testnet

# 各方角色

## 官方部署合约

1. 部署Admin
2. 部署实现：AnyCallV7Upgradeable
3. 部署：AnycallV7Proxy，内部通过data指定来initialize的参数data



## 用户部署A链合约

A链合约中，根据业务需求，最终调用AnycallV7Proxy的anyCall方法，调用后请求会发送到SMPC网络，最终传递到B链

```js
pragma solidity ^0.8.10;

/// IAnycallProxy interface of the anycall proxy
interface IAnycallProxy {
    function executor() external view returns (address);

    function anyCall(
        address _to, // B链合约地址
        bytes calldata _data, //B链执行的数据 
        uint256 _toChainID, // B链ID
        uint256 _flags,
        bytes calldata _extdata
    ) external payable;
}
```



## 用户部署B链合约

B链合约中，需要实现一个方法，供SMPC网络调用

```
function anyExecute(bytes calldata data) external override onlyExecutor returns (bool success, bytes memory result)
```



# 工作流程

anycall proxy is a universal protocal to complete cross-chain interaction.

1. the client call `AnycallV7Proxy::anyCall`
   - on the originating chain
   - to submit a request for a cross chain interaction
2. the mpc network verify the request and call `AnycallV7Proxy::anyExec`
   - on the destination chain
   - to execute a cross chain interaction (exec `IApp::anyExecute`)
3. if step 2 failed and step 1 has set allow fallback flags,
   - then emit a `LogAnyCall` log on the destination chain
   - to cause fallback on the originating chain (exec `IApp::anyFallback`)





# 自己运行demo

https://github.com/dukedaily/multchain-anycallv7-example

```sh
# 0x48636063bD54f705E8c5b5858a0462F896c05ADC
yarn hardhat deploy --network ftmtest

# 0x8B43B8E728Af345830732A6A0Bd78BB754Fd51a3
yarn hardhat deploy --network bnbtest

 yarn hardhat run ./scripts/1testanycall.js --network bnbtest
```

## 运行成功分析

- 在bsc测试网发送交易，此时会调用官方anyCallProxyV7里面的 [anyCall](https://testnet.bscscan.com/tx/0x52f6fbfbfb0119bbb655946672f56368d9a10b5686fa9b6428207123e09a39bc)，发送事件；
- SMPC网络会监听事件，然后在B链发起调用；
- B链调用是有官方的anyCallProxyV7发起调用的，调用B链合约的[anyExec](https://testnet.ftmscan.com/tx/0x56a7c1d1c38c4adc9795d55ab418f8bf18ab012f118137556c0fbedf1ebd4961)方法。

[点击查看](https://testnet.ftmscan.com/tx/0x56a7c1d1c38c4adc9795d55ab418f8bf18ab012f118137556c0fbedf1ebd4961#eventlog)

![image-20221105172320826](https://duke-typora.s3.amazonaws.com/ipic/2022-11-20-21758.png)



## [A链BSC效果（发送交易）](https://testnet.bscscan.com/tx/0x52f6fbfbfb0119bbb655946672f56368d9a10b5686fa9b6428207123e09a39bc)



![image-20221105172453919](https://duke-typora.s3.amazonaws.com/ipic/2022-11-20-021759.png)

## [B链FTM效果（执行交易，获取消息）](https://testnet.ftmscan.com/tx/0x56a7c1d1c38c4adc9795d55ab418f8bf18ab012f118137556c0fbedf1ebd4961)

![image-20221105172352072](https://duke-typora.s3.amazonaws.com/ipic/2022-11-20-021801.png)



# 涉及到的地址

| Name            | Address                                    | Chained |
| --------------- | ------------------------------------------ | ------- |
| A链BSC Dapp     | 0x8B43B8E728Af345830732A6A0Bd78BB754Fd51a3 | 97      |
| B链FTM Dapp     | 0x48636063bD54f705E8c5b5858a0462F896c05ADC | 4002    |
| A链BSC官方Proxy | 0xcBd52F7E99eeFd9cD281Ea84f3D903906BB677EC | 97      |
| B链FTM官方Proxy | 0xfCea2c562844A7D385a7CB7d5a79cfEE0B673D99 | 4002    |



# 结论

1. 目前集成multichain的demo已经跑通
2. multichain需要依赖他们自己的SMPC网络（主要是完成区中心化签名问题，多个节点维护私钥）