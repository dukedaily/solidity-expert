# 第14节：gnosisSafe分析

![image-20230310085517628](https://duke-typora.s3.amazonaws.com/ipic/2023-03-10-005518.png)



1. 我们在GnosisSafe的网站上创建多签钱包的时候，是由SafeProxyFactory帮我们创建了一个SafeProxy代理合约，这个代理合约就是你的多签钱包（此处记为0x111）

2. 当我们发起多签操作时（2/3多签），分两个阶段：

   1. 多签阶段：分别有多个Owner进行签名，此时仅为链下操作，当满足2/3时，便可以进行链上执行阶段
   2. 执行阶段：由其中一个Owner发起链上执行。

3. 执行阶段具体执行流程：

   1. Owner发起链上执行操作，携带所有的数据（在gnosis的dapp中添加），最终会生成如下数据，喂给这个函数：

      ```js
      function execTransaction(
          address to, // 目标地址，可以是合约，也可以是EOA
          uint256 value, // 金额
          bytes calldata data, // 具体calldata，与to配合使用
          Enum.Operation operation, // 0: call，1:delegatecall
          uint256 safeTxGas,
          uint256 baseGas,
          uint256 gasPrice,
          address gasToken,
          address payable refundReceiver,
          bytes memory signatures // 多个签名的集合，在内部会进行切割，循环校验
      ) public payable virtual returns (bool success)
      ```

   2. 操作交互流程为：多签钱包safeProxy通过代理方式调用Safe合约里面的  `execTransaction`方法执行

   3. execTransaction内部会：

      1. 循环校验签名
      2. 执行to.call(data)或者to.deletatecall(data)

   4. GnosisSafe GitHub: https://github.com/safe-global/safe-contracts

      

   **注意：to有可能不是最后环节，有可能是另外一个辅助合约，例如：MultiSend.sol，在这个合约内提供了multiSend方法，进行交易批量执行等**



