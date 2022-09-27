



```sh
# 安装命令
yarn global add @graphprotocol/graph-cli

# 将token存储在本地，执行一次即可
graph auth --product hosted-service <AccessToken>

graph auth https://api.thegraph.com/deploy/ <AccessToken>
```



## 常用

1. require的字段在创建的时候，都需要显示初始化，例如BigInt的要初始化为BigInt.zero()

