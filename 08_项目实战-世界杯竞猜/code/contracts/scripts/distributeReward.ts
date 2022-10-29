import { ApolloClient, gql, HttpLink, InMemoryCache } from 'apollo-boost';
import { fetch } from 'cross-fetch';
import { BigNumber } from 'bignumber.js'
import { MerkleTree } from 'merkletreejs'
import hre from 'hardhat'

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

async function getPlayerDistributions(index: number) {
  const query = ` {
    playerDistributions(
      where : {
        index: ${index}
      }
    ) {
      player
      rewardAmt
      weight
    }
  }
  `;

  // console.log('getWinnerHistory query:', query);

  let data = await executeQuery(query, {})
  return data['data']['playerDistributions']
}

function getPlayerRewardList(totalReward: string, records: any, winner: number) {
  // 遍历所有的records，计算每个人的奖励数量，返回一个数组，然后抛出来，后续使用进行merkel计算
  let group = {}
  let totalWeight: string = '0'

  records.map((it: {
    player(arg0: string, player: any): unknown; selectCountry: number;
  }) => {
    // 猜中奖励翻倍
    // console.log('mapping it:', it);
    // console.log('it.selectCountry:', it.selectCountry, 'winner:', winner);
    let weight = (it.selectCountry === winner) ? 2 : 1
    return { it, weight }
  }).forEach((element: {
    weight(weight: any): unknown; player: string | number;
  }) => {
    let value = group[element.it.player] || {
      list: [],
      weight: '0'
    }

    // console.log('current value:', value);

    value.list.push(element.it)
    value.weight = new BigNumber(value.weight).plus(element.weight).toFixed()
    totalWeight = new BigNumber(totalWeight).plus(element.weight).toFixed()

    group[element.it.player] = value
  });

  console.log('group', group)
  console.log('totalWeight', totalWeight)

  let playerDistributionList = []
  let actuallyAmt = "0"

  for (const player in group) {
    const item = group[player];

    // TODO dp是什么？
    item.reward = new BigNumber(item.weight).multipliedBy(totalReward).div(totalWeight).dp(0, BigNumber.ROUND_DOWN).toFixed();
    actuallyAmt = new BigNumber(actuallyAmt).plus(item.reward).toFixed()

    // console.log('total reward: ', totalReward, 'item.weight:', item.weight);
    console.log('reward:', item.reward.toString());
    playerDistributionList.push({
      player: player,
      rewardAmt: item.reward
    })
  }

  return { playerDistributionList, actuallyAmt };
}

function generateLeaf(index: number, player: string, rewardAmt: number) {
  return hre.ethers.utils.keccak256(
    hre.ethers.utils.solidityPack(
      ['uint256', 'address', 'uint256'],
      [index, player, rewardAmt]
    ))
}

function generateMerkelTree(index: number, playerRewardList: any) {
  // make leafs
  let items = playerRewardList.map(it => {
    console.log('it.rewardAmt:', it.rewardAmt);
    return generateLeaf(index, it.player, it.rewardAmt);
  })

  // create tree
  const tree = new MerkleTree(items, hre.ethers.utils.keccak256, { sort: true })
  return tree
}

export const oneEther = new BigNumber(Math.pow(10, 18))

export const createBigNumber18 = (v: any) => {
  return new BigNumber(v).multipliedBy(oneEther).toFixed()
}

const CURRENT_ROUND = 0;
const TOTAL_REWARD = createBigNumber18(10000);
const currentPlayer = '0xe8191108261f3234f1c2aca52a0d5c11795aef9e'; // TODO

async function main() {
  // query subgraph to get user data
  const playRecords = await getPlayerRecords(CURRENT_ROUND)
  // console.log('playRecords:', playRecords);

  const winner = await getWinnerHistory(CURRENT_ROUND)
  console.log(`winner for round ${CURRENT_ROUND} is : ${winner['result']}`);

  // calculate reward for each player
  const { playerDistributionList, actuallyAmt } = getPlayerRewardList(TOTAL_REWARD, playRecords, winner['result'])
  // console.log('reward list:', playerDistributionList, 'actuallyAmt:', actuallyAmt);

  // generate Merkel Root 
  const tree = generateMerkelTree(CURRENT_ROUND, playerDistributionList)
  console.log('root:', tree.getHexRoot());

  // call method of distributor 
  // TODO

  // get userDistribution from subgraph
  const playerDistributions = await getPlayerDistributions(CURRENT_ROUND)
  // console.log('playerDistributions:', playerDistributions);

  const newTree = generateMerkelTree(CURRENT_ROUND, playerDistributions)
  console.log('newRoot:', newTree.getHexRoot());

  const player = playerDistributions.filter(function (item) {
    // console.log('item.player:', item.player, 'currentPlayer:', currentPlayer)
    return item.player === currentPlayer
  })[0]

  console.log('player:', player);
  // console.log('claim player:', player[0].player, player[0].rewardAmt);

  // Claim by specific player
  const leaf = generateLeaf(CURRENT_ROUND, player.player, player.rewardAmt)
  const proof = newTree.getHexProof(leaf)
  console.log('proof:', proof);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
})