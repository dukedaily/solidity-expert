![image-20221214195013732](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214195013732.png)

## 一、概览

- 框架，搭建pos区块链、模块化、基础模块

![image-20221214195035836](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214195035836.png)

- cosmos sdk构造应用
- ABCI进行通讯
- Tendermint是共识层（BFT共识机制）

![image-20221214195124958](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214195124958.png)

## 二、核心模块介绍

- 标准化、增加互操作性、使开发者专注专有链自身业务逻辑、示范模板

![image-20221214195614245](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214195614245.png)

## 三、核心模块详解

- pos：staking、distribution、slashing
- 治理：gov、upgrade
- 资产管理：bank、nft
- 权限管理：authz、feegrant、group

![image-20221214195821702](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214195821702.png)

### staking

staking模块提供pos能力，涉及到的主要概念为：验证人（validator）、委托人（delegator），validator又细分为：

- 验证人节点：参与共识
- 全节点：同步并执行区块，不参与共识
- 哨兵节点：保护验证人节点不受外部攻击的全节点

![image-20221214195902025](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214195902025.png)



![image-20221214200429147](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214200429147.png)



![image-20221214200538705](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214200538705.png)

### distribution

- 完全pos收益分发：通证增发、网络交易手续费、委托人向验证人支付佣金

![image-20221214200632276](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214200632276.png)

![image-20221214201450473](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214201450473.png)

![image-20221214201552390](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214201552390.png)

### Slashing

![image-20221214205757324](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214205757324.png)

### Gov

![image-20221214205941405](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214205941405.png)

![image-20221214210216332](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214210216332.png)

### upgrade

![image-20221214210357674](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214210357674.png) 

![image-20221214210644131](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214210644131.png)

### Bank

![image-20221214210906199](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214210906199.png)

![image-20221214211011937](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214211011937.png)

### NFT

![image-20221214211042370](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214211042370.png)

![image-20221214211242025](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214211242025.png)

- Bank + IBC ，DEX专有链
- Bank + NFT，NFT市场专有链

![image-20221214211331242](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214211331242.png)

### Authz

- 授权相关，转账相关，权限相关

![image-20221214211517311](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214211517311.png)

### FeeGrant

- 被授权的人可以花费授权者（Owner）的钱，要求Owner为其支付手续费（gasfee）

![image-20221214211701801](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214211701801.png)

### Group

![image-20221214211850123](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214211850123.png)

### 文档

![image-20221214211959228](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221214211959228.png)