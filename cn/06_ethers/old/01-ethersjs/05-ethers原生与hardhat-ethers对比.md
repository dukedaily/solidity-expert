# 原生ethers
## 部署合约

```js
//let web3Provider = new ethers.providers.Web3Provider(currentProvider);
let provider = ethers.getDefaultProvider('ropsten');

let signer = new ethers.Wallet(privateKey, provier)

let factory = new ethers.ContractFactory(abi, bytecode, signer)

let contract = await factory.deploy(参数1，参数2)

let tx = await contract.deployed()
await tx.await()
```

## 调用合约

```js
let provider = ethers.getDefaultProvider('kovan')
const provider_default = new ethers.providers.JsonRpcProvider(); //默认localhost:8545
const provider_default = new ethers.providers.JsonRpcProvider('自定义'); //infura或者alchemy

let signer = new ethers.Wallet(privateKey, provider)

//let contract = new ethers.Contract(address, abi, provider)  //读
let contract = new ethers.Contract(address, abi, signer) //读写

let currentValue = await contract.getValue()

let tx = await contract.setValue(100).wait()
```



# hardhat ethers
## 部署合约

```js
const hre = require("hardhat");
const { ethers } = hre;
//注意，这里的ethers是hardhat-ethers实例，是在hardhat.config.js中导入的

//这里的ethers已经注入了provider，根据hardhat选择的网络
const factory = await ethers.getContractFactory("合约名字");

const contract = await factory.deploy(参数1，参数2);

await contract.deployed();
```



## 调用合约

```js
const [deployer] = await ethers.getSigners()
//const deployerAddress = deployer.address
  
const contract = await ethers.getContractAt(abi, address, deployer)

let tx = await contract.setValue(100).wait()
```

其他：

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
    console.log('x:', x);

    let accs = await hre.ethers.provider.listAccounts()
    for (let key in accs) {
        console.log('acc:', accs[key]);
    }

}

main()
```

额外提供的ethers方法：

```js
interface Libraries {
  [libraryName: string]: string;
}

interface FactoryOptions {
  signer?: ethers.Signer;
  libraries?: Libraries;
}

function getContractFactory(name: string): Promise<ethers.ContractFactory>;

function getContractFactory(name: string, signer: ethers.Signer): Promise<ethers.ContractFactory>;

function getContractFactory(name: string, factoryOptions: FactoryOptions): Promise<ethers.ContractFactory>;


function getContractAt(nameOrAbi: string | any[], address: string, signer?: ethers.Signer): Promise<ethers.Contract>;

function getSigners() => Promise<ethers.Signer[]>;

function getSigner(address: string) => Promise<ethers.Signer>;
```

