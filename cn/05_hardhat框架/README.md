# 第五章：hardhat框架
hardhat是目前以太坊dapp开发中最常使用的框架，已经替代truffle，主流协议目前绝大多数都使用hardhat，它可以快速的：完成合约部署、单测，fork等



常用插件汇总：

1. [hardhat-contract-sizer](https://github.com/ItsNickBarry/hardhat-contract-sizer)，检查合约size

2. [hardhat-storage-layout](https://github.com/aurora-is-near/hardhat-storage-layout)，检查状态变量的布局，优化gas

   - **contract**: is the name of the contract including its path as prefix
   - **state variable**: is the name of the state variable
   - **offset**: is the offset in bytes within the storage slot according to the encoding
   - **storage slot**: is the storage slot where the state variable resides or starts. This number may be very large and therefore its JSON value is represented as a string.
   - **type**: is an identifier used as key to the variable’s type information (described in the following)
   - **numberOfBytes**: is the nummber of bytes used by the state variable.

   ## 
