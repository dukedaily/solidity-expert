
在线工程：https://web3playground.io/

可以上传到ipfs：https://web3playground.io/QmcuoNwuoXLBbY8nkjUCymee9DQG9wQtqUxjtuquhbuNw9

![image-20220508111859883](assets/image-20220508111859883.png)



```js
async function main() {
  let transferEvent = "Transfer(address,address,uint256)"
  let sig = web3.eth.abi.encodeEventSignature(transferEvent)
  let sig2 = web3.eth.abi.encodeFunctionSignature(transferEvent)
  
  //should be: 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
  console.log('event sig1:', sig)
  console.log('event sig2:', sig2)

  let transferFun = "transfer(address,uint256)"
  let sig3 = web3.eth.abi.encodeFunctionSignature(transferFun)
  console.log('Function sig:', sig3)
}
```

结果：

```sh
"event sig1:":  "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"
"event sig2:":  "0xddf252ad"
"Function sig:" "0xa9059cbb"
```





