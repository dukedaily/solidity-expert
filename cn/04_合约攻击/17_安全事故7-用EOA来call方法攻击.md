# 第17节：安全事故6-用EOA来call方法攻击

合约地址与EOA地址的调用区别：

1. 注意，当使用合约进行call，delegatecall调用函数时，是永远都不会抛出异常的，哪怕被调用的函数不存在，它只能返回true或false。
   1. 当被调用的函数存在时，返回true，不存在时返回false；（fallback不存在情况下）
   2. 如果被调用函数不存在，但是实现了fallback，则返回true；

2. 对于非合约地址（EOA）调用函数时（这个是恶意行为，因为EOA根本没有函数），只要这个EOA的gas足够即可，返回的bool值居然永远都是true！
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

			// 这个居然是true，这个存在攻击可能
      console.log("result:", success);
    }

    function TestNotExist(uint _num) public payable {
      (bool success, bytes memory data) = address(this).call(
        abi.encodeWithSignature("notExist(uint256)", _num)
      );

			// true，因为执行了fallback
			// 如果fallback不存在，则返回false，但是不会抛异常
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



再次强调：在使用call调用外部函数的时候，要非常小心调用函数的内部实现，如果`函数` 未实现，但是实现了 `fallback` ，此时也会返回true。

所以，对于这种`caller`是用户可以传递的场景，要格外注意！

![img](https://duke-typora.s3.amazonaws.com/ipic/2022-12-14-003908.png)
