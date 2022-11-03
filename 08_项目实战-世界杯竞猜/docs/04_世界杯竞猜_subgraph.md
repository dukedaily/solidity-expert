# 第4节：世界杯竞猜（subgraph）

>  本文收录于我的开源项目：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。



## 概述

subgraph是DAPP领域最重要的基建之一，主流协议都在使用，其功能为：

- 链下监听事件，逻辑处理，存储到数据库中，供前端调用；
- 常用于：统计历史信息等，仅做展示相关，可以节约链上存储成本，且响应更快；
- 请求subgraph的时候使用[graphql](https://thegraph.com/docs/en/querying/graphql-api/)语言，而非sql语句。



下图的是uniswapV3的面板信息，其中绝大多数内容都取自subgraph服务。

![image-20221006102831823](assets/image-20221006102831823.png)



## 举例

- uniswap v3的[token功能](https://info.uniswap.org/#/tokens)主要是从subgraph中读取的

- 问：uniswapV3 查询当前有哪些pool？

- Url：https://api.thegraph.com/subgraphs/name/uniswap/uniswap-v3

- 请求语句：

  ```js
  {
    pools(
        first: 50 
        orderBy: totalValueLockedUSD 
        orderDirection: desc  
        subgraphError: allow) {    
        id    
        __typename  
      }
  }
  ```

- 请求结果：(部分)

  ```js
  {
    "data": {
      "pools": [
        {
          "id": "0x277667eb3e34f134adf870be9550e9f323d0dc24",
          "__typename": "Pool"
        },
        {
          "id": "0xa850478adaace4c08fc61de44d8cf3b64f359bec",
          "__typename": "Pool"
        },
        {
          "id": "0x8c0411f2ad5470a66cb2e9c64536cfb8dcd54d51",
          "__typename": "Pool"
        },
        {
          "id": "0x055284a4ca6532ecc219ac06b577d540c686669d",
          "__typename": "Pool"
        }
       ]
    }
  }
  ```



## 原理

1. 用户从合约侧发起交易；
2. 合约发送事件；
3. 由subgraph监听到该事件，并在内部执行逻辑（我们根据业务需求，自定义），处理后入库；
4. 用户（前端）从subgraph的数据空中读取数据，完成展示。

![subgraph流程图](assets/subgraph流程图.jpg)



## 可选资源

subgraph一共有三种模式可以使用，具体如下（我们使用第三种）：

1. the graph官方提供的host serivce模式（[已经废弃了](https://thegraph.com/blog/sunsetting-hosted-service/)）
2. the graph官方提供的去中心化网络：[subgraph studio](https://thegraph.com/docs/en/deploying/subgraph-studio/)（需要token支持，激励别人帮忙加速索引，请自行尝试）
3. 使用the graph官方提供的开源代码自己搭建：**（推荐，[官方指导](https://thegraph.academy/developers/local-development/)）**
   1. 先试用docker创建一个：graph node
   2. 在graph node上部署subgraph



## 关系梳理

graph node和subgraph的关系如下，在graph node上可以部署多个subgraph，每个subgraph可以服务多个不同的项目。官方的host service（已经废弃），就是帮我们创建了一个graph node。

![graphnode](assets/graphnode.jpg)

下面我们聊一聊如何进行使用docker搭建graphnode并部署自己的subgraph。



## 创建subgraph

安装命令graph，用于创建subgraph项目，编译，部署等。

```sh
#安装命令
npm install -g  @graphprotocol/graph-cli
```

初始化项目

```sh
graph init
```

具体选项跟随引导程序填写，选择：网络-> 名称-> 合约地址 -> 合约名字，引导程序会自动在网络上拉取ABI（前提是我们verify了，否则需要自己填写）

![image-20221008181919484](assets/image-20221008181919484.png)

由于我们将自己搭建graphnode，而不是使用官方的host service，所以可以忽略Next Steps中提示的内容。

查看一下目录结构如下：

![image-20221008182708149](assets/image-20221008182708149.png)

## 业务改造

在配置文件中增加扫块起点`startBlock`，如果不增加，则从最初开始扫块，效率太低了。

![image-20221008182827679](assets/image-20221008182827679.png)



## 小结

到这里，我们已经介绍了subgraph的基本概念，并且完成了对subgraph的基本框架的搭建，下一节，我们将编写具体的业务逻辑，完成对世界杯玩家的激励。



---

加V入群：Adugii，公众号：[阿杜在新加坡](https://mp.weixin.qq.com/s/kjBUa2JHCbOI_2UKmZxjJQ)，一起抱团拥抱web3，下期见！



> 关于作者：国内第一批区块链布道者；2017年开始专注于区块链教育(btc, eth, fabric)，目前base新加坡，专注海外defi,dex,元宇宙等业务方向。