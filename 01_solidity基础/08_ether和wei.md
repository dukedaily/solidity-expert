# 第8节：ether和wei

- 常用单位为：wei，gwei，ether
- 不含任何后缀的默认单位是 wei
- 1 gwei = 10^9 wei

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract EtherUnits {
    uint public oneWei = 1 wei;
    // 1 wei is equal to 1
    bool public isOneWei = 1 wei == 1;

    uint public oneEther = 1 ether;
    // 1 ether is equal to 10^18 wei
    bool public isOneEther = 1 ether == 1e18;
}

```

