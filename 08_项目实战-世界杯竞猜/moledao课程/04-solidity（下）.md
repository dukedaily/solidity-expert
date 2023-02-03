## abi.encode、decode、encodePacked

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



## call&staticcall

- **call**是一种底层调用合约的方式，可以在合约内调用其他合约，call语法为：

  ```js
  //(bool success, bytes memory data) = addr.call{value: valueAmt, gas: gasAmt}(abi.encodeWithSignature("foo(string,uint256)", 参数1, 参数2)
  其中：
  1. success：执行结果，一定要校验success是否成功，失败务必要回滚
  2. data：执行调用的返回值，是打包的字节序，需要解析才能得到调用函数的返回值（后续encode_decode详解）
  ```

- 当调用fallback方式给合约转ether的时候，**建议使用call**，而不是使用transfer或send方法

  ```js
  (bool success, bytes memory data) = addr.call{value: 10}("")
  ```

- 对于存在的方法，不建议使用call方式调用。

  ```js
  (bool success, bytes memory data) = _addr.call(abi.encodeWithSignature("doesNotExist()"));
  ```

  调用不存在的方法（又不存在fallback）时，交易会调用成功，但是第一个参数为：false，所以使用call调用后一定要检查success状态

### call

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

### Staticcall

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

  
