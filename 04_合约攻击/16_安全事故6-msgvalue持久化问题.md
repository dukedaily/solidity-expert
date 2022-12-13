# 第16节：安全事故5-msgvalue持久化问题

> 本文收录于我的开源项目：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。

在如下代码中，存在msg.value被重复使用的问题：在delegatecall中，msg.value与当前batch函数中msg.value一致，这可能导致错误。

```js
function batch(bytes[] calldata calls, bool revertOnFail) external payable returns(bool[] memory success, bytes[] memory results) {
  successes = new bool[](calls.length);
  results = new bytes[](calls.length);
  
  for (uint256 i=0; i< calls.length; i++) {
    (bool success, bytes memory result) = address(this).delegatecall(calls[i]);
    require(success || !revertOnFail, _getReyerMsg(result));
    successes[i] = success;
    results[i] = result;
  }
}
```

我们写一个测试案例：

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract batch {
    uint public num;
    address public sender;
    uint public value;

    function mintBatch(uint _num) public payable {
        // Proxy's storage is set, Implementation is not modified.
        for (uint i = 0; i < _num; i++) {
          (bool success, bytes memory data) = address(this).delegatecall(
              abi.encodeWithSignature("mint(uint256)", _num)
          );
        }
    }

    function mint(uint _num) public payable {
        require(msg.value == 1 ether, "error");
        num = _num;
        sender = msg.sender;
        value += msg.value;
    }
}
```

执行结果：

- 调用mintBatch时传入1ETH，内部会调用mint30次；
- 理论上一共应该话费30ETH，但是实际上每次delegatecall执行后这1ETH都会返回到当前的合约中，并在下次循环时被重复使用；

![image-20221213151222766](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221213151222766.png)

解决思路：

- 在使用delegatecall时如果涉及到了msg.value，不用与for循环配合使用。