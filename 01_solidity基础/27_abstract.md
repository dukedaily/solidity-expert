# 第27节：abstract

手册：https://docs.soliditylang.org/en/v0.8.14/contracts.html?highlight=abstract#abstract-contracts

抽象合约的作用是将函数定义和具体实现分离，从而实现解耦、可拓展性，其使用规则为：

1. 当合约中有未实现的函数时，则合约必须修饰为abstract；
2. 当合约继承的base合约中有构造函数，但是当前合约并没有对其进行传参时，则必须修饰为abstract；
3. abstract合约中未实现的函数必须在子合约中实现，即所有在abstract中定义的函数都必须有实现；
4. abstract合约不能单独部署，必须被继承后才能部署；

```js
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

abstract contract Animal {
    string public species;
    constructor(string memory _base) {
        species = _base;
    }
}

abstract contract Feline {
    uint public num;
    function utterance() public pure virtual returns (bytes32);

    function base(uint _num) public returns(uint, string memory) {
        num = _num;
        return (num, "hello world!");
    }
}

// 由于Animal中的构造函数没有进行初始化，所以必须修饰为abstract
abstract contract Cat1 is Feline, Animal {
    function utterance() public pure override returns (bytes32) { return "miaow"; }
}

contract Cat2 is Feline, Animal("Animal") {
    function utterance() public pure override returns (bytes32) { return "miaow"; }
}
```

