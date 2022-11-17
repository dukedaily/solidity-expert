# 第七节：Moralis基建

作为一个dapp开发，把一些基础的数据信息交给第三方服务看似不可靠，但是这和我们使用云主机又有什么区别呢？

https://moralis.io/



## 提供服务

1. 提供扫快的api等
2. 提供基本的存储能力（没错，他们提供数据库，使用地址sign登录作为session），可以存储和读取对应的数据，用的是mongodb

```js
// 这个句代码，将所有的页面串联起来了，数据通过这个useMoralis获取、传递
import { useMoralis } from "react-moralis";
```

3. 使用私钥签名登录后台，从而实现与对应的数据看进行访问。完成profile等数据存储。如果不这样做，没办法处理这些profile的。



## 查询token种类

指定一个EOA地址，查询持有token的种类以及数量，这个功能需要扫链来实现，Moralis提供了相应的API接口。示例：查看rinkeby网络，account：0xEf884C06F2aBf71040ff28976E3a85DDa8813ab2

1. 查看持有的erc20 token

```js
curl -X 'GET' \
  'https://deep-index.moralis.io/api/v2/0xEf884C06F2aBf71040ff28976E3a85DDa8813ab2/erc20?chain=rinkeby' \
  -H 'accept: application/json' \
  -H 'X-API-Key: ix9R1cyuOsdtAElOtcN0i0uMa7foYNoKpUOyNihzDjvMBDRUpiB98nfnsZJ8WQ1D'
```

2. 查看持有的nft token

```sh
curl -X 'GET' \
  'https://deep-index.moralis.io/api/v2/0xEf884C06F2aBf71040ff28976E3a85DDa8813ab2/nft?chain=rinkeby' \
  -H 'accept: application/json' \
  -H 'X-API-Key: ix9R1cyuOsdtAElOtcN0i0uMa7foYNoKpUOyNihzDjvMBDRUpiB98nfnsZJ8WQ1D'
```
