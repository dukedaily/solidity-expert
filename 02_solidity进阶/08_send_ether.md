# 第8节：Send Ether（transfer、send、call）

https://docs.soliditylang.org/en/latest/security-considerations.html#sending-and-receiving-ether

### 如何发送ether？

有三种方式可以向合约地址转ether：

1. transfer（2300 gas， throw error）
2. send（2300 gas，return bool）
3. call（传递交易剩余的gas或设置gas，不限定2300gas，return bool）(推荐使用)



总结：transfer() 和 send() 函数使用 2300 gas 以防止重入攻击，但公链升级后可能导致 gas 不足。所以推荐使用 call() 函数，但需做好重入攻击防护。



### 如何接收ether？

想接收ether的合约至少包含以下方法中的一个：

1. receive() external payable：msg.data为空时调用（为接收ether而生，仅solidity 0.6版本之后)
2. fallback() external payable：msg.data非空时调用（为执行default逻辑而生，**顺便支持接收ether**）

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ReceiveEther {
    /*
    Which function is called, fallback() or receive()?

                sender ether
                    |
             msg.data is empty?
                /       \
            yes          no
             /             \
      receive() exist?     fallback()
          /    \
        yes     no
       /          \
  receive()     fallback()
  */

    string public message;

    // Function to receive Ether. msg.data must be empty
    receive() external payable {
        message = "receive called!";
    }

    // Fallback function is called when msg.data is not empty
    fallback() external payable {
        message = "fallback called!";
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function setMsg(string memory _msg) public {
        message = _msg;
    }
}

contract SendEther {
    function sendViaTransfer(address payable _to) public payable {
        // This function is no longer recommended for sending Ether. (不建议使用)
        _to.transfer(msg.value);
    }

    function sendViaSend(address payable _to) public payable {
        // Send returns a boolean value indicating success or failure.
        // This function is not recommended for sending Ether. (不建议使用)
        bool sent = _to.send(msg.value);
        require(sent, "Failed to send Ether");
    }

    function sendViaCallFallback(address payable _to) public payable {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use. (推荐使用)
        (bool sent, bytes memory data) = _to.call{value: msg.value}(abi.encodeWithSignature("noExistFuncTest()"));
        require(sent, "Failed to send Ether");
    }

    function sendViaCallReceive(address payable _to) public payable {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.(推荐使用)
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
}
```

解析：

- 调用sendViaTransfer或sendViaSend的时候，假设构造这笔交易时，你传入的gas时：1000000 gas

  此时，在使用transfer和send转账的时候，只会传递2300个gas，如果接收者是个合约，这个合约必须有fallback，此时这个fallback里面不能有逻辑，否则会超过2300gas，导致转账失败。

- sendViaCall的时候，，假设构造这笔交易时，你传入的gas时：1000000 gas
  此时在调用call的时候，也可以完成转账，但是会把1000000传递给fallback，即在fallback中你可以实现自己复杂的逻辑。
