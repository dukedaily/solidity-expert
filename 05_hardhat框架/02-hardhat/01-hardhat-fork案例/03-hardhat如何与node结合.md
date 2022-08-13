## 清算需求背景

AAVE触发清算时，抛出清算事件liquidateEvent，这个事件被DSA这边的一个服务监听后，服务调用合约，从而将liquidateEvent转化成DSA事件系统里面的事件。



## 需求提炼

使用hardhat fork的网络，调用合约之后，其发送的事件：

1. 如何被服务监听到？
2. 如何被subgraph监听到？



