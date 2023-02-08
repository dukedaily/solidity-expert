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



### 1. Minimize on-chain data

- Event：如果链上合约不需要调用的数据，可以使用event，由链下监听，提供只读操作；
- IPFS：大数据可以上传到ipfs，然后将对应的id存储在链上；
- 无状态合约：如果只是为了存储key-value，那么在合约中不需要状态变量存储，而是仅仅通过参数记录，让链下程序去解析交易，读取参数，从而读取到key-value数据；
- 默克尔根（Merkle Proofs）：快速验证数据，合约不用存储太多内容。

### 2. Minimize on-chain operations

- string：string内在也是bytes，尽量使用bytes替代，可以减少EVM计算，减少gas消耗；
- 返回storage值：直接返回storage如果有必要的话，具体内部数据，让链下程序解析；
- Local Storage：使用local storage变量，可节约开销，不要使用memory进行copy一遍操作；
- Batching（批量操作）：如果有批量操作需要，可以提供相应接口，避免用户发起相同交易。

### 3. Memory locations

四种存储位置gas消耗（由低到高）：calldata -> stack -> memory -> storage.

- Calldata：一般用在参数中，修饰引用数据类型（array、string），限定external function，尽量使用，便宜；
- Memory：对于存储引用类型的数据时，完全拷贝（你没有看错，反而更便宜）比storage便宜；
- Storage：最贵，非必要，不使用。
- Stack：函数体中值类型的数据，自动修饰为stack类型；

### 4. Variables ordering

- Storage slots（槽）大小是32字节，但并不是所有的类型都能填满（bool，int8等）；
- 调整顺序，可以优化storage使用空间：
  - uint128、uint128、uint256，一共使用两个槽位（good）✅
  - uint128、uint256、uint128，一共使用三个槽位（bad）❌

### 5. Preferred data types

- 如果定义变量的类型原本可以填满整个槽位，那么就填满ta，而不要使用更短的数据类型。
- 例如：如果定义数据类型：datatype：uint8，但是opcode原则上是处理：uint256的，那么会对空余部分填充：0，这反而会增加evm对gas的开销，所以更好的方法是：直接定义datatype为：uint256。

### 6. Libraries

库有两种表现形式：

- Embedded Libraries：当lib中的方法都是internal的时候，会自动内联到合约中，此时对节约gas不起作用；
- Deployed Libraries：当lib中有public或external方法时，此时会单独部署lib合约，我们可以使用一个lib地址关联到不同合约来达到节约gas的目的。

### 7. Minimal Proxies (ERC 1167)

- 这是一个标准，用于clone合约
- openzeppelin合约中clone就源于此

### 8. Constructor

- 构造函数中可以传递immutable数据，如果可能，尽量使用constant，这样开销更小。

### 9. Contract Size

- 合约最大支持24K
- 减少Logs/ Message：require后面的des，event的使用，都影响合约size
- 使用opcode：这个看情况而定，opcode可能减少部署开销，却引来调用开销的增加。
- 修饰器Modifier：modifer中wrapped一个函数，在函数中实现具体逻辑 // TODO

### 10. Solidity compiler optimizer

- 开启编译器optimize，这个是有双面性的，一定会使得合约size变小；

- 但是可能会使部分函数的逻辑变复杂（code bigger），增加函数的执行开销。




## Solidity Gas Optimizations Tricks

### 1. 使用最新版本solidity

EVM的升级会带来gas的优化

### 2. for循环优化

```js
// 避免重复计算长度
uint length = arr.length;
// ++i 可以减少一次赋值，初始化i放在for里面
for (uint i; i < length;) {
  	// unchecked可以减少溢出校验
    unchecked { ++i; }
}
```

### 3. 使用calldata代替memory

calldata是存储不可修改的函数参数的位置，仅支持external函数，使用calldata可以减少一次将参数复制到memory的操作。

从calldata中加载使用：calldataload，从memory中加载使用：mload

### 4. 尽量使用immutable代替state variable

[EIP-2929](https://eips.ethereum.org/EIPS/eip-2929) 对slot的操作引入了cold slot（消耗2100 gas）和warm slot（消耗100 gas）的概念，但是依然很贵，而修饰为immutable的变量会保存在bytecode中，使用时使用的是push，仅消耗3gas

### 5. 使用immutable代替constant（计算keccak时）

```js
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract Immutables is AccessControl {
    uint256 public gas;
	bytes32 public immutable MANAGER_ROLE_IMMUT;
  
  	// 每次使用都需要重新计算hash值
    bytes32 public constant MANAGER_ROLE_CONST = keccak256('MANAGER_ROLE');
  
    constructor(){
        // 仅在构造时计算hash一次
        MANAGER_ROLE_IMMUT = keccak256('MANAGER_ROLE');
        _setupRole(MANAGER_ROLE_CONST, msg.sender);
        _setupRole(MANAGER_ROLE_IMMUT, msg.sender);
    }
  
    function immutableCheck() external {
        gas = gasleft();
        require(hasRole(MANAGER_ROLE_IMMUT, msg.sender), 'Caller is not in manager role'); // 24408 gas
        gas -= gasleft();
    }
    
    function constantCheck() external {
        gas = gasleft();
        require(hasRole(MANAGER_ROLE_CONST, msg.sender), 'Caller is not in manager role'); // 24419 gas
        gas -= gasleft();
    }
}
```

### 6. 使用modifier代替function

经过对比，modifier合约的foo方法更加节约gas

```js
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract Inlined {
    function isNotExpired(bool _true) internal view {
        require(_true == true, "Exchange: EXPIRED");
    }

    function foo(bool _test) public returns(uint) {
        isNotExpired(_test);
        return 1;
    }
}

contract Modifier {
    modifier isNotExpired(bool _true) {
        require(_true == true, "Exchange: EXPIRED");
        _;
    }

    function foo(bool _test) public isNotExpired(_test)returns(uint) {
        return 1;
    }
}
```

### 7. modifier中使用internal函数减少合约size

尽量将modifier中的条件判断逻辑写在单独的internal view函数中，可以减少合约size，从而减少gas消耗。

以下代码中，onlyOwner在多处使用，使用越多节约效果越明显

```js
pragma solidity ^0.8.10;

contract Context {
    function _msgSender() internal view returns(address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address public owner = _msgSender();

    modifier onlyOwner() {
        require(owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}
contract Ownable2 is Context {
    address public owner = _msgSender();

    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    
    function _checkOwner() internal view virtual {
        require(owner == _msgSender(), "Ownable: caller is not the owner");
    }
}
// This is deployment gas cost for each function
// 0: 107172
// 1: 145772
// 2: 181610
// 3: 198170
// 4: 214532
// 5: 241059
contract T1 is Ownable {
    event Call(bytes4 selector);
    function f0() external onlyOwner() { emit Call(this.f0.selector); }
    function f1() external onlyOwner() { emit Call(this.f1.selector); }
    function f2() external onlyOwner() { emit Call(this.f2.selector); }
    function f3() external onlyOwner() { emit Call(this.f3.selector); }
    function f4() external onlyOwner() { emit Call(this.f4.selector); }
}
// 0: 107172
// 1: 147908
// 2: 165818
// 3: 183506
// 4: 192500
// 5: 211682
contract T2 is Ownable2 {
    event Call(bytes4 selector);
    function f0() external onlyOwner() { emit Call(this.f0.selector); }
    function f1() external onlyOwner() { emit Call(this.f1.selector); }
    function f2() external onlyOwner() { emit Call(this.f2.selector); }
    function f3() external onlyOwner() { emit Call(this.f3.selector); }
    function f4() external onlyOwner() { emit Call(this.f4.selector); }
}
```

验证结果：

![image-20230208111811060](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20230208111811060.png)

### 8. >= is cheaper than >

可以减少内部校验是否为0的逻辑

Non-strict inequalities (`>=`) are cheaper than strict ones (`>`). This is due to some supplementary checks (`ISZERO`, 3 gas)).

```js
uint256 public gas;

function checkStrict() external {
    gas = gasleft();
    require(999999999999999999 > 1); // gas 5017
    gas -= gasleft();
}
function checkNonStrict() external {
    gas = gasleft();
    require(999999999999999999 >= 1); // gas 5006
    gas -= gasleft(); 
}
```

### 9. 使用SHR和SHL来代替乘除法

DIV使用5gas，SHR使用3gas，而且后者不用额外校验除数为0的逻辑，更加节约gas

### 10. 使用多个require代替使用&&

```js
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
import "hardhat/console.sol";

contract Requires {
    uint256 public gas;

    function check1(uint x) public {
        gas = gasleft();  
        console.log(gasleft());
        require(x == 0 && x < 1 ); // gas cost 22156
        console.log(gasleft());
        gas -= gasleft();
    }

    function check2(uint x) public {
        gas = gasleft(); 
        console.log(gasleft());
        require(x == 0); // gas cost 22148
        require(x < 1);
        console.log(gasleft());
        gas -= gasleft();
    }
}
```

### 11.使用自定义error代替revert("err info")

https://blog.soliditylang.org/2021/04/21/custom-errors/

语义更加丰富，同时节约gas，高效

### 12. public/private/internal/external等

在调用层面，四个修饰符gas fee没有不同之处

但是在部署的时候，public币private和internal更贵一些

### 13. 对状态变量进行caching节约gas

一个状态变量如果在一个函数中会被使用多次，那么使用memory进行caching可以节约gas

SLOAD：100gas

MLOAD：3 gas



### 14. 对结构体格外注意

```js
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
import "hardhat/console.sol";

contract Requires {
    event Unlock(address _sender, uint256 _nftIndex, uint256 _amt);

    // struct LockPosition use 3 slots
    mapping(uint256 => LockPosition) positions;

    struct LockPosition {
        address owner;
        uint256 unlockAt;
        uint256 lockAmount;
    }

    function unlock(uint256 _nftIndex) external {
        // 3 SLOADs and 3 MSTORES
        // 从storage读取三个变量，并且复制到memory中
        LockPosition memory position = positions[_nftIndex]; // gas: costing 3 SLOADs while only lockAmount is needed twice. 

        //Replace "memory" with "storage" and cache only position.lockAmount
        require(position.owner == msg.sender, "unauthorized");
        require(position.unlockAt <= block.timestamp, "locked");

        delete positions[_nftIndex];
        payable(msg.sender).transfer(position.lockAmount);

        emit Unlock(msg.sender, _nftIndex, position.lockAmount);
     }

     function unlockOptimize(uint256 _nftIndex) external {
        LockPosition storage position = positions[_nftIndex]; 

        uint256 amt = position.lockAmount;

        //Replace "memory" with "storage" and cache only position.lockAmount
        require(position.owner == msg.sender, "unauthorized");
        require(position.unlockAt <= block.timestamp, "locked");

        delete positions[_nftIndex];
        payable(msg.sender).transfer(amt);

        emit Unlock(msg.sender, _nftIndex, amt);
     }
}
```



### 15. 复用非零值的状态变量更节约gas

Writing to an Existing Storage Slot Is Cheaper Than Using a New One

https://eips.ethereum.org/EIPS/eip-2200

```sh
EIP — 2200 changed a lot with gas, and now if you hold 1 Wei of a token it’s cheaper to use the token than if you hold 0. There is a lot to unpack here so just google EIP 2200 and learn if you want, but in general, if you need to use a storage slot, don’t empty it if you plan to refill it later.
```





## 参考链接

1. https://medium.com/coinmonks/smart-contracts-gas-optimization-techniques-2bd07add0e86
2. https://www.alchemy.com/overviews/solidity-gas-optimization
3. https://medium.com/better-programming/solidity-gas-optimizations-and-tricks-2bcee0f9f1f2



