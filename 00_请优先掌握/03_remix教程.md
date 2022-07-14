



```js
pragma abicoder v2;
```

<<<<<<< HEAD


=======
>>>>>>> 05c3c75cb86e4e2e3bf82095b446c97918f6be59
# 使用remix传递参数事项

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

   传递参数：

   ```js
   tokens:	 [[0, '0x749B1c911170A5aFEb68d4B278cD5405C718fc7F',1000,0,0]],
   general: ["0x749B1c911170A5aFEb68d4B278cD5405C718fc7F", 8000, false, 1000, 1100, 8000, 10000, 10000]
   ```

   