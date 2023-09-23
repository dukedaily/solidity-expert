#  第1节：Hello world

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
>职场进阶: https://dukeweb3.com

1. pragma solidity ^0.8.13; 表明当前编译合约的版本号，向上兼容至0.9

```js
// SPDX-License-Identifier: MIT
// compiler version must be greater than or equal to 0.8.13 and less than 0.9.0
pragma solidity ^0.8.13;

contract HelloWorld {
    string public greet = "Hello World!";
}
```

