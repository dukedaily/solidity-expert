#  第1节：Hello world

1. pragma solidity ^0.8.13; 表明当前编译合约的版本号，向上兼容至0.9

```js
// SPDX-License-Identifier: MIT
// compiler version must be greater than or equal to 0.8.13 and less than 0.9.0
pragma solidity ^0.8.13;

contract HelloWorld {
    string public greet = "Hello World!";
}
```

