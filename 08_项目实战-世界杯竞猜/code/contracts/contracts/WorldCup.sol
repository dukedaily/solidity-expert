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