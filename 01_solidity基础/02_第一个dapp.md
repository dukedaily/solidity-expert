#  第2节：第一个dapp


```js
//指定编译器版本，版本标识符
pragma solidity ^0.8.13;

//关键字 contract 跟java的class一样  智能合约是Inbox      
contract Inbox{
	//string 是数据类型，message是成员变量，在整个智能合约生命周期都可以访问
	//public 是访问修饰符，是storage类型的变量，成员变量和是全局变量
	string public message;
    
    //函数以function开头，构造函数
	constructor(string memory initMessage) public {
        //本地变量
        string memory tmp = initMessage;
        message = tmp;
	}
  
    function setMessage(string memory _newMessage) public {
        message = _newMessage;
    }
    
    //view是修饰符，表示该函数仅读取成员变量，不做修改
    function getMessage() public view returns(string memory) {
        return message;
    }
}
```