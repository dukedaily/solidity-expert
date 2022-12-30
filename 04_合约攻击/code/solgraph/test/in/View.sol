pragma solidity ^0.4.23;

contract MyContract {
  uint value = 1;
  function Foo() public view returns(uint) {
    return value;
  }
}
