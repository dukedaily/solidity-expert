# 第11节：for and while

solidity支持for, while, do while循环；

尽量不要使用没有边界的循环，因为会导致达到gas limit，进而导致交易执行失败，因此很少使用while和do while

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Loop {
    function loop() public {
        // for loop
        for (uint i = 0; i < 10; i++) {
            if (i == 3) {
                // Skip to next iteration with continue
                continue;
            }
            if (i == 5) {
                // Exit loop with break
                break;
            }
        }

        // while loop
        uint j;
        while (j < 10) {
            j++;
        }
    }
}

```

