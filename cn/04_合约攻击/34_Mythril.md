# 第34节：Mythril



## 概述

Mythril是以太坊兼容链的安全分析工具，可以检查出bytecode层面的安全漏洞。`Mythril`是免费的，命令行工具；`MythX`三方平台，集成了Mythril，可以在Remix中使用；



## Install（local）

```sh
pip3 install mythril

# 如果报错，请依次执行
python3.10 -m pip install --upgrade pip

# 大概率是这个包缺失
pip install maturin
```



## Install（docker）

```sh
docker pull mythril/myth
```

### help

```sh
docker run mythril/myth --help

# 以下是输出内容
positional arguments:
  {safe-functions,analyze,a,disassemble,d,list-detectors,read-storage,function-to-hash,hash-to-address,version,help}
                        Commands
    safe-functions      Check functions which are completely safe using
                        symbolic execution
    analyze (a)         Triggers the analysis of the smart contract
    disassemble (d)     Disassembles the smart contract
    list-detectors      Lists available detection modules
    read-storage        Retrieves storage slots from a given address through
                        rpc
    function-to-hash    Returns the hash signature of the function
    hash-to-address     converts the hashes in the blockchain to ethereum
                        address
    version             Outputs the version

optional arguments:
  -h, --help            show this help message and exit
  -v LOG_LEVEL          log level (0-5)
```

### disassemble

```sh
docker run mythril/myth disassemble -c "0x6060"
```

![image-20221207111351251](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221207111351251.png)

### analyze

```sh
# 指定文件
myth analyze <solidity-file>
docker run -v $(pwd):/tmp mythril/myth analyze /tmp/<solidity-file>

# 指定地址
myth analyze -a <contract-address>
docker run mythril/myth analyze -a <contract-address>
```



## 演示案例

创建文件test.sol，内容如下：

```js
contract Exceptions {

    uint256[8] myarray;
    uint counter = 0;
    function assert1() public pure {
        uint256 i = 1;
      
      	// 会报错，因为assert一般不用来校验参数，而是校验状态变量。
        assert(i == 0); 
    }
    function counter_increase() public {
        counter+=1;
    }
    function assert5(uint input_x) public view{
        require(counter>2);

      	// 会报错，因为assert一般不用来校验参数，而是校验状态变量。
        assert(input_x > 10);
    }
    function assert2() public pure {
        uint256 i = 1;
        assert(i > 0);
    }

    function assert3(uint256 input) public pure {
        assert(input != 23);
    }

    function require_is_fine(uint256 input) public pure {
        require(input != 23);
    }

    function this_is_fine(uint256 input) public pure {
        if (input > 0) {
            uint256 i = 1/input;
        }
    }

    function this_is_find_2(uint256 index) public view {
        if (index < 8) {
            uint256 i = myarray[index];
        }
    }
}
```

执行命令：

```sh
docker run -v $(pwd):/tmp mythril/myth analyze /tmp/test.sol
```

Output如下，[点击查看完整输出](https://gist.github.com/dukedaily/ad605df57251bc0e908581112a2d2924)

<script src="https://gist.github.com/dukedaily/ad605df57251bc0e908581112a2d2924.js"></script>



## MythX三方工具

- 官网注册
- Remix插件



## 链接

- https://github.com/ConsenSys/mythril

