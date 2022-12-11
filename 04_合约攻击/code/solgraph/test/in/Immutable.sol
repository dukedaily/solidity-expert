pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyContract {
  // token
  ERC20 public immutable token = new ERC20("test", "test");

  function Foo() public constant returns(uint) {
    return 0;
  }

}
