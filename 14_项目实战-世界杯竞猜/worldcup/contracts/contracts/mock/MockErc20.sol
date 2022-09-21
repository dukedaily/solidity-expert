// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FHTToken is ERC20 {
  constructor(string memory _name, string memory _symbol, uint256 _totalSupply) ERC20(_name, _symbol) {
    _mint(msg.sender, _totalSupply);
  } 

  function decimals() public pure override  returns (uint8) {
    return 6;
  }
}