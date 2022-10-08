# 第2节：世界杯精彩_hardhat框架



## 内容概述

通过学习，掌握最主流的开发框架hardhat，从而了解如何管理以太坊工程代码，并掌握如何进行常用操作，单元测试等。

1. [点击查看效果](https://solidity-expert.vercel.app/)
1. [点击获取代码](https://github.com/dukedaily/solidity-expert/tree/main/14_项目实战-世界杯竞猜/worldcup)



## 前置条件

- 了解JavaScript（TypeScript）

- 了解合约开发基础



## 学习目标

1. 了解技术栈、hardhat框架使用：编译、部署、verify、单元测试、查看size、部署消耗gas统计
   1. 早期2018年工具链：solidity(0.4.16) + truffle + infura （rpc）+ web3.js（重，强大） + js
   2. 目前2022年工具链：solidity(0.8.16) + hardhat + alchemy （更快）+ ethers.js（轻） + ts

1. 学习官方demo

1. 合约集成WorldCup合约，完成部署、verify、单元测试



## 正文开始

1. 基础安装

```Bash
#创建npm空项目
npm init 

#安装命令，对照两个版本的差异性
npm install --save-dev hardhat@2.11.1 # 新案例，新工具包
npm install --save-dev hardhat@2.9.7

#创建工程
npx hardhat-》选择高级ts项目

#运行测试（默认已经不支持）
npx hardhat accounts

#编译合约
npx hardhat compile

#单元测试
npx hardhat test

#运行脚本，部署合约
npx hardhat run scripts/deploy.ts

#启动节点node
npx hardhat node

#部署合约到本地node节点
npx hardhat run scripts/deploy.ts --network localhost

#verify
npx hardhat verify 合约地址  参数1 参数2 --network 网络      
```

1. 目录结构

```Bash
contracts：合约
scripts：脚本
test：单元测试
hardhat.config.ts：配置文件
package.json：包管理文件
```

## 知识小结

配置文件：

```JavaScript
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

//在配置文件中引用
require('dotenv').config()

let ALCHEMY_KEY = process.env.ALCHEMY_KEY || ''
let INFURA_KEY = process.env.INFURA_KEY || ''
let PRIVATE_KEY = process.env.PRIVATE_KEY || ''
let ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || ''

console.log(ALCHEMY_KEY);
console.log(INFURA_KEY);
console.log(PRIVATE_KEY);
console.log(ETHERSCAN_API_KEY);

const config: HardhatUserConfig = {
    // solidity: "0.8.9",
    // 配置网络 kovan, bsc, mainnet
    networks: {
        hardhat: {
        },
        goerli: {
            url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_KEY}`,
            accounts: [PRIVATE_KEY]
        },
        kovan: {
            url: `https://kovan.infura.io/v3/${INFURA_KEY}`,
            accounts: [PRIVATE_KEY]
        }
    },
    // 配置自动化verify相关
    etherscan: {
        apiKey: {
            goerli: ETHERSCAN_API_KEY
        }
    },
    // 配置编译器版本
    solidity: {
        version: "0.8.9",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200
            }
        }
    },
};

export default config;
```

## 部署脚本

```JavaScript
import { ethers } from "hardhat";

async function main() {
  const TWO_WEEKS_IN_SECS = 14 * 24 * 60 * 60;
  const deadline = 1663150345 + TWO_WEEKS_IN_SECS;

  const WorldCup = await ethers.getContractFactory("WorldCup");
  const worldcup = await WorldCup.deploy(deadline);

  await worldcup.deployed();

  console.log(`new worldcup deployed to ${worldcup.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

## 下次预告

- 主流token协议（脱离业务）
  - ERC20 -> USDT，DAI，approve, allowance, transfer, transferFrom, safeTransfer...
  - ERC721 -> NFT1
  - ERC1155 -> NFT2

## 资源链接

- hardhat手册：https://hardhat.org/hardhat-runner/docs/getting-started#overview

- ethers.js: https://docs.ethers.io/v5/

- 详细知识点托管在github：https://github.com/dukedaily/solidity-expert