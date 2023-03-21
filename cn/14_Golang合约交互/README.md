# 第14章：后端服务

在DAPP项目中，绝大部分的工作都是由用户通过前端直接与合约交互的，对后台的依赖并不强。但是也存在很多场景需要由后台进行支撑，如：

- 清算机器人：后台服务定时轮询，当条件触发时，调用合约执行清算；
- 链下扫块：对链上合约、事件进行监听，触发条件时，执行预设逻辑；
- 预言机（Oracle）更新数据：Oracle是链下&链上交互的通道，对链上进行更新，如：价格、赛事结果、天气等等。



Nodejs、Java、Go都是主流的链下服务开发语言，从本章开始，我们将系统的介绍如何使用golang与合约交互，go开发以太坊资源：

- EN：https://goethereumbook.org/en/
- CN：https://goethereumbook.org/zh/

![image-20221211104737014](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20221211104737014.png)