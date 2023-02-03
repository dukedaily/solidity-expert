# 第16节：节约gas

1. 使用calldata替换memory
2. 将状态变量加载到memory中
3. 使用++i替换i++
4. 对变量进行缓存
5. 短路效应

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// gas golf
contract GasGolf {
    // start - 50908 gas
    // use calldata - 49163 gas
    // load state variables to memory - 48952 gas
    // short circuit - 48634 gas
    // loop increments - 48244 gas
    // cache array length - 48209 gas
    // load array elements to memory - 48047 gas

    uint public total;

    // start - not gas optimized
    // function sumIfEvenAndLessThan99(uint[] memory nums) external {
    //     for (uint i = 0; i < nums.length; i += 1) {
    //         bool isEven = nums[i] % 2 == 0;
    //         bool isLessThan99 = nums[i] < 99;
    //         if (isEven && isLessThan99) {
    //             total += nums[i];
    //         }
    //     }
    // }

    // gas optimized
    // [1, 2, 3, 4, 5, 100]
    function sumIfEvenAndLessThan99(uint[] calldata nums) external {
        uint _total = total;
        uint len = nums.length;

        for (uint i = 0; i < len; ++i) {
            uint num = nums[i];
            if (num % 2 == 0 && num < 99) {
                _total += num;
            }
        }

        total = _total;
    }
}
```



## 十种节约方法

一共两种类型的Gas需要消耗，他们是：

1. 调用合约
2. 部署合约

有时候，减少了一种类型的gas会导致另一种类型gas的增加，我们需要进行权衡（Tradeoff）利弊，主要优化方向：

1. **Minimize on-chain data** (events, IPFS, stateless contracts, merkle proofs) -> 优化链上存储
2. **Minimize on-chain operations** (strings, return storage value, looping, local storage, batching) -> 优化链上操作
3. **Memory Locations** (calldata, stack, memory, storage) -> 数据位置的选择
4. **Variables ordering** -> 变量的定义顺序很重要
5. **Preferred data types** -> 数据类型的选择
6. **Libraries** (embedded, deploy) -> 尽量使用库来减少部署gas
7. **Minimal Proxy** -> 使用clone方式创建新合约
8. **Constructor** -> 优化构造函数（尽量使用constant）
9. **Contract size** (messages, modifiers, functions) -> 优化合约size
10. **Solidity compiler optimizer** -> 开启优化中 



## 1. Minimize on-chain data

- Event：如果链上合约不需要调用的数据，可以使用event，由链下监听，提供只读操作；
- IPFS：大数据可以上传到ipfs，然后将对应的id存储在链上；
- 无状态合约：如果只是为了存储key-value，那么在合约中不需要状态变量存储，而是仅仅通过参数记录，让链下程序去解析交易，读取参数，从而读取到key-value数据；
- 默克尔根（Merkle Proofs）：快速验证数据，合约不用存储太多内容。

## 2. Minimize on-chain operations

- string：string内在也是bytes，尽量使用bytes替代，可以减少EVM计算，减少gas消耗；
- 返回storage值：直接返回storage如果有必要的话，具体内部数据，让链下程序解析；
- Local Storage：使用local storage变量，可节约开销，不要使用memory进行copy一遍操作；
- Batching（批量操作）：如果有批量操作需要，可以提供相应接口，避免用户发起相同交易。

## 3. Memory locations

四种存储位置gas消耗（由低到高）：calldata -> stack -> memory -> storage.

- Calldata：一般用在参数中，修饰引用数据类型（array、string），限定external function，尽量使用，便宜；
- Stack：函数体中值类型的数据，自动修饰为stack类型；
- Memory：对于存储引用类型的数据时，完全拷贝（你没有看错，反而更便宜）比storage便宜；
- Storage：最贵，非必要，不使用。

## 4. Variables ordering

- Storage slots（槽）大小是32字节，但并不是所有的类型都能填满（bool，int8等）；
- 调整顺序，可以优化storage使用空间：
  - uint128、uint128、uint256，一共使用两个槽位（good）✅
  - uint128、uint256、uint128，一共使用三个槽位（bad）❌

## 5. Preferred data types

- 如果定义变量的类型原本可以填满整个槽位，那么就填满ta，而不要使用更短的数据类型。
- 例如：如果定义数据类型：datatype：uint8，但是opcode原则上是处理：uint256的，那么会对空余部分填充：0，这反而会增加evm对gas的开销，所以更好的方法是：直接定义datatype为：uint256。

## 6. Libraries

库有两种表现形式：

- Embedded Libraries：当lib中的方法都是internal的时候，会自动内联到合约中，此时对节约gas不起作用；
- Deployed Libraries：当lib中有public或external方法时，此时会单独部署lib合约，我们可以使用一个lib地址关联到不同合约来达到节约gas的目的。

## 7. Minimal Proxies (ERC 1167)

- 这是一个标准，用于clone合约
- openzeppelin合约中clone就源于此

## 8. Constructor

- 构造函数中可以传递immutable数据，如果可能，尽量使用constant，这样开销更小。

## 9. Contract Size

- 合约最大支持24K
- 减少Logs/ Message：require后面的des，event的使用，都影响合约size
- 使用opcode：这个看情况而定，opcode可能减少部署开销，却引来调用开销的增加。
- 修饰器Modifier：modifer中wrapped一个函数，在函数中实现具体逻辑 // TODO

## 10. Solidity compiler optimizer

- 开启编译器optimize，这个是有双面性的，一定会使得合约size变小；

- 但是可能会使部分函数的逻辑变复杂（code bigger），增加函数的执行开销。

  

## 参考链接

1. https://medium.com/coinmonks/smart-contracts-gas-optimization-techniques-2bd07add0e86
2. https://www.alchemy.com/overviews/solidity-gas-optimization













EOA: 

CA: EOA NONCE + SALT + Bytecode



create: nonce + bytecode

create2



