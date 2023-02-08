# MEV（Maximum Extractable Value）

参考视频：

1. https://www.youtube.com/watch?v=XbMtIg5OgCc
2. https://www.youtube.com/watch?v=Z_charqdlJk
3. 文档：https://mp.weixin.qq.com/s/Yd-umFnjhXyB7crei2lynA

# 从交易顺序角度

## 1. 抢跑

1. Bob发现一个套利的机会，发起了一笔交易tx，从而获利；
2. 这笔交易提交到矿工的mem pool中；
3. 矿工（miner，validator）发现这笔交易有利可图，因此自己也发起了同样一笔套利交易，并优先Bob打包交易；
4. Bob执行套利失败，矿工套利成功。



## 2. 跟跑

1. 当在uniswap中有一个大额swap时，会抬高ETH的价格，此时其他dex中的ETH价格依然是低价；
2. 我们可以创建一个交易跟在这笔交易之后发起，从其他交易所借款，然后在uniswap中卖掉，从而通过扳平价格套利成功。



## 3. 三明治攻击

1. Bob发起大额的swap交易tx1，购买ETH；
2. 矿工可以tx1前发起一笔交易tx0，购买ETH，提供ETH价格，Bob发起后，购买了高价ETH，并且购买后ETH价格进一步被抬高了；
3. Bob的交易执行后，矿工再按照当前的高价卖出ETH，从而获利；



## 4. Time-Bandit Attack

1. 对于尚未发生的交易，有利可图时，可以通过三明治攻击
2. 对于已经发生的套利交易，矿工可以通过分叉来套利，在新的分叉上自己执行这笔交易获利（当这笔交易的收益高于分叉时）

# 从应用角度

## 1. 清算liquidation

1. 清算获利，超额抵押
2. 分批次清算
3. 任何人都可以发起清算，一般是bot机器人做的



## 2. 交易所套利

1. 多跳，原子性，multi-hop
2. 无本金，使用flashloan

# MEV的影响

1. 正向影响：

   1. 帮助defi健康运行（清算）

2. 负面影响：

   1. gas war：PGA（Priority Gas Auction）交易之间为了提高优先级而提高gas fee（链上抢购、清算情况下会发生）
   2. darkforest：上链的交易是公开的，会被攻击（抢炮、跟跑、三明治攻击）
   3. Reorg：为了套利而分叉

3. 解决方案：

   1. EIP1559引入，让MEV成本变高，gasfee更加平滑，有自动平衡的机制，gas price = base fee + tips，其中base fee会烧掉，每隔一个区块只能增加gas1.125倍base fee，所以gasfee更加平滑，最高上升到2倍（与使用block的总gas使用情况有关系）：==解决了1==

   2. flashbots/MEV-boost引入中心化的Sequencer：引入了链下竞价方式，一部分收入要给到链下服务：==解决了：1，2==

   3. Rollups：引入了layer2的FCFS，可以避免MEV的影响，==解决了：1，2，3==

      