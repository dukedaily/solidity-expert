# 第5节：function执行流程（if else function）

[Reversing and debugging EVM Smart contracts: The Execution flow if/else/for/functions(part5)](https://medium.com/@TrustChain/reversing-and-debugging-evm-the-execution-flow-part-5-2ffc97ef0b77)



## 版本

- Version：0.8.7
- Optimizer：true，Runs：1

## 1. IF/ELSE

```js
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Test {
    uint value = 0;
    function flow(bool x) external {
        if (x) {
            value = 4;
        } else {
            value = 9;
        }
    }
}
```

汇编：（medium原文描述应关闭优化，与汇编数据不符，实际上应该选择 runs：1）

```js
062 JUMPDEST |0x01|stack after arguments discarded|
063 DUP1     |0x01|0x01|
064 ISZERO   |0x00|0x01|
065 PUSH1 4b |0x4b|0x00|0x01|
067 JUMPI    |0x01|
068 PUSH1 04 |0x04|0x01|
070 PUSH1 00 |0x00|0x04|0x01|
072 SSTORE   |0x01|
073 POP      
074 JUMP 
075 JUMPDEST 
076 PUSH1 09 
078 PUSH1 00 
080 SSTORE 
081 POP 
082 JUMP
```

- 只要有JUMPI，那么就一定有if或for。



## 2. ELSE IF

```js

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Test {
    uint value = 0;
    function flow(uint x) external {
        if (x == 1) {
        	value = 4;
        } else if (x == 2) {
        	value = 9;
        } else if (x == 3) {
            value = 14;
        } else if (x == 4) {
            value = 19;
        } else {
            value = 24;
        }
    }
}
```

汇编：

```js
062 JUMPDEST 
063 DUP1 
064 PUSH1 01 
066 EQ 
067 ISZERO 
068 PUSH1 4e 
070 JUMPI 
071 PUSH1 04 
073 PUSH1 00 
075 SSTORE 
076 POP 
077 JUMP 
078 JUMPDEST 
079 DUP1 
080 PUSH1 02 
082 EQ 
083 ISZERO 
084 PUSH1 5e 
086 JUMPI 
087 PUSH1 09 
089 PUSH1 00 
091 SSTORE 
092 POP 
093 JUMP 
094 JUMPDEST 
095 DUP1 
096 PUSH1 03 
098 EQ 
099 ISZERO 
100 PUSH1 6e 
102 JUMPI 
103 PUSH1 0e 
105 PUSH1 00 
107 SSTORE 
108 POP 
109 JUMP 
110 JUMPDEST 
111 DUP1 
112 PUSH1 04 
114 EQ 
115 ISZERO 
116 PUSH1 7e 
118 JUMPI 
119 PUSH1 13 
121 PUSH1 00 
123 SSTORE 
124 POP 
125 JUMP 
126 JUMPDEST 
127 PUSH1 18 
129 PUSH1 00 
131 SSTORE 
132 POP 
133 JUMP
```

汇编很长，但是逻辑并不复杂，只是在不断的判断和跳转，有点像我们之前需要函数的selector，按照汇编的逻辑反推，我们可以得到下面的逻辑代码，不断的进行嵌套、判断：

```js
if (x == 1) {
	// do something
} else {
	if (x == 2) {
		// do something
	} else {
		if (x == 3) {
			// do something
		} else {
			if (x == 4) {
				// do something
			} else {
				// do something
			}	
		}
	}
}
```



## 3. For Loops

```js
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Test {
    uint value = 0;
    function flow(uint x) external {
        for (uint i = 0; i < x; i++) {
            value += i;
        }
    }
}
```

我们执行完一个函数，然后点击debug，此时一般都会停在一个JUMPDEST的OPCODE上，因为里就是函数执行的入口，此时stack V中已经压入了函数参数，例如这里：

```sh
# 汇编如下：
062 JUMPDEST
063 PUSH1 00  # for里面的变量，i = 0
065 JUMPDEST
066 DUP2
067 DUP2
068 LT # for里面的小于号， <
069 ISZERO
070 PUSH1 6c
072 JUMPI # 当条件不满足时，跳出循环♻️


# 当前stack数据：
[
	"0x000000000000000000000000000000000000000000000000000000000000000a", <=== 这里就是参数x=10（0a是十六进制）
	"0x000000000000000000000000000000000000000000000000000000000000003c",
	"0x0000000000000000000000000000000000000000000000000000000047f4d98d"
]
```

- 函数参数都是存储在stack中的

```sh
073 DUP1 
074 PUSH1 00 
076 DUP1 
077 DUP3 
078 DUP3 
079 SLOAD  # 将0存储到状态变量中
080 PUSH1 57 
082 SWAP2 
083 SWAP1 
084 PUSH1 88 
086 JUMP
```

- 接下来会校验加法是否溢出，在solidity 0.8之后，会自动校验，生成相应的汇编代码

```sh
136 JUMPDEST 
137 PUSH1 00 
139 DUP3 
140 NOT 
141 DUP3 
142 GT 
143 ISZERO 
144 PUSH1 98 
146 JUMPI 
147 PUSH1 98 
149 PUSH1 b5 
151 JUMP
```

- \- if yes, then the code JUMP to B5 and reverts. (You can check disassembly at 181.)
  \- if not, the execution continues at 98 (152 in dec)

```sh
152 JUMPDEST 
153 POP 
154 ADD 
155 SWAP1 
156 JUMP
```

- 经过溢出校验之后，上面的代码会将slot0的数据+i。

```sh
087 JUMPDEST 
088 SWAP1 
089 SWAP2 
090 SSTORE 
091 POP 
092 DUP2 
093 SWAP1 
094 POP 
095 PUSH1 65 
097 DUP2 
098 PUSH1 9d 
100 JUMP
```

- 这段代码会将slot0存储起来（SSTORE），然后跳转到9d（byte 157），然后重新校验是否溢出。

```sh
157 JUMPDEST 
158 PUSH1 00 
160 PUSH1 00 
162 NOT 
163 DUP3 
164 EQ 
165 ISZERO 
166 PUSH1 ae 
168 JUMPI 
169 PUSH1 ae 
171 PUSH1 b5 
173 JUMP
```

- 如果一切正常，继续跳转到ae（174）

```sh
174 JUMPDEST 
175 POP 
176 PUSH1 01 
178 ADD 
179 SWAP1 
180 JUMP
```

- 继续加1，然后跳转到65（101）

```sh
101 JUMPDEST
102 SWAP2
103 POP
104 POP
105 PUSH1 41
107 JUMP
```

- 这里的目的是clean整个Stack上的数据，然后跳转到41（65），跳转到00

- 整体反推后，逻辑为：

1. I declare `i = 0` .
2. I test if `i < x` if yes jump directly to the end (8).
3. Load the Slot 0 ( `value` variable).
4. verify that when, i’ll add i to Slot to `value` , there won’t be an overflow. If the test fails go to 181 when the function reverts.
5. add i to `value` and SSTORE to slot 0.
6. verify that when the EVM will add 1 to i (for incrementation) there won’t be an overflow if test fails go to 181 when the function reverts.
7. add 1 to i and return to 2.
8. end the execution.

The loop lies between 2 and 8 while i < x (in this example we called flow() with x = 10)



## 4. function无参数（重要！！）

Compile it **WITHOUT** the optimizer (but still with solidity version 0.8.7)

```js
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Test {
   	uint value = 0;
   	function flow() external {
			flow2();
    }
		
		function flow2() public {
			value = 5;
		}
}
```

flow内调用flow2的汇编如下：

```js
071 JUMPDEST 
072 PUSH1 4d		// byte 77
074 PUSH1 4f 		// byte 79
076 JUMP  
077 JUMPDEST 
078 JUMP
079 JUMPDEST 
080 PUSH1 05 
082 PUSH1 00 
084 DUP2 
085 SWAP1 
086 SSTORE 
087 POP 
088 JUMP
```

分析上述代码，得出结论：**函数执行前后，stack中的数据一致**。

- 执行flow2之前，stack（0）= 4d（byte 77）
- 执行flow2之后，stack（0）= 4d （byte 77）

![image-20221122105351096](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221122105351096.png)

**THIS IS THE CASE FOR ALL FUNCTIONS !!! ALL FUNCTIONS IN SOLIDITY ONCE EXECUTED WILL USE THE STACK AND CLEAN IT AFTER EXECUTION. AS A RESULT THE STACK WILL EXACTLY THE SAME BEFORE AND AFTER EXECUTION !**



所以当flow2执行后，在byte 88的jump语句，会跳转到4d（byte 77）位置。为什么会跳转到这里呢？因为flow2是嵌套在flow中的，当flow2执行完毕后，函数需要回到flow中，因此才会有语句PUSH1 4d，这是为了存储flow的状态。



**这也侧面印证了函数的调用特点，执行完字函数（此处是flow2）之后，所有字函数内的变量都会清除掉。**



## 5. Function有参数

Compile it **WITHOUT** the optimizer (but still with solidity version 0.8.7)

```js
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Test {
    uint value = 0;
  
   	function flow() external {
			flow2(5);
    }
		
		function flow2(uint y) public {
			value = y;
		}
}
```

![image-20221122114402578](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221122114402578.png)

byte 97是flow入口（居然有特殊颜色提示）

![image-20221122114934471](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221122114934471.png)

94和95的两个pop，会将stack上的数据清除掉，恢复到执行byte 97 （flow）之前的stack状态！

![image-20221122115519096](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221122115519096.png)



## 6. Function有返回值

```js
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Test {
	uint value = 0;
   	function flow() external {
	    uint n = flow2();
		value = n;
   	}
		
	function flow2() public returns(uint) {
		return 5;
	}
}
```



## 7. Let’s bring it together

```js
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Test {
    uint value = 0;
    function flow() external {
        uint n = flow2(5,7);
        value = n;
    }
		
    function flow2(uint x,uint y) public returns(uint) {
        return x;
    }
}
```

汇编：

```sh
117 JUMPDEST 
118 PUSH1 00 
120 PUSH2 0083 
123 PUSH1 05 
125 PUSH1 07 
127 PUSH2 008f 
130 JUMP 
131 JUMPDEST 
132 SWAP1 
133 POP 
134 DUP1 
135 PUSH1 00 
137 DUP2 
138 SWAP1 
139 SSTORE 
140 POP 
141 POP 
142 JUMP 
143 JUMPDEST 
144 PUSH1 00 
146 DUP3 
147 SWAP1 
148 POP 
149 SWAP3 
150 SWAP2 
151 POP 
152 POP 
153 JUMP
```



## 8. Conclusion

When you call a function in solidity (in assembly).

1. The EVM PUSH all arguments to the stack before the call
2. The function is executed
3. ALL return values are PUSHED in the stack

本文有助于理解函数调用过程中的stack处理规则，了解即可。
