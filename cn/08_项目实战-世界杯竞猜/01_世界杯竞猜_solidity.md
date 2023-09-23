# 第1节 世界杯竞猜（solidity）

>  小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
>  职场进阶: https://dukeweb3.com

## 概述

通过学习，初步了解以太坊开发的基础工具链，通过一个案例（世界杯精彩）实战，使大家掌握基本的solidity开发，完成语法学习。

1. [点击查看效果](https://solidity-expert-worldcup.vercel.app/)
2. [点击获取代码](https://github.com/dukedaily/solidity-expert/tree/main/cn/08_%E9%A1%B9%E7%9B%AE%E5%AE%9E%E6%88%98-%E4%B8%96%E7%95%8C%E6%9D%AF%E7%AB%9E%E7%8C%9C/code/contracts)
3. [点击查看视频](https://dukeweb3.com/courses/enrolled/2187286)

## 学习目标

- Metamask：助记词、私钥、地址、gas费相关
- Remix：部署、交互、abi、bytecode
- Etherscan：交易分析、verify合约
- 基础solidity语法：基础类型、如何转账、可见性、手续费、Event



## 业务需求

1. 参赛球队一经设定不可改变，整个活动结束后无法投票；
2. 全⺠均可参与，无权限控制；
3. 每次投票为1ether，且只能选择一支球队；
4. 每个人可以投注多次；
5. 仅管理员公布最终结果，完成奖金分配，开奖后逻辑：
6. winner共享整个奖金池（一部分是自己的本金，一部分是利润）；
7. winner需自行领取奖金（因为有手续费）；
8. 下一期自行开始

### 最初状态

![流程图a](assets/流程图a.jpg)

### 开始投票

![流程图b](assets/流程图b.jpg)

### 开奖后

![流程图c](assets/流程图c.jpg)

## 需求分析

1. 状态变量(真正上链）：管理员、记录所有玩家、统计每个球队参与者、记录获奖者信息、第几期、参赛球队
2. 核心方法：投票、开奖、领奖
3. 辅助方法：获取奖金池金额、管理员地址、当前期数、参与人数、所有玩家、参赛球队



## 知识点

1. 1 ether = 10^18wei, 

2. 1 gwei = 10^9 wei

3. 1 ether = 10^9 gwei

4. tx：

   ```js
   1. from：交易发起人， 合约中是：msg.sender
   2. to：交互合约地址，传给合约的数据：msg.data
   3. value：传递的金额，msg.value
   ```

5. **"storage", "memory"** 

   1. Storage: 引用传值，修改会同步修改原变量
   2. **memory：值传递，完全独立的拷贝**



## 代码

- goerli地址：0xD0f85823D7e118BB7fa4D460A25851fCf99f7Fa9

- https://goerli.etherscan.io/address/0xD0f85823D7e118BB7fa4D460A25851fCf99f7Fa9

```JavaScript
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

contract WorldCup {
    // 1. 状态变量：管理员、所有玩家、获奖者地址、第几期、参赛球队
    // 2. 核心方法：下注、开奖、
    // 3. 辅助方法：获取奖金池金额、管理员地址、当前期数、参与人数、所有玩家、参赛球队

    address public admin;
    uint8 public currRound;

    // string[] public countries; // ["GERMANY", "FRANCH", "CHINA", "BRIZAL", "KOREA"]
    string[] public countries = ["GERMANY", "FRANCH", "CHINA", "BRIZAL", "KOREA"];
    mapping (uint8 => mapping (address => Player)) players;
    mapping (uint8 => mapping (Country => address[])) public countryToPlayers;
    mapping (address => uint256) public winnerVaults;

    uint256 public immutable deadline;
    uint256 public lockedAmts;

    enum Country {
        GERMANY,
        FRANCH,
        CHINA,
        BRAZIL,
        KOREA
    }

    event Play(uint8 _currRound, address _player, Country _country);
    event Finialize(uint8 _currRound, uint256 _country);
    event ClaimReward(address _claimer, uint256 _amt);

    modifier onlyAdmin {
        require(msg.sender == admin, "not authorized!");
        _;
    }

    struct Player {
        bool isSet;
        mapping (Country => uint256) counts;
    }

    // constructor(string[] memory _countries, uint256 _deadline) {
    constructor(uint256 _deadline) {
        admin = msg.sender;
        require(_deadline > block.timestamp, "WorldCupLottery: invalid deadline!");
        deadline = _deadline;
    }

    function play(Country _selected) payable external {
        // 参数校验
        require(msg.value == 1 gwei, "invalid funds provided!");

        require(block.timestamp < deadline, "it's all over!");

        // 更新countryToPlayers
        countryToPlayers[currRound][_selected].push(msg.sender);
        
        // 更新players
        Player storage player = players[currRound][msg.sender];
        // player.isSet = false;
        player.counts[_selected] += 1;

        emit Play(currRound, msg.sender, _selected);
    }
    
    // 写另外一个合约，模拟oracle，讲解合约间调用
    function finialize(Country _country) onlyAdmin external {
        // 找到winners
        address[] memory winners = countryToPlayers[currRound][_country];
        uint256 distributeAmt;

        // 分配奖励金额
        uint currAvalBalance = getVaultBalance() - lockedAmts;
        console.log("currAvalBalance:", currAvalBalance, "winners count:", winners.length);

        for (uint i = 0; i< winners.length; i++) {
            address currWinner = winners[i];

            // 获取每个地址应该得到的份额
            Player storage winner = players[currRound][currWinner];
            if (winner.isSet) {
                console.log("this winner has been set already, will be skipped!");
                continue;
            }

            winner.isSet = true;

            uint currCounts = winner.counts[_country];

            // （本期总奖励 / 总参与人数）* 当前地址持有份额
            uint amt = (currAvalBalance / countryToPlayers[currRound][_country].length) * currCounts;

            winnerVaults[currWinner] += amt;
            distributeAmt += amt;
            lockedAmts += amt;

            console.log("winner:", currWinner, "currCounts:", currCounts);
            console.log("reward amt curr:", amt, "total:", winnerVaults[currWinner]);
        }

        uint giftAmt = currAvalBalance - distributeAmt;
        if (giftAmt > 0) {
            winnerVaults[admin] += giftAmt;
        }

        emit Finialize(currRound++, uint256(_country));
    }

    function claimReward() external {
        uint256 rewards = winnerVaults[msg.sender];
        require(rewards > 0, "nothing to claim!");

        winnerVaults[msg.sender] = 0;
        lockedAmts -= rewards;
        (bool succeed,) = msg.sender.call{value: rewards}("");
        require(succeed, "claim reward failed!");

        console.log("rewards:", rewards);

        emit ClaimReward(msg.sender, rewards);
    }

    ////////////////////////////////////////////// getter functions ////////////////////////////////////////////////

    function getVaultBalance() public view returns(uint256 bal){
        bal = address(this).balance;
    }

    function getCountryPlayters(uint8 _round, Country _country) external view returns (uint256) {
        return countryToPlayers[_round][_country].length;
    }

    function getPlayerInfo(uint8 _round, address _player, Country _country) external  view returns (uint256 _counts) {
        return players[_round][_player].counts[_country];
    }
}
```



## 下次预告

1. 使用工程化来管理合约
2. 自动编译、部署、verify、单元测试、fork主网



## 资源链接

1. 详细知识点：https://github.com/dukedaily/solidity-expert
2. 快速添目标网络：https://chainlist.org/
3. 水龙头领取Goerli主币：https://goerlifaucet.com/
4. 一键领取多个水龙头，需要Twitter登录：https://faucet.paradigm.xyz/
5. 详细知识点托管在github：https://github.com/dukedaily/solidity-expert



---

加V入群：dukeweb3，公众号：[阿杜在新加坡](https://mp.weixin.qq.com/s/kjBUa2JHCbOI_2UKmZxjJQ)，一起抱团拥抱web3，下期见！

> 关于作者：国内第一批区块链布道者；2017年开始专注于区块链教育(btc, eth, fabric)，目前base新加坡，专注海外defi,dex,元宇宙等业务方向。