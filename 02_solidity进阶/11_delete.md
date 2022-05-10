# 第11节：delete

1. delete操作符可以用于任何变量(map除外)，将其设置成默认值；
2. 如果对动态数组使用delete，则删除所有元素，其长度变为0: uint[ ] array0 ;   arry0 = new uint[](10)；
3. 如果对静态数组使用delete，则重置所有索引的值，数组长度不变: uint[10] array1 = [1,2,3,4,5,6]；
4. 如果对map类型使用delete，什么都不会发生；
5. 但如果对map类型中的一个键使用delete，则会删除与该键相关的值。

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract  Delete {
    //01. string 
    string public str1 = "hello";
    
    function deleteStr() public {
        delete str1;
    }
    
    function setStr(string memory input) public {
        str1 = input;
    }
    
    //02. array 对于固定长度的数组，会删除每个元素的值，但是数组长度不变
    uint256[10] public arry1 = [1,2,3,4,5];
    
    function deleteFiexedArry() public {
        delete arry1;
    }
    
    //03. array new
    uint256[] arry2 ;
    function setArray2() public {
        arry2 = new uint256[](10);
        for (uint256 i = 0; i< arry2.length; i++) {
            arry2[i] = i;
        }
    }
    
    function getArray2() public view returns(uint256[] memory) {
        return arry2;
    }
    
    function deleteArray2() public {
        delete arry2;
    }
    
    //04. mapping
    mapping(uint256 => string) public m1;
    
    function setMap() public {
        m1[0] = "hello";
        m1[1] = "world";
    }
    
    //Mapping不允许直接使用delete，但是可以对mapping的元素进行指定删除
    // function deleteM1() public {
    //     delete m1;
    // }	
    
    function deleteMapping(uint256 i) public {
        delete m1[i];
    }
}
```

