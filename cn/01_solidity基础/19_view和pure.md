# 第19节：view和pure

view和pure用于修饰Getter函数（只读取数据的函数），其中：

1. **view**：表示函数中不会修改状态变量，只是读取；
2. **pure**：表示函数中不会使用状态变量，既不修改也不读取。

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ViewAndPure {
    uint public x = 1;

    // Promise not to modify the state.
    function addToX(uint y) public view returns (uint) {
        return x + y;
    }

    // Promise not to modify or read from the state.
    function add(uint i, uint j) public pure returns (uint) {
        return i + j;
    }
}
```



