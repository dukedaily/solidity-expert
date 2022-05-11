# 第14节：library

link：

1. Stack Overflow提问出和我相同的疑问：https://ethereum.stackexchange.com/questions/106574/why-can-i-use-linked-libraries-on-remix-ide-without-deploying-them-first
2. 讲解library：https://www.youtube.com/watch?v=25MLAnIzXRw
3. 讲解library（画了一个图）：https://www.youtube.com/watch?v=iIMSMfArTiE
4. remix部署合约和库：https://medium.com/remix-ide/deploying-with-libraries-on-remix-ide-24f5f7423b60
5. 另外一个solidity ide：https://ethfiddle.com/jtQ8Ja33ko



Linked Librarie、Embedded Libraries



当涉及到状态变量修改的时候，需要传递第一个参数，X stroage _self



### 使用remix，link到预先部署的lib

#### 第一次部署：

```txt
linking {
	"contracts/SampleTest.sol": {
		"aLib": [
			{
				"length": 20,
				"start": 110
			}
		]
	}
} using {
	"contracts/SampleTest.sol": {
		"aLib": "0x5FD6eB55D12E759a21C09eF703fe0CBa1DC9d88D"
	}
}

--------
from	0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
to	sampleContract.(constructor)
gas	265549 gas
transaction cost	230912 gas 
execution cost	230912 gas 
input	0x608...d0033
decoded input	{}
decoded output	 - 
logs	[]
val	0 wei
--------
from	0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
to	sampleContract.(constructor)
gas	265549 gas
transaction cost	230912 gas  //<<<======
execution cost	230912 gas 
input	0x608...d0033
decoded input	{}
decoded output	 - 
logs	[]
val	0 wei
```

### 不使用link库，重新部署

此时会自动部署两个合约，第一个是库合约，第二个是调用合约；

![image-20220511110133946](assets/image-20220511110133946.png)

### 改成内嵌的

合约部署一次，但是gas费变高了

```txt
from	0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
to	sampleContract.(constructor)
gas	280702 gas
transaction cost	244088 gas   <========
execution cost	244088 gas 
input	0x608...d0033
decoded input	{}
decoded output	 - 
logs	[]
```







