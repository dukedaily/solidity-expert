import { ethers } from "hardhat";

async function main() {
  // 0xEAd54777D54C2C1bE1458E749fDfB5d654458309
  const senderPrivateKey = "0xa7b0f6c4cddc5c818655f5c0eb9e42f803dcc400ec284521e9092e8b243473c3"
  const provider_default = new ethers.providers.JsonRpcProvider("https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161");

  let sender = new ethers.Wallet(senderPrivateKey, provider_default)
  // 获取地址，与hardhat原生的不一样
  let senderAddr = await sender.getAddress()

  // 提前转入足量的eth和token
  let balance = await sender.getBalance()
  console.log('balance Of Ether: ' + balance, ', sender:', senderAddr)

  const contractAddr = "0x11Fe617f76aC652F995E7BA0fE4001F741e6d003"

  // 这里要加上signer
  let contractInstance = await ethers.getContractAt("Test", contractAddr, sender)
  console.log('contractInstance:', contractInstance.address);
  console.log("balance of sender:", await contractInstance.BalanceOf(senderAddr))

  //1. 构造攻击bytecode
  let transferToCode = contractInstance.interface.encodeFunctionData("transferTo", ["0xdfca6234eb09125632f8f3c71bf8733073b7cd00", 123])
  // 0x2ccb1b30000000000000000000000000dfca6234eb09125632f8f3c71bf8733073b7cd00000000000000000000000000000000000000000000000000000000000000007b
  // 0x2ccb1b30000000000000000000000000dfca6234eb09125632f8f3c71bf8733073b7cd000000000000000000000000000000000000000000000000000000000000007b, 剪掉两个0
  console.log('transferToCode:', transferToCode);

  // 2. 发起攻击 
  const tx = {
    // data: '0x2ccb1b30000000000000000000000000dfca6234eb09125632f8f3c71bf8733073b7cd000000000000000000000000000000000000000000000000000000000000007b', //invalid data
    data: '0x2ccb1b30000000000000000000000000dfca6234eb09125632f8f3c71bf8733073b7cd00000000000000000000000000000000000000000000000000000000000000007b', // valid data
    nonce: 1,//你发送交易的帐号的最后一笔交易的 nonce + 1
    gasLimit: '0x2dc6c0',
    gasPrice: '0x2540be400',
    value: '0x0',
    to: contractAddr
  }

  let signedTx = await sender.signTransaction(tx)
  console.log('signedTx:', signedTx);


  let res = await sender.sendTransaction(tx)
  console.log("tx hash:", res.hash);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
