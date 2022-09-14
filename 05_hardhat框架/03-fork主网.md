参考链接：https://blog.csdn.net/weixin_43840202/article/details/121114097



impersonate_account:

```js
async function f1(){
  await hardhat.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [被模拟的账户],
  });
  const signer = await ethers.provider.getSigner(被模拟的账户)
  // 用模拟的账户给指定账户转账
  await signer.sendTransaction({
    to: "0x23FCB0E1DDbC821Bd26D5429BA13B7D5c96C0DE0",
    value: ethers.utils.parseEther("1.0"),
  });
  console.log('success')

// 取消模拟
  await hardhat.network.provider.request({
    method: "hardhat_stopImpersonatingAccount",
    params: [被模拟的账户],
  });
}

f1().then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

完整demo

```js
import { network, ethers, waffle } from "hardhat";
import { Signer } from "ethers";

async function main() {
    await network.provider.request({
        method: "hardhat_impersonateAccount",
        params: ["0xE78388b4CE79068e89Bf8aA7f218eF6b9AB0e9d0"],
    });

    let [acc0] = await ethers.getSigners()
    console.log('acc0:', acc0.address);
    let bal = await ethers.provider.getBalance(acc0.address)
    //10000000000000000000000
    console.log('acc0 bal:', bal.toString());

    const signer = await ethers.provider.getSigner(
        "0xE78388b4CE79068e89Bf8aA7f218eF6b9AB0e9d0"
    );

    await signer.sendTransaction({
        to: acc0.address,
        value: ethers.utils.parseEther("20") // 20 ether
    });

    bal = await ethers.provider.getBalance(acc0.address)
    //10020000000000000000000
    console.log('new acc0 bal:', bal.toString());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
```

