# provider

1. 所有读取链上数据信息的操作都是有provider提供的
2. 所有写、签名等数据都是wallet实现的。
3. 与链上信息交互的内容使用provider

```js
// 可以使用任何标准网络名称做参数：
//  - "homestead"
//  - "rinkeby"
//  - "ropsten"
//  - "kovan"
//  - "goerli"

let provider = ethers.getDefaultProvider('ropsten');
```

4. 也可以直接调用合约，是低级调用，不建议
5. 获取账号余额

```js
let address = "0x02F024e0882B310c6734703AB9066EdD3a10C6e0";

provider.getBalance(address).then((balance) => {

    // 余额是 BigNumber (in wei); 格式化为 ether 字符串
    let etherString = ethers.utils.formatEther(balance);

    console.log("Balance: " + etherString);
});
```

6. 获取当前状态：

```js
provider.getBlockNumber().then((blockNumber) => {
    console.log("Current block number: " + blockNumber);
});

provider.getGasPrice().then((gasPrice) => {
    // gasPrice is a BigNumber; convert it to a decimal string
    gasPriceString = gasPrice.toString();

    console.log("Current gas price: " + gasPriceString);
});
```

7. 为什么要使用wait

```js
    //sendTransaction内部会使用wallet进行签名:signedTransaction
    //返回值是一个response不是receipt，wait之后是receipt
    //这是与web3库不同之处
    let recepit = await (await wallet.sendTransaction(transaction)).wait()
    console.log('recepit:', recepit);
```

结果：

```sh
recepit: {
  to: '0x6491D615b6DB93154d6123e97751897CCe524787',
  from: '0xEf884C06F2aBf71040ff28976E3a85DDa8813ab2',
  contractAddress: null,
  transactionIndex: 0,
  gasUsed: BigNumber { _hex: '0x5208', _isBigNumber: true },
  logsBloom: '0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',
  blockHash: '0x1474eb339219d25cac26ebe358bec46894757cbdb3e847c095eb07c74804d4e0',
  transactionHash: '0x8e80d43da4c20bb44420bfd3dff300ef573a550125a96b2fb7ac52a321333001',
  logs: [],
  blockNumber: 29052026,
  confirmations: 15,
  cumulativeGasUsed: BigNumber { _hex: '0x5208', _isBigNumber: true },
  effectiveGasPrice: BigNumber { _hex: '0x04a817c800', _isBigNumber: true },
  status: 1,
  type: 2,
  byzantium: true
}
```

8. 使用第三方链接：

```js
// 可以使用任何标准网络名称做参数：
//  - "homestead"
//  - "rinkeby"
//  - "ropsten"
//  - "kovan"

let defaultProvider = ethers.getDefaultProvider('ropsten');

// ... 或 ...

let etherscanProvider = new ethers.providers.EtherscanProvider('ropsten');

// ... 或 ...

let infuraProvider = new ethers.providers.InfuraProvider('ropsten');
```

8. 链接自定义节点：

```js
// 在使用JSON-RPC API时，将自动检测网络

// 默认: http://localhost:8545
let httpProvider = new ethers.providers.JsonRpcProvider();

// 通过定制 URL 连接 :
let url = "http://something-else.com:8546";
let customHttpProvider = new ethers.providers.JsonRpcProvider(url);

// 通过 IPC 命名管道
let path = "/var/run/parity.ipc";
let ipcProvider = new ethers.providers.IpcProvider(path);
```

9. 链接一个已有的web3

```js
// 使用 Web3 provider 时, 自动检测网络

// e.g. HTTP provider
let currentProvider = new web3.providers.HttpProvider('http://localhost:8545');

let web3Provider = new ethers.providers.Web3Provider(currentProvider);
```

10. 关系：InfuraProvider顶层是JsonRpcProvider
11. 原生ethers自己的rpc交互

```js
let ethers = require('ethers')

let privateKey = "";

// let provider = ethers.getDefaultProvider('kovan')
let ALCHEMY_KEY = "https://eth-kovan.alchemyapi.io/v2/FKPQya5-fdpIyRPdKyr3KB2Q02hW626y"

let f6 = async () => {
    // let p = new ethers.providers.JsonRpcProvider('http://localhost:8545')
    // 允许连接到我们控制或可以访问的以太坊节点（包括主网，测试网，权威证明（PoA）节点或Ganache）
    // getDefaultProvider 里面也是调用的: JsonRpcProvider
    let p = new ethers.providers.JsonRpcProvider(ALCHEMY_KEY)
    // let accounts = await p.listAccounts()
    // console.log('accoutns:', accounts);

    let signer = new ethers.Wallet(privateKey, p)
    console.log('addr:', await signer.getAddress());

    let bal = await signer.getBalance()
    console.log('bal:', bal.toString());
}

f6()
```

