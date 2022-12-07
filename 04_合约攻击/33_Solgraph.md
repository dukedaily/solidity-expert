# 第33节：Solgraph



## 概述

Solgraph可以图形化的展示合约的结构，使用不同颜色标注合约的函数，从而尽可能的暴漏问题，为合约审计提供便利。

![image-20221207095507346](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221207095507346.png)

**Legend:**

- Red: Send to external address
- Blue: Constant function
- Yellow: View
- Green: Pure
- Orange: Call
- Purple: Transfer
- Lilac: Payable



## 合约

编写合约MyContract.sol

```js
contract MyContract {
  uint balance;

  function MyContract() {
    Mint(1000000);
  }

  function Mint(uint amount) internal {
    balance = amount;
  }

  function Withdraw() {
    msg.sender.send(balance);
  }

  function GetBalance() constant returns(uint) {
    return balance;
  }
}
```

## 安装

```sh
npm install -g solgraph
```

## 执行

```sh
solgraph MyContract.sol > MyContract.dot
```

此时生成文件MyContract.dot，内容如下：

```js
strict digraph {
  MyContract
  Mint [color=gray]
  Withdraw [color=red]
  UNTRUSTED
  GetBalance [color=blue]
  MyContract -> Mint
  Withdraw -> UNTRUSTED
}
```

## 渲染图片

```sh
# 安装渲染工具
brew install graphviz

# 执行渲染
dot -Tpng MyContract.dot -o MyContract.png

# Mac用户可以使用内置工具Preview.app查看方式
pbpaste | solgraph | dot -Tpng | open -f -a /Applications/Preview.app
```

## 执行效果

![image-20221207095800219](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221207095800219.png)

## 图形化

send已经呗废弃了，不安全，这里暴露了出来，应该使用transfer或者call来处理（记得校验返回值）

![image-20221207095858531](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221207095858531.png)



## 链接

github：https://github.com/raineorshine/solgraph