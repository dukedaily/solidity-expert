pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//合约继承，使用 is
contract FHTToken is ERC20 {
    // 构造函数中进行初始化，发行token
    // 1. 发行 1000w FHT Token
    // 2. 一次性mint出来，不允许后续mint
    // uint8 x;
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) ERC20(name_, symbol_) {
        _mint(msg.sender, totalSupply_);
    }
    
    //10000000,000000
    function decimals() public pure override returns (uint8) {
      return 6;
    }
}
