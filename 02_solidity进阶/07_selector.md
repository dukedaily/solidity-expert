# 第4节：selector

1. 当调用某个function时，具体调用function的信息会被拼装成**calldata**，calldata的前4个字节就是这个function的selector，其中：

   1. 通过selector可以知道调用的是哪个function；
   2. calldata 可以通过msg.data获取。

2. 通过拼装selector和函数参数，我们可以在A合约中得到calldata，并在A合约中通过call方法去调用B合约中的方法，从而实现合约间的调用。举例，下面的代码功能是：在当前合约中使用**call**调用**addr**地址中的**transfer**方法：

   ```js
   bytes memory transferSelector = abi.encodeWithSignature("transfer(address,uint256)");
   addr.call(transferSelector, 0xSomeAddress, 100);
   // "transferSelector" "0xa9059cbb"
   
   // 一般会写成一行
   // addr.call(abi.encodeWithSignature("transfer(address,uint256)"), 0xSomeAddress, 100);
   ```

   在合约中，一个function的4字节selector可以通过**abi.encodeWithSignature(...)**来获取

3. 另外一种计算selector的方式为：（keccak256即sha3哈希算法）

   ```js
   bytes4(keccak256(bytes("transfer(address,uint256)"))) //不用关心返回值，不用放在这里面计算。
   ```

4. 在合约内部也可以直接获取selector

   ```js
   // 假设当前合约内有transfer函数
   this.transfer.selector
   ```

### 完整demo：

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract FunctionSelector {

    event Selector(bytes4 s1, bytes4 s2);

    // _func: "transfer(address,uint256)"
    function getSelector(string calldata _func) external pure returns (bytes4, bytes memory) {
        bytes4 selector1 = bytes4(keccak256(bytes(_func)));
        bytes memory selector2 = abi.encodeWithSignature(_func);
        return (selector1, selector2);
    }
}
```

### 其他知识

1. 一般提到signature的方法指的是函数原型：

   ```js
   "transfer(address,uint256)"
   ```

2. 一般提到selector指的是前4字节

   ```js
   // bytes4(keccak256(bytes("transfer(address,uint256)")))
   "Function sig:" "0xa9059cbb"
   ```

3. 链下方式计算selector（详见在web3.js和ether.js章节），[点击](https://web3playground.io/QmRkM4oxkQVTV7JcGxuUpnYvuA2yhMWg867DnFiNVE1Y9K)执行demo

   ```js
   async function main() {
     let transferEvent = "Transfer(address,address,uint256)"
     let sig = web3.eth.abi.encodeEventSignature(transferEvent)
     let sig2 = web3.eth.abi.encodeFunctionSignature(transferEvent)
     
     //should be: 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
     console.log('event sig1:', sig)
     console.log('event sig2:', sig2)
   
     let transferFun = "transfer(address,uint256)"
     let sig3 = web3.eth.abi.encodeFunctionSignature(transferFun)
     console.log('Function sig:', sig3)
   }
   ```

4. 哈希算法：

   ```js
   // keccak256与sha3和算法相同  ==》  brew install sha3sum
   // sha256属于sha2系列(与sha3不同)。
   ```







