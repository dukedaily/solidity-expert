# 第2节：payable

1. 一个函数（或地址）如果想接收ether，需要将其修饰为：**payable**。
2. address常用方法：
   1. balance(): 查询当前地址的ether余额
   2. transfer(uint): 合约向当前地址转指定数量的ether，如果失败会回滚
   3. send(uint): 合约向当前地址转指定数量的ether，如果失败会返回false，不回滚==（不建议使用send）==

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Payable {
    // 1. Payable address can receive Ether
    address payable public owner;

    // 2. Payable constructor can receive Ether
    constructor() payable {
        owner = payable(msg.sender);
    }

    // 3. Function to deposit Ether into this contract.
    function deposit() public payable {}

    // 4. Call this function along with some Ether.
    // The function will throw an error since this function is not payable.
    function notPayable() public {}

    // 5. Function to withdraw all Ether from this contract.
    function withdraw() public {
        uint amount = address(this).balance;
        owner.transfer(amount);
    }

    // 6. Function to transfer Ether from this contract to address from input
    function transfer(address payable _to, uint _amount) public {
        _to.transfer(_amount);
    }
}
```

