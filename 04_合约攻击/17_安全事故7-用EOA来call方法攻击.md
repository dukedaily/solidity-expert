# 第17节：安全事故6-用EOA来call方法攻击

合约地址与EOA地址的调用区别：

1. 调用合约时，需要合约有对应的方法，否则会去执行fallback函数，如果fallback不存在，则合约执行成功，但是返回的bool值为false，详见：call章节；
2. 但是对于非合约地址（EOA）则没有这样的要求，只要这个EOA的gas足够即可，故意使用EOA来调用合约方法时，返回的bool值居然是true！
3. 攻击案例：[QBridege安全事件](https://halborn.com/explained-the-qubit-hack-january-2022/)

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "hardhat/console.sol";

contract Test {		
    function TestEOA(uint _num) public payable {
      address EOA = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
      (bool success, bytes memory data) = address(EOA).call(
        abi.encodeWithSignature("mint(uint256)", _num)
      );

			// true
      console.log("result:", success);
    }

    function TestNotExist(uint _num) public payable {
      (bool success, bytes memory data) = address(this).call(
        abi.encodeWithSignature("notExist(uint256)", _num)
      );

			// true，因为执行了fallback
			// 如果fallback不存在，则返回false
      console.log("result:", success);  
    }

    function TestExist(uint _num) public payable {
      (bool success, bytes memory data) = address(this).call(
          abi.encodeWithSignature("mint(uint256)", _num)
      );

      // true
      console.log("result:", success);
    }

    function mint(uint _num) public payable {
        console.log("mint called:", _num);
    }

    fallback() external payable {
      console.log("fallback called!");
    }
}
```

执行结果，三个方法返回的都是true

![image-20221213154459295](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221213154459295.png)
