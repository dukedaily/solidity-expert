# 第12节：bytes和string

byteN、bytes、string直接的关系：

![image-20220506194856017](assets/image-20220506194856017.png)

**bytes:**

- bytes是动态数组，相当于byte数组（如：byte[10])
- 支持push方法添加
- 可以与string相互转换

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract  Bytes {
    bytes public name;
    
    //1. 获取字节长度
    function getLen() public view returns(uint256) {
        return name.length;
    }

    //2. 可以不分空间，直接进行字符串赋值，会自动分配空间
    function setValue(bytes memory input) public {
        name = input;
    }
    
    //3. 支持push操作，在bytes最后面追加元素
    function pushData() public {
        name.push("h");
    }
}
```

**string:**

- string 动态尺寸的UTF-8编码字符串，是特殊的可变字节数组
- string **不支持下标索引**、**不支持length、push方法**
- string **可以修改(需通过bytes转换)**

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract  String {
    string public name = "lily";   
    
    function setName() public {
        bytes(name)[0] = "L";   
    }
    
    function getLength() public view returns(uint256) {
        return bytes(name).length;
    }
}
```





