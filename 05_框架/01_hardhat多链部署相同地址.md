# 第1节:hardhat

不同网络部署相同的地址：[xdeployer](https://www.npmjs.com/package/xdeployer)，每次执行只能部署一个合约。

1. 安装插件

   ```js
   npm install --save-dev xdeployer
   ```

2. hardhat.config.ts中增加：

   ```js
   import "xdeployer";
   ```

3. 增加配置

   ```js
       xdeploy: {
           contract: "Mock1Inch",
           //constructorArgsPath: "",
           constructorArgsPath: "./deploy-args.ts",
           salt: "Bydefi",
           signer: process.env.PRIVATE_KEY,
           networks: ["hardhat", "ropsten"],
           rpcUrls: ["hardhat", NETWORKS_RPC_URL["ropsten"]],
           gasLimit: DEFAULT_BLOCK_GAS_LIMIT
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
   ```

4. 构造函数的格式：./deploy-args.ts

   ```js
   const data = [
     "arg1",
     "arg2",
     ...
   ];
   
   export { data };
   ```

5. 增加contracts/Create2DeployerLocal.sol

   ```js
   // SPDX-License-Identifier: MIT
   
   pragma solidity ^0.8.9;
   
   import "xdeployer/src/contracts/Create2Deployer.sol";
   
   contract Create2DeployerLocal is Create2Deployer {}
   ```

6. 执行部署命令：

   ```sh
   npx hardhat xdeploy
   ```

7. 支持的网络

   ```sh
   localhost,hardhat,rinkeby,ropsten,kovan,goerli,sepolia,bscTestnet,optimismTestnet,arbitrumTestnet,mumbai,hecoTestnet,fantomTestnet,fuji,sokol,moonbaseAlpha,alfajores,auroraTestnet,harmonyTestnet,spark,cronosTestnet,ethMain,bscMain,optimismMain,arbitrumMain,polygon,hecoMain,fantomMain,avalanche,gnosis,moonriver,moonbeam,celo,auroraMain,harmonyMain,autobahn,fuse,cronos.
   ```

# 原理

研究一下这个合约代码：https://bscscan.com/address/0x13b0d85ccb8bf860b6b79af3029fca081ae9bef2

目前在bsc主网可以正常部署，但是arbitrium上部署失败，我是通过参考bsc合约的deploy参数，在arbi上手动调用的deploy，也完成 合约的部署和verify。

# 手动地址

xdeployer地址：0x13b0d85ccb8bf860b6b79af3029fca081ae9bef2

1. 找到这个地址
2. 调用deploy方法：
   1. 
