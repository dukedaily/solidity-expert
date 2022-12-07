/**
[Specs]
pattern: TODTransferPattern

 */
pragma solidity ^0.5.0;

contract game {
  bool won = false;

  function play() public {
    require(!won);
    won = true;
    msg.sender.transfer(10 ** 18); // violation
  }
}
