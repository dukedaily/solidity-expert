# 第3节：fork主网

hardhat提供了一个模拟主网的功能，使得我们可以直接使用主网的数据进行测试，需要我们：

1. 在配置文件hardhat.confit.ts中启动fork开关、指定网络、指定块高；
2. 在单元测试文件中做配置。



## impersonate_account

默认情况下，我们的hardaht账户在主网上是没有资产的，因此我们在使用fork功能时，需要impersonate（扮演）成其他地址（这个人在主网上，在我们指定的块高上，是有真实资产的），具体代码如下：

创建test.fork/sendTransactionFork.ts：(单独创建一个fork的文件夹，与原来的test分开)

```js
/* eslint-disable no-console */
import { network, ethers } from "hardhat";
// import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { JsonRpcServer } from "hardhat/types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { JsonRpcSigner } from "@ethersproject/providers";

describe("sendTransaction", () => {
  let signer: JsonRpcSigner;
  let acc0: SignerWithAddress;

  beforeEach(async () => {
    // https://etherscan.io/accounts
    const ETHWHALE = "0xF977814e90dA44bFA03b6295A0616a897441aceC";
    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [ETHWHALE],
    });

    //1. 获取hardaht内置账户
    const accounts = await ethers.getSigners();
    acc0 = accounts[0];
    console.log("acc0:", acc0.address);

    //2. 查看金额，应该为：10000000000000000000000（这是初始化的值）
    let bal = await ethers.provider.getBalance(acc0.address);
    console.log("acc0 bal:", bal.toString());

    //3. 重要‼️ acc0扮演成: 三方地址（有真实资产的地址），后续signer代表的就是这个三方地址了，而不是原来的acc0
    signer = ethers.provider.getSigner(ETHWHALE);
    bal = await ethers.provider.getBalance(signer.getAddress());
    
    //4. 查看这个资产
    console.log("ETHWHALE bal:", bal.toString());
  });

  describe("sendTransaction Test", () => {
    it("should send transaction", async () => {
      // 4. 测试一下，用三方地址给我们的acc0转账
      await signer.sendTransaction({
        to: acc0.address,
        value: ethers.utils.parseEther("20"),
      });

      const bal = await ethers.provider.getBalance(acc0.address);
      // 5. 查看acc0的金额，应该是：10020000000000000000000
      console.log("new acc0 bal:", bal.toString());
    });
  });
});

```

## 修改配置文件

hardhat.config.ts

```js
const mainnetFork = MAINNET_FORK  //我们使用环境变量来控制fork与否
  ? {
    url: 'urlxxxxx'
    blockNumber: 21577481,
  }
  : undefined;

const config: HardhatUserConfig = {
  networks: {
    bsc_main: 'urlxxxxx'
    hardhat: {
      blockGasLimit: DEFAULT_BLOCK_GAS_LIMIT,
      gas: DEFAULT_BLOCK_GAS_LIMIT,
      gasPrice: 8000000000,
      chainId: 56,
      throwOnTransactionFailures: true,
      throwOnCallFailures: true,
      accounts: 
      forking: mainnetFork  // 开关在这里生效
    },
  },
```

## 执行代码

```sh
 MAINNET_FORK=true npx hardhat test test.fork/sendTransactionFork.ts
```

![image-20221118095707119](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221118095707119.png)

