import { ApolloClient, gql, HttpLink, InMemoryCache } from 'apollo-boost';
import { fetch } from 'cross-fetch';
import { BigNumber } from 'bignumber.js'

// const graphUrl = process.env.SUBGRAPH_API;
const graphUrl = "http://localhost:8000/subgraphs/name/duke/worldcup"

async function executeQuery(query: string, variables: any) {
  const client = new ApolloClient({
    link: new HttpLink({ uri: graphUrl, fetch }),
    cache: new InMemoryCache(),
  });

  // console.log('ready to executeQuery...');

  return await client.query({
    query: gql(query),
    variables: variables,
  });
}

function calculatePlayerReward() {
  /*
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
  */
}

async function getPlayerRecords(index: number) {
  const query = `{
    playRecords(where: {
      index: ${index}
    }){
      id
      index
      player
      selectCountry
      block
    }
  }
  `;

  // console.log('playRecords query:', query);

  let data = await executeQuery(query, {})
  return data['data']['playRecords']
}

async function getWinnerHistory(index: number) {
  const query = `{
    finializeHistory(id: ${index}) {
      result
    }
  }
  `;

  // console.log('getWinnerHistory query:', query);

  let data = await executeQuery(query, {})
  return data['data']['finializeHistory']
}

function getPlayerRewardList(records: any, winner: number) {
  // 遍历所有的records，计算每个人的奖励数量，返回一个数组，然后抛出来，后续使用进行merkel计算
  let group = {}
  let totalWeight: string

  records.map((it: {
    player(arg0: string, player: any): unknown; selectCountry: number;
  }) => {
    // 未猜中weight为1
    // 猜中奖励翻倍
    // console.log('mapping it:', it);
    // console.log('it.selectCountry:', it.selectCountry, 'winner:', winner);
    let weight

    if (it.selectCountry === winner) {
      console.log('weight is 2 for', it.player);
      weight = 2
    } else {
      console.log('\t weight is 1 for', it.player);
      weight = 1
    }
    return [it, weight]
  }).forEach((element: {
    weight(weight: any): unknown; player: string | number;
  }) => {
    let value = group[element[0].player] || {
      list: [],
      weight: '0'
    }

    // console.log('current value:', value);

    value.list.push(element[0])
    value.weight = new BigNumber(value.weight).plus(element[1]).toFixed()
    totalWeight = new BigNumber(totalWeight).plus(element[1]).toFixed()

    group[element[0].player] = value
  });

  console.log('group', group)
}

function generateMerkelRoot(list: any) {

}

const CURRENT_ROUND = 0;

async function main() {
  // query subgraph to get user data
  const playRecords = await getPlayerRecords(CURRENT_ROUND)
  // console.log('playRecords:', playRecords);

  const winner = await getWinnerHistory(CURRENT_ROUND + 1) // TODO need bug fix
  console.log(`winner for round ${CURRENT_ROUND} is : ${winner['result']}`);

  // calculate reward for each player
  const playerRewardList = getPlayerRewardList(playRecords, winner['result'])

  // generate Merkel Root 
  const root = generateMerkelRoot(playerRewardList)

  // call method of distributor 

  // get userDistribution

  // user Claim
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
})