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

  entity.result = event.params._giftAmt; // TODO need change to _country later
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

/*
export function handleClaimReward(event: ClaimReward): void {
  // Entities can be loaded from the store using a string ID; this ID
  // needs to be unique across all entities of the same type
  let entity = ExampleEntity.load(event.transaction.from.toHex())

  // Entities only exist after they have been saved to the store;
  // `null` checks allow to create entities on demand
  if (!entity) {
    entity = new ExampleEntity(event.transaction.from.toHex())

    // Entity fields can be set using simple assignments
    entity.count = BigInt.fromI32(0)
  }

  // BigInt and BigDecimal math are supported
  entity.count = entity.count + BigInt.fromI32(1)

  // Entity fields can be set based on event parameters
  entity._claimer = event.params._claimer
  entity._amt = event.params._amt

  // Entities can be written to the store with `.save()`
  entity.save()

  // Note: If a handler doesn't require existing field values, it is faster
  // _not_ to load the entity from the store. Instead, create it fresh with
  // `new Entity(...)`, set the fields that should be updated and save the
  // entity back to the store. Fields that were not set or unset remain
  // unchanged, allowing for partial updates to be applied.

  // It is also possible to access smart contracts from mappings. For
  // example, the contract that has emitted the event can be connected to
  // with:
  //
  // let contract = Contract.bind(event.address)
  //
  // The following functions can then be called on this contract to access
  // state variables and other data:
  //
  // - contract.admin(...)
  // - contract.countries(...)
  // - contract.countryToPlayers(...)
  // - contract.currRound(...)
  // - contract.deadline(...)
  // - contract.getCountryPlayters(...)
  // - contract.getPlayerInfo(...)
  // - contract.getVaultBalance(...)
  // - contract.lockedAmts(...)
  // - contract.winnerVaults(...)
}
*/

export function handleBlock(block: ethereum.Block): void {
  let id = block.number.toString();
  let entity = new SimpleBlock(id);
  entity.height = block.number;
  entity.time = block.timestamp;
  entity.save();
}
