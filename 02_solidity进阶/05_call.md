# 第5节：call

**call**是一种底层调用合约的方式，可以在合约内调用其他合约，call语法为：

```js
//(bool success, bytes memory data) = addr.call{value: valueAmt, gas: gasAmt}(abi.encodeWithSignature("foo(string,uint256)", 参数1, 参数2)
其中：
1. success：执行结果，一定要校验success是否成功，失败务必要回滚
2. data：执行调用的返回值，是打包的字节序，需要解析才能得到调用函数的返回值（后续encode_decode详解）
```

当调用fallback方式给合约转ether的时候，**建议使用call**，而不是使用transfer或send方法

```js
(bool success, bytes memory data) = addr.call{value: 10}("")
```

对于存在的方法，不建议使用call方式调用。

```js
(bool success, bytes memory data) = _addr.call(abi.encodeWithSignature("doesNotExist()"));
```

**调用不存在的方法（又不存在fallback）时，交易会调用成功，但是第一个参数为：false。**



### 完整demo:

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Receiver {
    event Received(address caller, uint amount, string message);

    fallback() external payable {
        emit Received(msg.sender, msg.value, "Fallback was called");
    }

    function foo(string memory _message, uint _x) public payable returns (uint) {
        emit Received(msg.sender, msg.value, _message);

        return _x + 1;
    }
}

contract Caller {
    event Response(bool success, bytes data);

    function testCallFoo(address payable _addr) public payable {
        // You can send ether and specify a custom gas amount
        (bool success, bytes memory data) = _addr.call{value: msg.value, gas: 5000}(
            abi.encodeWithSignature("foo(string,uint256)", "call foo", 123)
        );

        emit Response(success, data);
    }

    // Calling a function that does not exist triggers the fallback function.
    function testCallDoesNotExist(address _addr) public {
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("doesNotExist()")
        );

        emit Response(success, data);
    }
}
```

