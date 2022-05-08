# 第4节：Send Ether（transfer、send、call）

https://docs.soliditylang.org/en/latest/security-considerations.html#sending-and-receiving-ether

### 如何发送ether？

有三种方式可以向合约地址转ether：

1. transfer（2300 gas， throw error）
2. send（2300 gas，return bool）
3. call（传递交易剩余的gas或设置gas，不限定2300gas，return bool）==(推荐使用)==

### 如何接收ether？

想接收ether的合约至少包含以下方法中的一个：

1. receive() external payable：msg.data为空时调用
2. fallback() external payable：msg.data非空时调用

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ReceiveEther {
    /*
    Which function is called, fallback() or receive()?

              sender ether
                  	|
             msg.data is empty?
                /  		\
            yes					no
             /					 \
      receive() exist?	fallback()
          /      \
        yes       no
       /         	  \
  receive()  		   fallback()
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
        // This is the current recommended method to use.
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

