# 第17节：存储位置-memory、storage、calldata

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

solidity中的存储位置分为三种，使用memory、storage、calldata来进行区分：

- storage：属于状态变量，数据会存储在链上，仅适用于所有引用类型：string，bytes，数组，结构体，mapping等；
- memory：仅存储在内存中，供函数使用，数据不上链，适用于所有类型，包括：
  - 值类型（int，bool，bytes8等）
  - 引用类型（string，bytes，数组，结构体，mapping）
- calldata：存储函数的参数的位置，是只读的（只有calldata支持数组切片，状态变量不可以直接使用切片，需要new新数组，然后使用for循环解决）
- 其他：Solidity 变量中 memory 、calldata 2 个表示作用非常类似，都是函数内部临时变量，它们最大的区别就是 calldata 是不可修改的，在某些只读的情况比较省 Gas.
- 局部变量（此处指引用类型）默认是Storage类型的，只能将使用storage类型赋值，不能使用memory类型来赋值。

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



## memory和storage进阶

```js
// SPDX-License-Identifier: MIT
pragma solidity =0.8.10;

import "hardhat/console.sol";

contract Test{

    constructor() {
        personArrayGlobal.push(Person("Lily", 20, true));
        personArrayGlobal.push(Person("James", 30, false));
    }

    struct Person {
        string name;
        uint256 age;
        bool married;
    }

    Person[] public personArrayGlobal;

    // remix: [["Lily", 20, true]]
    function changeTestMemory(Person[] memory _psersonArray) public {
        Person memory pTmp = _psersonArray[0];

        // error, 不能基于memory对象创建storage对象
        // Person storage pTmp = _psersonArray[0];
        _innerChangeMemory(pTmp);

        console.log(pTmp.name);             // David memory
        console.log(_psersonArray[0].name); // David memory，居然改变了！虽然在memory中，但是实际上也是传递的指针

        uint256 tmpInt = 200;
        _innerChangeInt(tmpInt);
        console.log(tmpInt);                // 200，指类型的变量，总是直接复制一份
    }

    function _innerChangeInt(uint _newValue) internal pure {
        _newValue = 100;
    }

    function _innerChangeMemory(Person memory _p) internal pure {
        _p.name = "David memory";
        _p.age = 30;
        _p.married = false;
    }

    function _innerChangeStorage(Person storage _p) internal {
        _p.name = "David Storage";
        _p.age = 30;
        _p.married = false;
    }

    // run before changeTestGlobalWithStorage
    function changeTestGlobalWithMemory() public {
        Person memory pTmp = personArrayGlobal[0];

        _innerChangeMemory(pTmp);

        // error，memory 不能赋值给storage
        // _innerChangeStorage(pTmp);

        console.log(pTmp.name); // David memory，memory中的变量改变了
        console.log(personArrayGlobal[0].name); // Lily，原storage中数据未改变
    }

    // run after changeTestGlobalWithMemory
    function changeTestGlobalWithStorage() public {
        Person storage pTmp = personArrayGlobal[0];

        // storage 赋值给memory，完全拷贝
        _innerChangeMemory(pTmp); 
        console.log(pTmp.name); // Lily
        console.log(personArrayGlobal[0].name); // Lily

        // storage 赋值给storage，指针传递
        _innerChangeStorage(pTmp);

        console.log(pTmp.name); // David
        console.log(personArrayGlobal[0].name); // David

    }
}
```

