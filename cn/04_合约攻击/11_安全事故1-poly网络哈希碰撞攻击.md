# 第11节：安全事故1-poly网络哈希碰撞攻击

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。

通过构造特定的合约calldata（主要是四字节的sig），可以实现攻击，这个四字节sig可以通过hash碰撞来实现，August 10, 2021 ploy网络的攻击就是这个原理，

慢雾分析：[点击查看](https://slowmist.medium.com/the-root-cause-of-poly-network-being-hacked-ec2ee1b0c68f)

BlockSec分析：[点击查看](https://blocksecteam.medium.com/the-initial-analysis-of-the-polynetwork-hack-270ac6072e2a)

```sh
byte4(keccak256(transfer(address,uint256))) = 0xa9059cbb
```

**合约关系：**

![image-20221211173609673](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221211173609673.png)

