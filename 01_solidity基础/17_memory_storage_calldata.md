# 第17节：存储位置-memory、storage、calldata

solidity中的存储位置分为三种，使用memory、storage、calldata来进行区分：

- storage：属于状态变量，数据会存储在链上，仅适用于所有引用类型：string，bytes，数组，结构体，mapping等；
- memory：仅存储在内存中，供函数使用，数据不上链，适用于所有类型，包括：
  - 值类型（int，bool，bytes8等）
  - 引用类型（string，bytes，数组，结构体，mapping）
- calldata：存储函数的参数的位置，是只读的-
- 其他：Solidity 变量中 memory 、calldata 2 个表示作用非常类似，都是函数内部临时变量，它们最大的区别就是 calldata 是不可修改的，在某些只读的情况比较省 Gas.

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract DataLocations {
    uint[] public arr = [1, 2, 3];
    mapping(uint => address) public map;
    struct MyStruct {
        uint foo;
    }
    mapping(uint => MyStruct) public myStructs;

    function test() public {
        // get a struct from a mapping
        MyStruct storage myStruct = myStructs[1];

        // create a struct in memory
        MyStruct memory myMemStruct = MyStruct(0);

        // call _f with state variables
        _f(arr, map, myStruct);

        //invalid convertion, failed to call
        // _f(arr, map, myMemStruct); 

        _g(arr);
        this._h(arr);
    }

    function _f(
        uint[] storage _arr,
        mapping(uint => address) storage _map,
        MyStruct storage _myStruct
    ) internal {
        // do something with storage variables
        _arr.push(100);
        _map[20] = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        _myStruct.foo = 20;
    }

    // You can return memory variables
    function _g(uint[] memory _arr) public returns (uint[] memory) {
        // do something with memory array
        _arr[0] = 100;
    }

    function _h(uint[] calldata _arr) external {
        // do something with calldata array
        // calldata is read-only
        // _arr[2] = 200;
    }
}
```

