# 第20节：链下签名signature

在openzeppelin标准合约中，已经实现了对ECDSA标准合约，我们拆解一下，整个签名验证过程可以分为三个阶段（详见下图）

1. 阶段一：打包原始消息，生成hash
2. 阶段二：添加前缀，生成待签名的hash
3. 阶段三：解析签名，获得解析的地址1
4. 阶段四：校验地址1与实际签名的地址

![image-20221127223259928](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221127223259928.png)



- 理论详见：08\_项目实战-世界杯竞猜/07\_世界杯竞猜_链下签名.md
- 代码详见：https://github.com/dukedaily/hello-erc20-permit
