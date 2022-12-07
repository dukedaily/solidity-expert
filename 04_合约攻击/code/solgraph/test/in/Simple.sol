pragma solidity ^0.4.23;

contract MyContract {
  uint counter = 0;

  function Count() public {
    counter++;
  }

  function CallCount() public {
    Count();
  }
}
