# Solidity语法（下）

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

## 讲师介绍

资深web3开发者，bybit交易所defi团队Tech Lead，MoleDAO技术顾问，国内第一批区块链布道者，专注海外defi,dex,AA钱包等业务方向。

- 公众号：[阿杜在新加坡](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU5NDQ0NDAxNQ==&action=getalbum&album_id=2529739108240556033&scene=173&from_msgid=2247484601&from_itemidx=1&count=3&nolastread=1#wechat_redirect) 
- github：[以太坊教程](https://github.com/dukedaily)
- B站：[杜旭duke](https://www.bilibili.com/video/BV1EY4y1c7Yq/?vd_source=42fe91bf6d16ec8841b22ea520184d76)
- Youtube：[duke du](https://www.youtube.com/watch?v=Wpf5KkgzElc&list=PLO_KaIZjoik9oY-Rs9BsDkHY2RJy7WcE-)
- Twitter：[dukedu2022](https://twitter.com/home)



## interface

可以使用Interface完成多个合约之间进行交互，interface有如下特性：

1. 接口中定义的function不能存在具体实现；
2. 接口可以继承；
3. 所有的function必须定义为external；public，internal，private
4. 接口中不能存在constructor函数；
5. 接口中不能定义状态变量；
6. [abstract和interface的区别](https://medium.com/upstate-interactive/solidity-how-to-know-when-to-use-abstract-contracts-vs-interfaces-874cab860c56)

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Counter {
    uint public count;

    function increment() external {
        count += 1;
    }
}

interface IBase {
    function count() external view returns (uint);
}

interface ICounter is IBase {
  	// uint num;
    function increment() external;
}

contract MyContract {
    function incrementCounter(address _counter) external {
        ICounter(_counter).increment();
    }

    function getCount(address _counter) external view returns (uint) {
        return ICounter(_counter).count();
    }
}
```

uniswap demo:

```js
// Uniswap example
interface UniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface UniswapV2Pair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

contract UniswapExample {
    address private factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function getTokenReserves() external view returns (uint, uint) {
        address pair = UniswapV2Factory(factory).getPair(dai, weth);
        (uint reserve0, uint reserve1, ) = UniswapV2Pair(pair).getReserves();
        return (reserve0, reserve1);
    }
}
```

## library

库与合约类似，**限制：不能在库中定义状态变量，不能向库地址中转入ether**，库有两种存在形式：

1. 内嵌（embedded）：当库中所有的方法都是internal时，此时会将库代码内嵌在调用合约中，不会单独部署库合约；
2. ==链接（linked）==：当库中含有external或public方法时，此时会单独将库合约部署，并在调用合约部署时链接link到库合约。
   1. 可以复用的代码可以编写到库中，不同的调用者可以linked到相同的库，因此会更加节约gas；
   2. 对于linked库合约，调用合约使用delegatecall进行调用，所以上下文为调用合约；
   3. 部署工具（如remix）会帮我们自动部署&链接合约库。

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// 1. 只有internal方法，会内嵌到调用合约中
library SafeMath {
  
    function add(uint x, uint y) internal pure returns (uint) {
        uint z = x + y;
        require(z >= x, "uint overflow");

        return z;
    }
}

library Math {
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        // else z = 0 (default value)
    }
}

contract TestSafeMath {
  	// 对uint类型增加SafeMath的方法，
  	// 1. 后续定义的uint变量就会自动绑定SafeMath提供的方法: uint x;
  	// 2. 这个变量会作为第一个参数传递给函数: x.add(y);
    using SafeMath for uint;

    uint public MAX_UINT = 2**256 - 1;
		
  	// 用法1：x.方法(y)
    function testAdd(uint x, uint y) public pure returns (uint) {
       //return x.add(y);
      return SafeMath.add(x,y);
    }

  	// 用法2：库.方法(x)
    function testSquareRoot(uint x) public pure returns (uint) {
        return Math.sqrt(x);
    }
}

// 2. 存在public方法时，会单独部署库合约，并且第一个参数是状态变量类型
library Array {
  	// 修改调用者状态变量的方式，第一个参数是状态变量本身
    function remove(uint[] storage arr, uint index) public {
        // Move the last element into the place to delete
        require(arr.length > 0, "Can't remove from empty array");
        arr[index] = arr[arr.length - 1];
        arr.pop();
    }
}

contract TestArray {
    using Array for uint[];

    uint[] public arr;

    function testArrayRemove() public {
        for (uint i = 0; i < 3; i++) {
            arr.push(i);
        }

        arr.remove(1);

        assert(arr.length == 2);
        assert(arr[0] == 0);
        assert(arr[1] == 2);
    }
}
```



## encode

1. abi.**encode**：可以将data编码成bytes，生成的bytes总是32字节的倍数，不足32为会自动填充（用于给合约调用）；
2. abi.**decode**：可以将bytes解码成data（可以只解析部分字段）
3. abi.**encodePacked**：与abi.encode类似，但是生成的bytes是压缩过的（有些类型不会自动填充，无法传递给合约调用）。
4. 手册：https://docs.soliditylang.org/en/v0.8.13/abi-spec.html?highlight=abi.encodePacked#non-standard-packed-mode

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract AbiDecode {
    struct MyStruct {
        string name;
        uint[2] nums;
    }

    // input: 10, 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, [1,"2",3], ["duke", [10,20]]
    // output: 0x000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc40000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000000064756b6500000000000000000000000000000000000000000000000000000000
    //  output长度：832位16进制字符（去除0x)，832 / 32 = 26 （一定是32字节的整数倍，不足填0）
    function encode(
        uint x,
        address addr,
        uint[] calldata arr,
        MyStruct calldata myStruct
    ) external pure returns (bytes memory) {
        return abi.encode(x, addr, arr, myStruct);
    }

    function decode(bytes calldata data)
        external
        pure
        returns (
            uint x,
            address addr,
            uint[] memory arr,
            MyStruct memory myStruct
        )
    {
        (x, addr, arr, myStruct) = abi.decode(data, (uint, address, uint[], MyStruct));

        /* decode output: 
            0: uint256: x 10
            1: address: addr 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
            2: uint256[]: arr 1,2,3
            3: tuple(string,uint256[2]): myStruct ,10,20
        */
    }

    // 可以只decode其中部分字段，而不用全部decode，当前案例中，只有第一个字段被解析了，其余为默认值
    function decodeLess(bytes calldata data)
        external
        pure
        returns (
            uint x,
            address addr,
            uint[] memory arr,
            MyStruct memory myStruct
        )
    {
        (x) = abi.decode(data, (uint));

        /* decode output: 
            0: uint256: x 10
            1: address: addr 0x0000000000000000000000000000000000000000
            2: uint256[]: arr
            3: tuple(string,uint256[2]): myStruct ,0,0
        */
    }

    // input: -1, 0x42, 0x03, "Hello, world!"
    function encodePacked(
        int16 x,
        bytes1 y,
        uint16 z,
        string memory s
    ) external view returns (bytes memory) {

        // encodePacked 不支持struct和mapping
        return abi.encodePacked(x, y, z, s);

        /*
        0xffff42000348656c6c6f2c20776f726c6421
          ^^^^                                 int16(-1)
              ^^                               bytes1(0x42)
                ^^^^                           uint16(0x03)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^ string("Hello, world!") without a length field
        */
    }
  
  	// 可以用encodePacked来拼接字符串
  	// output string: ipfs://bafybeidmrsvehl4ehipm5qqvgegi33r6/100.json
  	function encodePackedTest() public  pure returns (string memory) {
        string memory uri = "ipfs://bafybeidmrsvehl4ehipm5qqvgegi33r6/";
        return string(abi.encodePacked(uri, "100", ".json"));
    }
}
```

## keccak256

keccak256用于计算哈希，属于sha3算法，与sha256（属于sha2算法不同），keccak256使用场景如下：

1. 用于生成唯一id；
2. 生成数据指纹；

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract HashFunction {
    function hash(
        string memory _text,
        uint _num,
        address _addr
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_text, _num, _addr));
    }

    // Example of hash collision
    // Hash collision can occur when you pass more than one dynamic data type
    // to abi.encodePacked. In such case, you should use abi.encode instead.
    function collision(string memory _text, string memory _anotherText)
        public
        pure
        returns (bytes32)
    {
        // encodePacked(AAA, BBB) -> AAABBB
        // encodePacked(AA, ABBB) -> AAABBB
        return keccak256(abi.encodePacked(_text, _anotherText));
    }
}

contract GuessTheMagicWord {
    bytes32 public answer =
        0x60298f78cc0b47170ba79c10aa3851d7648bd96f2f8e46a19dbc777c36fb0c00;

    // Magic word is "Solidity"
    function guess(string memory _word) public view returns (bool) {
        return keccak256(abi.encodePacked(_word)) == answer;
    }
}
```



## Send Ether

**如何发送ether？**

有三种方式可以向合约地址转ether：

1. ~~send（21000 gas，return bool）~~
2. transfer（21000 gas， throw error）
3. call（传递交易剩余的gas或设置gas，不限定21000gas，return bool）(推荐使用)

总结：transfer() 和 send() 函数使用 2300 gas 以防止重入攻击，但公链升级后可能导致 gas 不足。所以推荐使用 call() 函数，但需做好重入攻击防护。



**如何接收ether？**

想接收ether的合约至少包含以下方法中的一个：

1. receive() external payable：msg.data为空时调用（为接收ether而生，仅solidity 0.6版本之后)
2. fallback() external payable：msg.data非空时调用（为执行default逻辑而生，**顺便支持接收ether**）

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ReceiveEther {
    /*
    Which function is called, fallback() or receive()?

                sender ether
                    |
             msg.data is empty?
                /       \
            yes          no
             /             \
      receive() exist?     fallback()
          /    \
        yes     no
       /          \
  receive()     fallback()
  */

    string public message;

    // Function to receive Ether. msg.data must be empty
    receive() external payable {
        message = "receive called!";
    }

    // Fallback function is called when msg.data is not empty
    fallback() external payable {
        message = "fallback called!";
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function setMsg(string memory _msg) public {
        message = _msg;
    }
}

contract SendEther {
    function sendViaTransfer(address payable _to) public payable {
        // This function is no longer recommended for sending Ether. (不建议使用)
        _to.transfer(msg.value);
    }

    function sendViaSend(address payable _to) public payable {
        // Send returns a boolean value indicating success or failure.
        // This function is not recommended for sending Ether. (不建议使用)
        bool sent = _to.send(msg.value);
        require(sent, "Failed to send Ether");
    }

    function sendViaCallFallback(address payable _to) public payable {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use. (推荐使用)
        (bool sent, bytes memory data) = _to.call{value: msg.value}(abi.encodeWithSignature("noExistFuncTest()"));
        require(sent, "Failed to send Ether");
    }

    function sendViaCallReceive(address payable _to) public payable {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.(推荐使用)
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
}
```

解析：

- 调用sendViaTransfer或sendViaSend的时候，假设构造这笔交易时，你传入的gas时：1000000 gas

  此时，在使用transfer和send转账的时候，只会传递2300个gas，如果接收者是个合约，这个合约必须有fallback，此时这个fallback里面不能有逻辑，否则会超过2300gas，导致转账失败。

- sendViaCall的时候，假设构造这笔交易时，你传入的gas时：1000000 gas
  此时在调用call的时候，也可以完成转账，但是会把1000000传递给fallback，即在fallback中你可以实现自己复杂的逻辑。

- 参考链接：https://docs.soliditylang.org/en/latest/security-considerations.html#sending-and-receiving-ether



## call

- **call**是一种底层调用合约的方式，可以在合约内调用其他合约

- 当调用fallback方式给合约转ether的时候，**建议使用call**，而不是使用transfer或send方法

- 对于存在的方法，不建议使用call方式调用

- 调用不存在的方法（又不存在fallback）时，交易会调用成功，但是第一个参数为：false，所以使用call调用后一定要检查success状态

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Receiver {
    event Received(address caller, uint amount, string message);

    fallback() external payable {
        emit Received(msg.sender, msg.value, "Fallback was called");
    }

    function foo(string memory _message, uint _x) public payable returns (uint) {
        emit Received(msg.sender, msg.value, _message);

        return _x + 1;
    }
}

contract Caller {
    event Response(bool success, bytes data);

    function testCallFoo(address payable _addr) public payable {
        // You can send ether and specify a custom gas amount
        (bool success, bytes memory data) = _addr.call{value: msg.value, gas: 5000}(
            abi.encodeWithSignature("foo(string,uint256)", "call foo", 123)
        );

        emit Response(success, data);
    }

    // Calling a function that does not exist triggers the fallback function.
    function testCallDoesNotExist(address _addr) public {
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("doesNotExist()")
        );

        emit Response(success, data);
    }
}
```

## staticcall

- https://eips.ethereum.org/EIPS/eip-214
- Since byzantium staticcall can be used as well. This is basically the same as call, but will revert if the called function modifies the state in any way.
- 与CALL相同，但是不允许修改任何状态变量，是为了安全🔐考虑而新增的OPCODE
- 在Transparent模式的代理合约逻辑中，就使用了staticcall，从而让proxyAmin能够免费的调用父合约的admin函数，从而从slot中返回代理合约的管理员。这部分会在合约升级章节介绍。

```js
    function getProxyAdmin(TransparentUpgradeableProxy proxy) public view virtual returns (address) {
        // We need to manually run the static call since the getter cannot be flagged as view
        // bytes4(keccak256("admin()")) == 0xf851a440
        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f851a440");
        require(success);
        return abi.decode(returndata, (address));
    }
```



## delegatecall

delegatecall与call相似，也是底层调用合约方式，特点是：

1. 当A合约使用delegatecall调用B合约的方法时，B合约的代码被执行，但是**使用的是A合约的上下文**，包括A合约的状态变量，msg.sender，msg.value等；
2. 使用delegatecall的前提是：A合约和B合约有相同的状态变量。

![image-20220510094354223](https://duke-typora.s3.amazonaws.com/ipic/2023-03-06-085436.png)

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Implementation {
    // NOTE: storage layout must be the same as contract A
    uint public num;
    address public sender;
    uint public value;

    function setVars(uint _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
}

contract ImplementationV2 {
    // NOTE: storage layout must be the same as contract A
    uint public num;
    address public sender;
    uint public value;

    function setVars(uint _num) public payable {
        num = _num*2;
        sender = msg.sender;
        value = msg.value;
    }
}

// 注意：执行后，Proxy中的sender值为EOA的地址，而不是A合约的地址  (调用链EOA-> Proxy::setVars -> Implementation::setVars)
contract Proxy {
    uint public num;
    address public sender;
    uint public value;

    function setVars(address _impl, uint _num) public payable {
        // Proxy's storage is set, Implementation is not modified.
        (bool success, bytes memory data) = _impl.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }
}
```



## create&create2

创建合约时，在世界状态中，增加一个地址与账户的信息。

![image-20220906214046327](https://duke-typora.s3.amazonaws.com/ipic/2023-03-06-085757.png)

在EVM层面，一共有两个操作码（OPCODE）可以用来创建合约：

1. create：

- 原理：新生成地址 = hash(创建者地址, nonce)
- 特点：不可预测，因为nonce是变化的

2. create2：

- 原理：新生成地址 = hash("0xFF",创建者地址, salt, bytecodeHash)
- 特点：可以预测，因为没有变量

在编码时，我们可以直接使用汇编来创建新合约，也可以使用solidity中的new关键字来创建新合约：

1. 使用汇编方式：

```js
assembly {
  create(参数...)
}

assembly {
  create2(参数...)
}
```

2. 使用new方式创建：

```js
// 内部调用create
new ContractName(参数...)

// 内部调用create2
// 在0.8.0版本之后，new增加了salt选项，从而支持了create2的特性（通过salt可以计算出创建合约的地址）。
new ContractName{salt: _salt}(参数...)
```

demo验证：

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Car {
    address public owner;
    string public model;
    address public carAddr;

    constructor(address _owner, string memory _model) payable {
        owner = _owner;
        model = _model;
        carAddr = address(this);
    }
}

contract CarFactory {
    Car[] public cars;

    function create(address _owner, string memory _model) public {
        Car car = new Car(_owner, _model);
        cars.push(car);
    }

    function createAndSendEther(address _owner, string memory _model) public payable {
        Car car = (new Car){value: msg.value}(_owner, _model);
        cars.push(car);
    }

    function create2(
        address _owner,
        string memory _model,
        bytes32 _salt
    ) public {
        Car car = (new Car){salt: _salt}(_owner, _model);
        cars.push(car);
    }

    function create2AndSendEther(
        address _owner,
        string memory _model,
        bytes32 _salt
    ) public payable {
        Car car = (new Car){value: msg.value, salt: _salt}(_owner, _model);
        cars.push(car);
    }

    function getCar(uint _index)
        public
        view
        returns (
            address owner,
            string memory model,
            address carAddr,
            uint balance
        )
    {
        Car car = cars[_index];

        return (car.owner(), car.model(), car.carAddr(), address(car).balance);
    }
}
```



## 合约间调用

普通的交易，相当于在世界状态中修改原有的账户数据，更新到新状态。

![image-20220906214200031](https://duke-typora.s3.amazonaws.com/ipic/2023-03-06-090931.png)

一共有三种方式调用合约：

1. 使用合约实例调用合约（常规）：**A.foo(argument)**
2. 使用call调用合约: **A.call(calldata)**
3. 使用delegate调用合约：**A.delegatecall(calldata)**

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Callee {
    uint public x;
    uint public value;

    function setX(uint _x) public returns (uint) {
        x = _x;
        return x;
    }

    function setXandSendEther(uint _x) public payable returns (uint, uint) {
        x = _x;
        value = msg.value;

        return (x, value);
    }
}

contract Caller {
    // 直接在参数中进行实例化合约
    function setX(Callee _callee, uint _x) public {
        uint x = _callee.setX(_x);
    }

    // 传递地址，在内部实例化callee合约
    function setXFromAddress(address _addr, uint _x) public {
        Callee callee = Callee(_addr);
        callee.setX(_x);
    }

    // 调用方法，并转ether
    function setXandSendEther(Callee _callee, uint _x) public payable {
        (uint x, uint value) = _callee.setXandSendEther{value: msg.value}(_x);
    }
}

```



## uniswapV2

![image-20230307193843382](https://duke-typora.s3.amazonaws.com/ipic/2023-03-07-113843.png)
