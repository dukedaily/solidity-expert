# 第15节：import

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

我们可以使用import将本地的.sol文件或外部（github或openzeppelin等）.sol导入进来

```js
├── Import.sol
└── Foo.sol
```

Fool.sol

常量、函数、枚举、结构体、Error可以定义在合约之外；事件、变量不允许定义在合约之外。

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

struct Point {
    uint x;
    uint y;
}

// 事件不允许定义在合约之外
// event Greeting(string);

error Unauthorized(address caller);

string constant greeting = "hell world";

function add(uint x, uint y) pure returns (uint) {
    return x + y;
}

contract Foo {
    string public name = "Foo";
}
```

Import.sol

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// import Foo.sol from current directory
import "./Foo.sol";

// import {symbol1 as alias, symbol2} from "filename";
import {Unauthorized, add as func, Point} from "./Foo.sol";

contract Import {
    // Initialize Foo.sol
    Foo public foo = new Foo();

    // Test Foo.sol by getting it's name.
    function getFooName() public view returns (string memory) {
        return foo.name();
    }

    function myAdd() public pure returns(uint) {
        return func(1,2);
    }

    function greetingCall() public pure returns(string memory) {
        return greeting;
    }
}
```

导入外部文件：

```js
// https://github.com/owner/repo/blob/branch/path/to/Contract.sol
import "https://github.com/owner/repo/blob/branch/path/to/Contract.sol";

// Example import ECDSA.sol from openzeppelin-contract repo, release-v4.5 branch
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/cryptography/ECDSA.sol
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/cryptography/ECDSA.sol";

```

