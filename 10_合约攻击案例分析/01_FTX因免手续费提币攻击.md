# FTX因免手续费提币，被黑客0元购XEN Token技术分析

> 本文收录于我的开源项目：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。



## 背景介绍

Xen Token最近太火了，算是熊市中的一股清流，让死寂的币圈又活跃了起来。

这个项目的参与算是0门槛，只需要支付gas费就可以mint，然后claim，越早进入mint的token越多，收益越高。

这么火🔥的项目自然会走入黑客的视野，果然，一场风暴就此降临。只不过受害者不是Xen Token项目方，而是无辜的FTX交易所，具体攻击结果为：

1. 黑客通过FTX的免手续费提币功能，通过技术手段，让FTX支付手续费，疯狂调用Xen mint 1.7万次，获得大量的Xen Token，并通过Uniswap等dex将Xen兑换为61个ETH，完成套现。
2. FTX交易所前后损失：80多个ETH。



## 发起攻击

首先，在10月10日，攻击者EOA（0x1d371CF00038421d6e57CFc31EEff7A09d4B8760）在以太坊链上部署了攻击合约（0xCba9b1Fd69626932c704DAc4CB58c29244A47FD3）

![image-20221014004119421](assets/image-20221014004119421.png)

随后发起攻击，具体流程为：攻击者不断的从FTX交易所向攻击合约提小额ETH，数量为：0.00350242ETH，如下图：

![image-20221014004310723](assets/image-20221014004310723.png)

这个攻击合约是没有代码开源的，但是我们知道：如果一个合约想接受别人转入ether，那么合约内部必须实现fallback函数或者receive函数（两者具体差异参见文末教程），由于fallback中有mint逻辑，所以一定是fallback函数。每一笔攻击交易详情如下图：

交易：https://etherscan.io/tx/0xc06bda5b8d7f4bb4510521e14edce590c0e74f1944157c58b70c6749d0fa1009

![image-20221014004134405](assets/image-20221014004134405.png)

交易流水：使用chrome插件eigentx，我们可以查看图示化的流水，请根据数字编号追踪，最终都留到了leaf中，即黑客的EOA。

![image-20221014004144529](assets/image-20221014004144529.png)



## 攻击交易跟踪

通过链上交易call trace工具：https://tx.eth.samczsun.com/ethereum/0xc06bda5b8d7f4bb4510521e14edce590c0e74f1944157c58b70c6749d0fa1009，我们可以进一步跟踪交易链路，具体如下图：

![image-20221014004332664](assets/image-20221014004332664.png)



## 完整攻击流程

综上所述，我们得知攻击可能的完整流程为：

1. 攻击者在FTX上进行小额提币ETH，收款地址为自己的攻击合约（实现了fallback方法）；
2. fallback内部创建1～3个子合约；
3. 在子合约中：先调用xen的claimRank得到xen；
4. 在子合约中：再调用claimMintRewardAndShare方法，将子合约持有的xen转给黑客的EOA；
5. 子合约自杀；



## 为什么会出问题

1. 提币有漏洞：提币转账的时候，没有限定接收方的地址进行限定（如不允许是合约，这个一般不会限定），更重要的是没有对这个交易的gaslimit进行设置，使得攻击代码可以顺利执行。

   

2. 风控不及时：对于高频次（本次共攻击1.7万次）、相同金额的转账却没有及时发现异常。

   从攻击合约部署：Oct-10-2022 05:20，到实际发生mint攻击：Oct-11-2022 05:51:47 AM ，整整24h小时内，黑客其实一直在提币（但是没有mint xen），FTX一直没有发现，直至又mint两天之后，才发现异常，这确实让人匪夷所思。



## 总结

最近黑客是真的抢眼，先是TP钱包的approve问题，再是bsc跨链桥被盗，再到今天的FTX被撸gas问题，看来区块链安全问题已经刻不容缓了，这也是本人接下来的重点方向。



## 本文涉及到的工具

1. 交易链路分析：https://tx.eth.samczsun.com/ethereum
2. token流水展示：https://chrome.google.com/webstore/detail/eigentx/gmjkhhheaknfaekapfiedhohdilpmgci?hl=en-GB
3. 以太坊区块链教程：https://github.com/dukedaily/solidity-expert（500star）





加V入群：Adugii，公众号：阿杜在新加坡，一起抱团拥抱web3，下期见！

> 关于作者：国内第一批区块链布道者；2017年开始专注于区块链教育(btc, eth, fabric)，目前base新加坡，专注海外defi,dex,元宇宙等业务方向。