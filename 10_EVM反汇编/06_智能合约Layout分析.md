

# 第6节：智能合约Layout分析

[Reversing and debugging EVM Smart contracts: Full Smart Contract layout(part6) ](https://medium.com/@TrustChain/reversing-and-debugging-part-6-full-smart-contract-layout-f236c3121bd1)

- solidity version: 0.8.7
- optimizer: 200 runs

```js
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Test {
    address owner;

    uint data;

    function setOwner(address _addr) external {
        owner = _addr;
    }

    function returnAdd(uint x,uint y) internal view returns(uint) {
        return x+y;
    }

    function setBalance(uint x) external {
        uint var1 = 10;
        data = returnAdd(x,var1);
    }
}
```



## 1. Disassembling the function main

入口执行逻辑：由于没有main函数作为entry point，solidity从byte 0开始执行。

```js
function main() {
	mstore(0x40,0x80)
	if (msg.value > 0) { revert(); }
	if (msg.data.size < 4) { revert(); }
}
```

里面有三个函数（selector），需要分支进行判断，相当于对所有的函数进行遍历map：

```js
function main() {
	mstore(0x40,0x80)
	if (msg.value > 0) { revert(); }
	if (msg.data.size < 4) { revert(); }
	byte4 selector = msg.data[0:4]
  	switch (selector) {
		case 0x13af4035:
			// JUMP to 37
			
		case 0xfb1669ca:
			// JUMP to 66
		default: revert(0);
}
```

## 2. The function layout

每个函数的bytecode是连续的（side by side）

```js
func_082() 0x82 => 0x91
func_092() 0x92 => 0xB9
func_0BA(a,b) 0xBA => 0xD1
func_0D2() 0xD2 => 0xF6
```

到这里我们得到了每个函数的位置（layout），接下来了解一下函数内部的code。

## 3. Understanding the code functions

内部详情，先省略。

## 4. What is inside the main() 



## 5. Conclusion
