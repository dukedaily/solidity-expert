# 第1节：uniswapV2部署文档	

## 一、概述

refer: https://segmentfault.com/a/1190000040401731

node版本：

1.	node版本： v14.17.0
2.	nvm install v14.17.0
3.	nvm use v14.17.0
4.	==删除node_module时，把lock文件一并删除==

## 二、合约

### 1. core

```sh
yarn && yarn compile
yarn test
```

### 2. periphery

```sh
yarn && yarn compile
yarn test
```

### 3. deploy工厂合约

1. 部署factory前，先在factory中添加代码，用于计算：INIT_CODE_HASH

```sh
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(UniswapV2Pair).creationCode));
```

![image-20211215220204063](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20211215220204063.png)

2. 修改外围工程的UniswapV2Library.sol中，搜索：function pairFor，将hex更换为我们的：INIT_CODE_HASH，注意：去掉0x

![image-20211215220457939](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20211215220457939.png)

3. 部署router2

```sh
WETH = '0xd0a1e359811322d97991e03f863a0c30c2cf029c'
factory: 0xd41130E9142c64Da60908d2a6Bd0eD191Bc6d7E4
router2: 0xDC292C81e24efB77Bc69e6d3727E3727EC1bF170 (verify)

INIT_CODE_HASH = '0x1a2b467a96f24f635e38aa0d5eb137af393113cb941125f3cbf3d93857eb6e69'

Aave DAI:  0xff795577d9ac8bd7d90ee22b6c1703490b6512fd
Aave WBTC:  0xd1b98b6607330172f1d991521145a22bce793277
```



## 三、sdk

### 1. uniswap/sdk

在github上fork一下这个工程。

```sh
git@github.com:dukedaily/uniswap-sdk-v2.git
```

clone到本地：

```sh
git clone git@github.com:dukedaily/uniswap-sdk-v2.git
```

修改uniswap/sdk中的数据，替换为我们部署的FACTORY_ADDRESS和INIT_CODE_HASH：

```sh
# uniswap-sdk-v2/src/constants.ts

export const FACTORY_ADDRESS = '0xd41130E9142c64Da60908d2a6Bd0eD191Bc6d7E4'

export const INIT_CODE_HASH = '0x1a2b467a96f24f635e38aa0d5eb137af393113cb941125f3cbf3d93857eb6e69'
```

安装&编译：

```sh
yarn &yarn build
```

提交代码到github上，注意，将dist也传上去，需要修改.gitignore

## 四、interface

### 1. 引用sdk

下载工程：使用v2.6.5版本，之后的版本有治理功能，我们不需要。

```sh
git clone https://github.com/Uniswap/uniswap-interface.git
cd uniswap-interface && git checkout v2.6.5
```

v2.6.5版本的interface在package.json中，使用的sdk版本为：

```sh
@uniswap/sdk": "3.0.3-beta.1",
```

但是当前uniswap官网上已经不提供这个版本了，我们上面clone的工程就是这个版本的。我们会替换掉这个默认的版本，修改package.json，将

```sh
"@uniswap/sdk": "3.0.3-beta.1",
```

修改为：

```sh
 "@uniswap/sdk": "git://github.com/dukedaily/uniswap-sdk-v2.git",
```

表示这个sdk去我们的github工程中下载。

### 2. 自定义token列表

token.json，上传到gist中：https://gist.github.com/，

```json
{
    "name": "DAI Aave List",
    "version": {
        "major": 1,
        "minor": 0,
        "patch": 0
    },
    "logoURI": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0/logo.png",
    "timestamp": "2021-07-25 00:00:00.000+00:00",
    "tokens": [
        {
            "chainId": 42,
            "address": "0xff795577d9ac8bd7d90ee22b6c1703490b6512fd",
            "name": "DAIAAVE Token",
            "symbol": "DAI",
            "decimals": 18,
            "logoURI": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0/logo.png"
        },
        {
            "chainId": 42,
            "address": "0xd1b98b6607330172f1d991521145a22bce793277",
            "name": "WBTCAAVE Token",
            "symbol": "WBTC",
            "decimals": 8,
            "logoURI": "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0/logo.png"
        }

    ]
}
```

上传后，点击raw可以得到链接：

![image-20211215221937889](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20211215221937889.png)

https://gist.githubusercontent.com/dukedaily/ad8881018f36b3e508d4fd40d6777de3/raw/3bccf12ce45eda66034a101bfaa1213e9f2fb6a3/gistfile1.json

可以将这个页面将链接添加到uniswap的token列表中，也可以在程序中写死：

![image-20211215222139155](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20211215222139155.png)

### 3. 修改路由地址

index.ts中：

```js
export const ROUTER_ADDRESS = '0xDC292C81e24efB77Bc69e6d3727E3727EC1bF170'
```

依次执行如下命令：

```sh
yarn &yarn build

yarn start
```

增加中间币种兑换（路由）

![image-20220607150148813](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20220607150148813.png)

### 4. 部署github.io

1. 修改package中的homepage为：'https://dukedaily.github.io/chfry-uniswap'
2. 增加命令： "deploy": "gh-pages -d build",
3. yarn add gh-pages
4. yarn build
5. git add .
6. git commit -m "uniswap exchange deployment"
7. git push
8. yarn deploy
9. 访问：https://dukedaily.github.io/chfry-uniswap/index.html#/swap