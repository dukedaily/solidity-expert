# 第16节：结构体Struct

自定义结构类型，将不同的数据类型组合到一个结构中，目前支持参数传递结构体。

枚举和结构体都可以定义在另外一个文件中，进行import后使用

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Todos {
    struct Todo {
        string text;
        bool completed;
    }

    // An array of 'Todo' structs
    Todo[] public todos;

    function create(string memory _text) public {
        // 3 ways to initialize a struct
        // - calling it like a function
        todos.push(Todo(_text, false));

        // key value mapping
        todos.push(Todo({text: _text, completed: false}));

        // initialize an empty struct and then update it
        Todo memory todo;
        todo.text = _text;
        // todo.completed initialized to false

        todos.push(todo);
    }

    // Solidity automatically created a getter for 'todos' so
    // you don't actually need this function.
    function get(uint _index) public view returns (string memory text, bool completed) {
        Todo storage todo = todos[_index];
        return (todo.text, todo.completed);
    }

    // update text
    function update(uint _index, string memory _text) public {
        Todo storage todo = todos[_index];
        todo.text = _text;
    }

    // update completed
    function toggleCompleted(uint _index) public {
        Todo storage todo = todos[_index];
        todo.completed = !todo.completed;
    }
}
```

在外面定义结构体：StructDeclaration.sol（说明并不是所有数据都必须写在合约之内的）

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

struct Todo {
    string text;
    bool completed;
}
```

在主合约中引用：

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./StructDeclaration.sol";

contract Todos {
    // An array of 'Todo' structs
    Todo[] public todos;
}
```

**避坑指南**

1. 传递结构体时，需要使用方括号包裹，并且里面有地址的时候，需要使用双引号包裹，不可以时单引号，或者不包裹

2. 传递结构体数组时，需要在外层再次包裹方括号即可。

3. 示例：

   函数原型：

   ```js
   function createOffer(Token[] memory _tokens, GeneralInfo memory _general)
   ```

   结构定义：

   ```js
   enum TokenType {
       ERC20,
       ERC721,
       ERC1155
   }
   
   struct Token {
       TokenType tokenType;
       address tokenAddr;
       uint256 tokenAmounts;
       uint256 tokenId;
       uint256 tokenPrice;
   }
   
   struct GeneralInfo {
       address loanToken; //token to borrow
       uint256 ltv; //8000 means 80%
       bool featuredFlag; //true, false
       uint256 loanAmount; //amounts to borrow
       uint256 interestRate; //1100 means 11%
       uint256 collateralThreshold; //8000 means 80%
       uint256 repaymentDate; //timestamp + 30days
       uint256 offerAvailable; //timestamp + 7days
   }
   
   ```

   正确传递参数方式如下：

   ```js
   tokens:	 [[0, '0x749B1c911170A5aFEb68d4B278cD5405C718fc7F',1000,0,0]],
   general: ["0x749B1c911170A5aFEb68d4B278cD5405C718fc7F", 8000, false, 1000, 1100, 8000, 10000, 10000]
   ```
