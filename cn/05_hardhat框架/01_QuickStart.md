# 第一节：快速体验QuickStart

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com



## 实用命令

```sh
## hh
npm install --global hardhat-shorthand

# 查看支持的网络
npx hardhat verify --list-networks
```



## 环境构造

```sh
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
```



## 目录结构

- contracts：合约
- scripts：脚本
- test：单元测试
- hardhat.config.ts：配置文件
- package.json：包管理文件



## hardhat-toolbox

当前版本：hardhat：^2.11.1，在配置文件中，引用了hardhat-toolbox包，这是一个集合，安装了常用的npm包。

```js
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.9",
};

export default config;
```



## 修改配置文件

1. 修改.env

   - rpc: alchemy（更快）：

   - rpc: infura：小狐狸使用的，以太坊基金会赞助：

   ```sh
   ETHERSCAN_API_KEY=
   ALCHEMY_KEY=
   INFURA_KEY=
   PRIVATE_KEY=
   ```

2. 安装dotenv

   ```sh
   npm install dotenv
   
   #在配置文件中引用
   require('dotenv').config()
   ```

3. 配置文件完整内容：

   ```ts
   import { HardhatUserConfig } from "hardhat/config";
   import "@nomicfoundation/hardhat-toolbox";
   // import * as dotenv from "dotenv";
   require('dotenv').config()
   
   const PRIVATE_KEY = process.env.PRIVATE_KEY || ''
   const ALCHEMY_KEY = process.env.ALCHEMY_KEY || ''
   const INFURA_KEY = process.env.INFURA_KEY || ''
   const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || ''
   
   console.log("PRIVATE_KEY: ", PRIVATE_KEY);
   console.log("ALCHEMY_KEY: ", ALCHEMY_KEY);
   
   const config: HardhatUserConfig = {
       networks: {
           hardhat: {
           },
           goerli: {
               url: `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_KEY}`,
               accounts: [PRIVATE_KEY]
           },
           mainnet: {
               url: `https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_KEY}`,
               accounts: [PRIVATE_KEY]
           },
           kovan: {
               // url: `https://eth-kovan.g.alchemy.com/v2/${ALCHEMY_KEY}`,
               url: `https://kovan.infura.io/v3/${INFURA_KEY}`,
               accounts: [PRIVATE_KEY]
           },
           ropsten: {
               // url: `https://eth-kovan.g.alchemy.com/v2/${ALCHEMY_KEY}`,
               url: `https://ropsten.infura.io/v3/${INFURA_KEY}`,
               accounts: [PRIVATE_KEY]
           }
       },
       solidity: {
           version: "0.8.9",
           settings: {
               optimizer: {
                   enabled: true,
                   runs: 200
               }
           }
       },
       etherscan: {
           apiKey: {
             ropsten: ETHERSCAN_API_KEY
           }
         }
   };
   
   export default config;
   ```


4. 部署不同网络

   ```js
   npx hardhat run scripts/deploy.ts --network ropsten    
   ```

5. Verify

   ```sh
   #https://ropsten.etherscan.io/address/0x61c8E000634154dF38B2ec23483fa2E08984d938#code
   
   npx hardhat verify 0x61c8E000634154dF38B2ec23483fa2E08984d938 1694667145  --network ropsten
   ```

   

## 参考链接

1. hardhat手册：https://hardhat.org/hardhat-runner/docs/getting-started#overview
1. alchemy：https://dashboard.alchemy.com/apps
1. infura：https://infura.io/

