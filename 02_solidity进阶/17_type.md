# 第17节：type

https://docs.soliditylang.org/en/v0.6.5/units-and-global-variables.html#meta-type

type(x) 可以返回x类型的对象信息，例如：

- type(x).name: 合约的名字；
- type(x).creattionCode: 合约部署时的bytecode；
- type(x).runtimeCode: 合约运行时的bytecode，一般是构造函数数据，但是当constructor中有汇编时会有不同（没有仔细了解）。

```js
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract Storage {
    string public str;
    constructor(string memory _str) {
        str = _str;
    }

    uint256 number;


    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function store(uint256 num) public {
        number = num;
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256){
        return number;
    }

    function getInfo() public pure returns(string memory name) {
        name = type(Storage).name;

        // creationCode 和runtimeCode不能在这个合约自己内部使用，防止会出现循环调用问题
        // creationCode = type(Storage).creationCode;
        // runtimeCode = new type(Storage).runtimeCode;

    }
}

contract TestStorage {
    Storage s;
    constructor(Storage _address) {
        s = _address;
    }

    function getInfo() public view returns(bytes memory creationCode, bytes memory runtimeCode) {
        creationCode = type(Storage).creationCode;
        runtimeCode = type(Storage).runtimeCode;
    }
}
```

