pragma solidity ^0.4.23;

contract MyContract {
  function Foo() public {
    msg.sender.send(1);
  }
}
