# 第10节：fallback

1. fallback是特殊的函数，无参数，无返回值；
2. 何时会被调用：
   1. 当被调用的方法不存在时，fallback会被调用，属于default函数；
   2. 当向合约转ether但是合约不存在receive函数时；
   3. 当向合约转ether但是msg.data不为空时。（即使receive存在）
3. 当使用transfer或者send对合约进行转账时，fallback函数的gaslimit限定为2300 gas

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Fallback {
    event Log(uint gas);

    // Fallback function must be declared as external.
    fallback() external payable {
        // send / transfer (forwards 2300 gas to this fallback function)
        // call (forwards all of the gas)
        emit Log(gasleft());
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract SendToFallback {
    function transferToFallback(address payable _to) public payable {
      	// Log event:  "gas": "2254"
        _to.transfer(msg.value);
    }

    function callFallback(address payable _to) public payable {
        // Log event:  "gas": "6110"
        (bool sent, ) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
  
     function callNoExistFunc(address payable _to) public payable {
        // call no exist funtion will call fallback by default 
        // Log event:  "gas": "5146"
        (bool sent, ) = _to.call{value: msg.value}(abi.encodeWithSignature("noExistFunc()"));
        require(sent, "Failed to call");
    }
}
```

