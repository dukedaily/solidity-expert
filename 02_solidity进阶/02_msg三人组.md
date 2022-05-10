# 第2节：msg.sender、msg.value、msg.data

当用户发起一笔交易时，相当于向合约发送一个消息(msg)，这笔交易可能会涉及到三个重要的全局变量，具体如下：

1. **msg.sender**：表示这笔交易的调用者是谁（地址），同一个交易，不同的用户调用，msg.sender不同；
2. **msg.value**：表示调用这笔交易时，携带的ether数量，这些以太坊由msg.sender支付，转入到当前合约（wei单位整数）；
   1. 注意：一个函数（或地址）如果想接收ether，需要将其修饰为：**payable**。
3. **msg.data**：表示调用这笔交易的信息，由函数签名和函数参数（16进制字符串），组成代理模式时常用msg.data（后续讲解）。
   1. msg.data可以由


## msg.sender

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MsgSender {

    address public owner;
    uint256 public value;
    address public caller;
    
    constructor() {
        //在部署合约的时候，设置一个全局唯一的合约所有者，后面可以使用权限控制
        owner = msg.sender;
    }
    
    //1. 对与合约而言，msg.sender是一个可以改变的值，并不一定是合约的创造者
    //2. 任何人调用了合约的方法，那么这笔交易中的from就是当前合约中的msg.sender
    function setValue(uint256 input) public {
        value = input;
        caller = msg.sender;
    }
}
```

## msg.value

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MsgValue {

    // uint256 public money;
    
    mapping(address=> uint256) public personToMoney;
    
    // 函数里面使用了msg.value，那么函数要修饰为payable
    function play() public payable {
        
        // 如果转账不是100wei，那么参与失败
        // 否则成功，并且添加到维护的mapping中
        require(msg.value == 100, "should equal to 100!");
        personToMoney[msg.sender] = msg.value;
    }
    
    // 查询当前合约的余额
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
}
```

## msg.data

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MsgData {
    event Data(bytes data, bytes4 sig);
		
    // input0: addr: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // input1: amt : 1
    function transfer(address addr, uint256 amt) public {
        bytes memory data = msg.data;
      
        // msg.sig 表示当前方法函数签名（4字节）
        // msg.sig 等价于 this.transfer.selector
        emit Data(data, msg.sig);
    }
  
    //output: 
    // - data: 0xa9059cbb0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc40000000000000000000000000000000000000000000000000000000000000001
    // - sig: 0xa9059cbb
  
    // 对data进行分析：
    // 0xa9059cbb //前四字节
    // 0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4 //第一个参数占位符
    // 0000000000000000000000000000000000000000000000000000000000000001 //第二个参数占位符
}
```



