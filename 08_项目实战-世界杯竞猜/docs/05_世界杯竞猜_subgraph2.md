# 第5节：世界杯竞猜（subgraph2）



## 背景

| 玩家     | EOA地址                                    | 国家 | 备注     |
| -------- | ------------------------------------------ | ---- | -------- |
| 管理员   | 0xE8191108261f3234f1C2acA52a0D5C11795Aef9E |      | 负责开奖 |
| Account1 | 0xE8191108261f3234f1C2acA52a0D5C11795Aef9E | 0，1 |          |
| Account2 | 0xC4109e427A149239e6C1E35Bb2eCD0015B6500B8 | 0    |          |
| Account3 | 0x572ed8c1Aa486e6a016A7178E41e9Fc1E59CAe63 | 0    |          |

- 最终胜出国家：0，此时合约中一共有：4gwei，三个人平分：每个人获得 4/3 gwei，如果有剩余，则转给管理员。
- 合约地址：==0x471a8f71d3bBB8254e36832FBbb6928b73298347==



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



## 部署合约

==WorldCupToken==：

```sh
npx hardhat verify --contract contracts/tokens/WorldCupToken.sol:WorldCupToken  0x4c305227E762634CB7d3d9291e42b423eD45f1AD "World Cup Token" "WCT" 10000000000000000000000000 --network goerli

# 0x4c305227E762634CB7d3d9291e42b423eD45f1AD
```

==WorldCupDistributor==：

```sh
hh run scripts/deployDistributor.ts --network goerli

# 0xF19233dFE30219F4D6200c02826B80e4347EF8BF

hh verify 0xF19233dFE30219F4D6200c02826B80e4347EF8BF 0x4c305227E762634CB7d3d9291e42b423eD45f1AD  --network goerli
```

向WorldCupDistributor中转入1w个奖励WorldCupToken。



## 编写配置文件

subgraph.yaml

```yaml
specVersion: 0.0.4
schema:
  file: ./schema.graphql
dataSources:
  - kind: ethereum
    name: WorldCup
    network: goerli
    source:
      address: "0x471a8f71d3bBB8254e36832FBbb6928b73298347"
      abi: WorldCup
      startBlock: 7789647
    mapping:
      kind: ethereum/events
      apiVersion: 0.0.6
      language: wasm/assemblyscript
      entities:
        - PlayRecord
        - FinializeHistory
      abis:
        - name: WorldCup
          file: ./abis/WorldCup.json
      eventHandlers:
        - event: Play(uint8,address,uint8)
          handler: handlePlay
        - event: Finialize(uint8,uint256)
          handler: handleFinialize
        - event: ClaimReward(address,uint256)
          handler: handleClaimReward
      file: ./src/world-cup.ts
  - kind: ethereum
    name: WorldCupDistributor
    network: goerli
    source:
      address: "0xF19233dFE30219F4D6200c02826B80e4347EF8BF"
      abi: WorldCupDistributor
      startBlock: 7789791
    mapping:
      kind: ethereum/events
      apiVersion: 0.0.6
      language: wasm/assemblyscript
      entities:
        - MerkleDistributor
        - Distribution
        - NeedToHandle
      abis:
        - name: WorldCupDistributor
          file: ./abis/WorldCupDistributor.jso
      eventHandlers:
        - event: DistributeReward(indexed bytes32,indexed uint256,uint256,uint256)
          handler: handleDistributeReward
        - event: Claimed(indexed address,indexed address,indexed uint256)
          handler: handleClaimed
      file: ./src/world-cup.ts

```

## 编写 Schema

schema.graphql

```yaml
type PlayRecord @entity {
  id: ID!
  index: BigInt! # uint256
  player: Bytes! # address
  selectCountry: BigInt! # uint256
  time: BigInt!
  block: BigInt!
}

type NeedToHandle @entity {
  id: ID!
  list: [PlayRecord!]!
}

type FinializeHistory @entity {
  id: ID!
  result: BigInt!
}

type PlayerDistribution @entity {
  id: ID!
  player: Bytes!
  rewardAmt: BigInt!
  weight: BigInt!
  isClaimed: Boolean!
}

type RewardHistory @entity {
  id: ID!
  index: BigInt!
  rewardAmt: BigInt!
  settleBlockNumber: BigInt!
  totalWeight: BigInt!
  list: [PlayerDistribution!]!
}

type MerkleDistributor @entity {
  id: ID!
  index: BigInt!
  totalAmt: BigInt!
  settleBlockNumber: BigInt!
}

type SimpleBlock @entity {
  id: ID!
  height: BigInt!
  time: BigInt!
}
```



## 编写映射文件（业务逻辑）

```js
import { Address, BigInt, Bytes, TypedMap, ethereum, log } from "@graphprotocol/graph-ts";

import {
  WorldCup,
  ClaimReward,
  Finialize,
  Play,
} from "../generated/WorldCup/WorldCup"

import {
  DistributeReward,
  Claimed
} from "../generated/WorldCupDistributor/WorldCupDistributor";

import { PlayRecord, NeedToHandle, PlayerDistribution, MerkleDistributor, SimpleBlock, FinializeHistory, RewardHistory } from "../generated/schema"

let NO_HANDLE_ID = "noHandleId"

export function handlePlay(event: Play): void {
  // 统计所有的play事件，存储起来
  // 1. get id 
  let id = event.params._player.toHex() + "#" + event.params._currRound.toString() + "#" + event.block.timestamp.toHex();

  // 2. create entity
  let entity = new PlayRecord(id);

  // 3. set data
  entity.index = BigInt.fromI32(event.params._currRound);
  entity.player = event.params._player;
  entity.selectCountry = BigInt.fromI32(event.params._country);
  entity.time = event.block.timestamp;
  entity.block = event.block.number;

  // 4. save
  entity.save()

  // 5. save nohandle play record
  let noHandle = NeedToHandle.load(NO_HANDLE_ID);
  if (!noHandle) {
    noHandle = new NeedToHandle(NO_HANDLE_ID);
    noHandle.list = [];
  }

  noHandle.list.push(id)
  noHandle.save()
}

export function handleFinialize(event: Finialize): void {
  let id = event.params._currRound.toString();
  let entity = new FinializeHistory(id);

  entity.result = event.params._country;
  entity.save();
}


export function handleDistributeReward(event: DistributeReward): void {
  // parse parameters first
  let id = event.params.index.toString();
  let rewardAmt = event.params.amount;
  let index = event.params.index;
  let settleBlockNumber = event.params.settleBlockNumber;

  // 找到当前发奖周期，查看哪个国家是winner
  let winCountry = FinializeHistory.load(id)
  if (!winCountry) {
    return;
  }

  // save for double check
  let merkelEntity = new MerkleDistributor(id);

  merkelEntity.index = index;
  merkelEntity.totalAmt = rewardAmt;
  merkelEntity.settleBlockNumber = settleBlockNumber;
  merkelEntity.save();

  let startBlock = BigInt.fromI32(0);
  let endBlock = settleBlockNumber;

  if (index > BigInt.fromI32(1)) {
    let prevId = index.minus(BigInt.fromI32(1)).toString()

    let prev = MerkleDistributor.load(prevId);
    if (!prev) {
      prev = new MerkleDistributor(prevId)
    }

    startBlock = prev.settleBlockNumber;
  }

  let totalWeight = BigInt.fromI32(0)
  let rewardActuallyAmt = BigInt.fromI32(0) // might be a little less than the given reward amt caused by the precise lossing of division
  let rewardHistoryList: string[] = []; // for history check usage

  let noHandle = NeedToHandle.load(NO_HANDLE_ID);
  if (noHandle) {
    let group = new TypedMap<Bytes, BigInt>();
    let currentList = noHandle.list; // current record
    let newList: string[] = []; // record won't be used this time

    for (let i = 0; i < currentList.length; i++) {
      let playerWeight = BigInt.fromI32(1)
      let record = PlayRecord.load(currentList[i]) as PlayRecord;
      if (record.block > startBlock && record.block <= endBlock) {
        if (winCountry.result == record.selectCountry) {
          // good guess, will get double rewards
          playerWeight = playerWeight.times(BigInt.fromI32(2))
        }

        let prevWeight = group.get(record.player)
        if (!prevWeight) {
          prevWeight = BigInt.fromI32(0)
        }

        // update weight of player
        group.set(record.player, prevWeight.plus(playerWeight));

        // update total weight
        totalWeight = totalWeight.plus(totalWeight);
      } else {
        // 遍历所有的record，累加到player之上, block区间之外的，会添加到newList中
        newList.push(currentList[i]);
      }
    }

    // 便利所有的group，为每个人分配奖励数量，然后存储在UserDistribution中(供最终调用)
    for (let j = 0; j < group.entries.length; j++) {
      let player = group.entries[j].key;
      let weight = group.entries[j].value;

      let id = player.toString() + "#" + index.toString()
      let reward = rewardAmt.times(weight).div(totalWeight);

      let playerDistribution = new PlayerDistribution(id);
      playerDistribution.player = player;
      playerDistribution.rewardAmt = reward;
      playerDistribution.weight = weight;
      playerDistribution.isClaimed = false;
      playerDistribution.save();

      rewardHistoryList.push(id);
      rewardActuallyAmt = rewardActuallyAmt.plus(reward);
    }

    noHandle.list = newList;
    noHandle.save();
  }

  // 存储本期奖励详情，供后续查看历史
  let rewardHistory = new RewardHistory(id);
  rewardHistory.index = index;
  rewardHistory.rewardAmt = rewardAmt;
  rewardHistory.settleBlockNumber = settleBlockNumber;
  rewardHistory.totalWeight = totalWeight;
  rewardHistory.list = rewardHistoryList;
}

export function handleClaimed(event: Claimed): void {
}

export function handleBlock(block: ethereum.Block): void {
  let id = block.number.toString();
  let entity = new SimpleBlock(id);
  entity.height = block.number;
  entity.time = block.timestamp;
  entity.save();
}

```



## 梅克尔根

1. 使用三方库，指定所有数据，可以生成root
2. 给定单个节点，可以生成叶子：leaf
3. 指定root和leaf数据，可以得到proof数组（有方法）
4. claim的时候😷：proof数组、root、节点数据

安装包：

package.json中添加，执行：npm i

```sh
    "dependencies": {
        "apollo-boost": "^0.4.9",
        "cross-fetch": "^3.1.5",
        "bignumber.js": "^9.1.0",
        "merkletreejs": "^0.2.32",
    }
```

创建scripts/distributeReward.ts，

```sh
import { ApolloClient, gql, HttpLink, InMemoryCache } from 'apollo-boost';
import { fetch } from 'cross-fetch';
```





## 其他琐碎

1. player每一期可以领取的数量，可以从graph中读取，合约中没有存储，合约仅仅是用来分配，领取的，未存储中间数据。
2. 
