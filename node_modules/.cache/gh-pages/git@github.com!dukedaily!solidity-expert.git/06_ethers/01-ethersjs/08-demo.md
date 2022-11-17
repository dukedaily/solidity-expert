```js
import { deployments } from 'hardhat';
import hre from 'hardhat'

const sleep = (ms: number) =>
    new Promise((resolve) =>
        setTimeout(() => {
            resolve(1);
        }, ms)
    );

async function main() {
    //返回所有的地址signer对象，不是地址，包括了私钥，和provider
    let [accounts_0] = await hre.ethers.getSigners()
    console.log('accounts_0:', accounts_0.address);

    //使用地址，生成signer对象
    let deployer = await hre.ethers.getSigner(accounts_0.address)
    console.log('deployer:', deployer.address);

    let x = await hre.getNamedAccounts()
    // console.log('x:', x);

    let accs = await hre.ethers.provider.listAccounts()
    for (let key in accs) {
        console.log('acc:', accs[key]);
    }

    //1. 测试部署
    let factory = await hre.ethers.getContractFactory('Counter')
    let contract1 = await factory.deploy()
    console.log('contract:', contract1.address);

    let tx = await contract1.deployed()
    // console.log('tx:', tx);

    // let contract2 = factory.attach(contract1.address)
    //测试获取合约实例
    let contract2 = await hre.ethers.getContractAt('Counter', contract1.address)
    console.log('contract2 address:', contract2.address);

    //测试读写
    let count = await contract2.getCount()
    console.log('count:', count.toString());

    let tx1 = await (await contract2.countUp()).wait()
    console.log('tx1:', tx1);

    count = await contract2.getCount()
    console.log('new count:', count.toString());

    // ******************
    // deployer.sendTransaction() //TODO  ethers 目前不知道，
    // ethers: 没有找到ethers对data进行编码的方法
    // web3: 有方法：const data = contract.methods.createAccount(params.accountType).encodeABI() 
}

main()
```

