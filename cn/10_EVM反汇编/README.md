工具：

1. 在线decompile：https://www.ethervm.io/decompile
2. 命令行decompile：https://github.com/Arachnid/evmdis
3. python decompile：https://github.com/crytic/pyevmasm
4. 图形化decompile：https://github.com/crytic/ethersplay
5. 其他：https://www.pnfsoftware.com/blog/ethereum-smart-contract-decompiler/
6. signature查询：https://www.4byte.directory/



## 反汇编系列文章

1.  [***Reversing and debugging EVM Smart contracts: First steps in assembly\* (part** ](https://medium.com/@TrustChain/reversing-and-debugging-evm-smart-contracts-392fdadef32d)**1️⃣**[**)**](https://medium.com/@TrustChain/reversing-and-debugging-evm-smart-contracts-392fdadef32d)
2.  [*Reversing and debugging EVM Smart contracts: Deployment of a smart contract* ***(Part\*** ](https://medium.com/@TrustChain/reversing-and-debugging-evm-smart-contracts-part-2-e6106b9983a)2️⃣[***)\***](https://medium.com/@TrustChain/reversing-and-debugging-evm-smart-contracts-part-2-e6106b9983a)
3. [*Reversing and debugging EVM Smart contracts: How the storage layout works?* ***(part\*** ](https://medium.com/@TrustChain/reversing-and-debugging-ethereum-evm-smart-contracts-part-3-ebe032a08f97)3️⃣[***)\***](https://medium.com/@TrustChain/reversing-and-debugging-ethereum-evm-smart-contracts-part-3-ebe032a08f97)
4. [*Reversing and Debugging EVM Smart contracts: 5 Instructions to end/abort the Execution* ***(part\*** ](https://medium.com/@TrustChain/reversing-and-debugging-evm-the-end-of-time-part-4-3eafe5b0511a)4️⃣[***)\***](https://medium.com/@TrustChain/reversing-and-debugging-evm-the-end-of-time-part-4-3eafe5b0511a)
5. [*Reversing and debugging EVM Smart contracts: The Execution flow if/else/for/functions* ***(part\*** ](https://medium.com/@TrustChain/reversing-and-debugging-evm-the-execution-flow-part-5-2ffc97ef0b77)5️⃣[***)\***](https://medium.com/@TrustChain/reversing-and-debugging-evm-the-execution-flow-part-5-2ffc97ef0b77)
6. [*Reversing and debugging EVM Smart contracts: Full Smart Contract layout* ***(part\*** ](https://medium.com/@TrustChain/reversing-and-debugging-part-6-full-smart-contract-layout-f236c3121bd1)6️⃣[***)\***](https://medium.com/@TrustChain/reversing-and-debugging-part-6-full-smart-contract-layout-f236c3121bd1)
7. [*Reversing and debugging EVM Smart contracts: External Calls and contract deployment* **(part** 7️⃣**)**](https://medium.com/@TrustChain/reversing-and-debugging-the-evm-part-7-2a20a44a555e)





## 计算方法的sig

https://web3playground.io/

 ```js
 async function main() {
   let transferEvent = "Transfer(address,address,uint256)"
   let sig1 = web3.eth.abi.encodeEventSignature(transferEvent)
   let sig2 = web3.eth.abi.encodeFunctionSignature(transferEvent)
   
   //should be: 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
   console.log('event sig1:', sig1)
   console.log('event sig2:', sig2)
 
   let transferFun = "test()"
   let sig3 = web3.eth.abi.encodeFunctionSignature(transferFun)
   console.log('Function sig:', sig3)
 }
 ```

