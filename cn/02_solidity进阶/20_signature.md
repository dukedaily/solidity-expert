# 第20节：链下签名signature-EIP191

在openzeppelin标准合约中，已经实现了对ECDSA标准合约，我们拆解一下，整个签名验证过程可以分为三个阶段（详见下图）

1. 阶段一：打包原始消息，生成hash
2. 阶段二：添加前缀，生成待签名的hash
3. 阶段三：解析签名，获得解析的地址1
4. 阶段四：校验地址1与实际签名的地址

![image-20221127223259928](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221127223259928.png)



- 理论详见：[07\_世界杯竞猜_链下签名](https://dukedaily.github.io/solidity-expert/08_%E9%A1%B9%E7%9B%AE%E5%AE%9E%E6%88%98-%E4%B8%96%E7%95%8C%E6%9D%AF%E7%AB%9E%E7%8C%9C/docs/07_%E4%B8%96%E7%95%8C%E6%9D%AF%E7%AB%9E%E7%8C%9C_%E9%93%BE%E4%B8%8B%E7%AD%BE%E5%90%8D.html)
- 代码详见：https://github.com/dukedaily/hello-erc20-permit
