# 第7节：selector

1. 当调用某个function时，具体调用function的信息会被拼装成**calldata**，calldata的前4个字节就是这个function的selector，其中：

   1. 通过selector可以知道调用的是哪个function；
   2. calldata 可以通过msg.data获取。

2. 通过拼装selector和函数参数，我们可以在A合约中得到calldata，并在A合约中通过call方法去调用B合约中的方法，从而实现合约间的调用。举例，下面的代码功能是：在当前合约中使用**call**调用**addr**地址中的**transfer**方法：

   ```js
   // 在合约中，一个function的4字节selector可以通过abi.encodeWithSignature(...)来获取
   // "0xa9059cbb"
   bytes memory transferSelector = abi.encodeWithSignature("transfer(address,uint256)");
   
   // 调用合约
   addr.call(transferSelector, 0xSomeAddress, 100); 
   
   // 一般会写成一行
   // addr.call(abi.encodeWithSignature("transfer(address,uint256)"), 0xSomeAddress, 100);
   ```

3. 另外一种计算selector的方式为：（keccak256即sha3哈希算法）

   ```js
   bytes4(keccak256(bytes("transfer(address,uint256)"))) //不用关心返回值，不用放在这里面计算。
   ```

4. 在合约内部也可以直接获取selector

   ```js
   // 假设当前合约内有transfer函数
   this.transfer.selector
   ```

5. 也可以使用abi.encodeCall方式获取

   ```js
   interface IERC20 {
   		function transfer(address, uint) external;
   }
   
   function encodeCall(address to, uint amount) external pure returns (bytes memory) {
   	  // Typo and type errors will not compile
     	return abi.encodeCall(IERC20.transfer, (to, amount));
   }
   ```

### 完整demo：

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20 {
    function transfer(address, uint) external;
}

contract FunctionSelector {
    event Selector(bytes4 s1, bytes4 s2);

    //_func示例值: "transfer(address,uint256)"
    function getSelector(string calldata _func) external pure returns (bytes4, bytes memory) {
        bytes4 selector1 = bytes4(keccak256(bytes(_func)));
        bytes memory selector2 = abi.encodeWithSignature(_func);

		// 两者相同
      	// 0: bytes4: 0xa9059cbb
		// 1: bytes: 0xa9059cbb
        return (selector1, selector2);
    }
  
   	function encodeWithSignature(address to, uint amount)
        external
        pure
        returns (bytes memory)
    {
        // Typo is not checked - "transfer(address, uint)"，不会检查参数类型
        return abi.encodeWithSignature("transfer(address,uint256)", to, amount);
    }

    function encodeWithSelector(address to, uint amount)
        external
        pure
        returns (bytes memory)
    {
        // Type is not checked - (IERC20.transfer.selector, true, amount) ，不会检查to, amount类型
        return abi.encodeWithSelector(IERC20.transfer.selector, to, amount);
    }

    function encodeCall(address to, uint amount) external pure returns (bytes memory) {
        // Typo and type errors will not compile，校验最严格
        return abi.encodeCall(IERC20.transfer, (to, amount));
    }
}
```

### 补充知识点

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
     let sig1 = web3.eth.abi.encodeEventSignature(transferEvent)
     let sig2 = web3.eth.abi.encodeFunctionSignature(transferEvent)
     
     // 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
     console.log('event sig1:', sig1)
     
     // 0xddf252ad
     console.log('event sig2:', sig2)
   
     let transferFun = "transfer(address,uint256)"
     let sig3 = web3.eth.abi.encodeFunctionSignature(transferFun)
     
     // 0xa9059cbb，差一个字母千差万别
     console.log('Function sig:', sig3)
   }
   ```

4. 哈希算法：

   ```js
   // keccak256与sha3和算法相同  ==》  brew install sha3sum
   // sha256属于sha2系列(与sha3不同)。
   ```
   
5. 





