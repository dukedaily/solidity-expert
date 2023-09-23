# 第七章：subgraph

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

subgraph是DAPP领域最重要的基建之一，主流协议都在使用，其功能为：
- 链下监听事件，逻辑处理，存储到数据库中，供前端调用；
- 常用于：统计历史信息等，仅做展示相关，可以节约链上存储成本，且响应更快；
- 请求subgraph的时候使用[graphql](https://thegraph.com/docs/en/querying/graphql-api/)语言，而非sql语句。

本节代码位于：https://github.com/dukedaily/subgraph-demo

