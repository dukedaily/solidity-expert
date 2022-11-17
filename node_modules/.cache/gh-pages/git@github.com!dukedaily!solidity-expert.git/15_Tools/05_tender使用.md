1. 绑定一个合约之后，所有和这个合约交互的交易都会展示在Transaction tab下面

2. 模拟执行交易的时候，不必导入abi，直接输入地址，网络，然后在metamask中复制calldata过来执行即可（我之前都是自己填写abi，然后选择函数、填写参数，最后再执行。

3. 可以将网上已经发生的错误的交易在tenderly中执行，从而进行debug，而不用重新模拟执行。直接将交易的哈希在搜索框中查询即可，牛逼啊！

   ![image-20220523223141274](assets/image-20220523223141274.png)

4. tenderly：https://dashboard.tenderly.co/，模拟线上交易

5. 使用方式![u7zKBjCAdv](assets/u7zKBjCAdv.png)

6. 使用tenderly可以当做又一个浏览器进行查看，而且对input的解析比etherscan更加强大：
   1. input对比：
      1. etherscan无法解析input：https://kovan.etherscan.io/tx/0x3b58560275fece3de720fe0b1afc83e1efc469ed24a5a5d9c01521a79fff24ff
      2. tenderly可以解析input：https://dashboard.tenderly.co/tx/kovan/0x3b58560275fece3de720fe0b1afc83e1efc469ed24a5a5d9c01521a79fff24ff
   2. token名字对比：两者可以配合着使用，因为对自定义token的展示，浏览器更加清晰，tenderly却展示unknow
   3. console.log对比：浏览器无法展示，tenderly可以展示，但是值貌似不对，需要谨慎对待。
7. 



​	