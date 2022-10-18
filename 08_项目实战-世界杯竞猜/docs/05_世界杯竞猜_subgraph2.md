# 第5节：世界杯竞猜（subgraph2）



## 背景

| 玩家     | EOA地址                                    | 国家 | 备注     |
| -------- | ------------------------------------------ | ---- | -------- |
| 管理员   | 0xE8191108261f3234f1C2acA52a0D5C11795Aef9E |      | 负责开奖 |
| Account1 | 0xE8191108261f3234f1C2acA52a0D5C11795Aef9E | 0，1 |          |
| Account2 | 0xC4109e427A149239e6C1E35Bb2eCD0015B6500B8 | 0    |          |
| Account3 | 0x572ed8c1Aa486e6a016A7178E41e9Fc1E59CAe63 | 0    |          |

- 最终胜出国家：0，此时合约中一共有：4gwei，三个人平分：每个人获得 4/3 gwei，如果有剩余，则转给管理员。
- 合约地址：0xFdD506bAe16aD28516C407876Ca53618befB3502



## 接下来做什么

- 发行一个worldCupToken
- 按照玩家的参与度进行分配，由subgraph进行链下统计
- 玩家自己进行领取



## 技术选型

1. 使用链下签名方式，让用户链上claim：
   1. 需要为每个用户都生成一个链下的签名，由管理员签发；
   1. 好处是：分配时不需要调用合约；多期奖励可以一次领取；
   1. 代价是：需要入库，对后台要求更高
2. 使用merkel tree方式，对这一期所有的玩家进行统一设置，然后各自去claim：
   1. 好处是：不需要入库，直接设置一次merkelTree即可（由所有用户来当叶子节点）
   2. 代价是：需要调用一次合约；多期奖励无法一次领取。



## 配置文件

```yaml
specVersion: 0.0.4
schema:
  file: ./schema.graphql
dataSources:
  - kind: ethereum
    name: WorldCup
    network: goerli
    source:
      address: "0xFdD506bAe16aD28516C407876Ca53618befB3502"
      abi: WorldCup
      startBlock: 7784143
    mapping:
      kind: ethereum/events
      apiVersion: 0.0.6
      language: wasm/assemblyscript
      entities:
        - ClaimReward
        - Finialize
        - Play
      abis:
        - name: WorldCup
          file: ./abis/WorldCup.json
      eventHandlers:
        - event: ClaimReward(address,uint256)
          handler: handleClaimReward
        - event: Finialize(uint8,address[],uint256,uint256)
          handler: handleFinialize
        - event: Play(uint8,address,uint8)
          handler: handlePlay
      file: ./src/world-cup.ts
```

## shchema

```yaml

```

## 部署合约

WorldCupToken：

```sh
npx hardhat verify --contract contracts/tokens/WorldCupToken.sol:WorldCupToken  0x4c305227E762634CB7d3d9291e42b423eD45f1AD "World Cup Token" "WCT" 10000000000000000000000000 --network goerli

# 0x4c305227E762634CB7d3d9291e42b423eD45f1AD
```

WorldCupDistributor：

```sh
hh run scripts/deployDistributor.ts --network goerli

# 0xF19233dFE30219F4D6200c02826B80e4347EF8BF

hh verify 0xF19233dFE30219F4D6200c02826B80e4347EF8BF 0x4c305227E762634CB7d3d9291e42b423eD45f1AD  --network goerli
```







## 梅克尔根

使用三方库，指定所有数据，可以生成root

给定单个节点，可以生成叶子：leaf

指定root和leaf数据，可以得到proof数组（有方法）

claim的时候😷：proof数组、root、节点数据
