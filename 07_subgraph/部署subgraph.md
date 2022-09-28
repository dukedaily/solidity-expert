## 如何搭建

1. clone graph-node

```
git clone git@github.com:graphprotocol/graph-node.git
```

2. accessing Docker directory of the graph node

```
cd graph-node/docker
```

3. Replacing host IP(Linux only)

```
./setup.sh
```

4. starting the local graph node

```
docker-compose up
```



5. accessing Bisaar-subgraph

```
cd Bisaar-subgraph
```

6. create subgraph

```
npm run create-local
```

1. deploy

```
npm run deploy-local
```







## 常用

1. require的字段在创建的时候，都需要显示初始化，例如BigInt的要初始化为BigInt.zero()

