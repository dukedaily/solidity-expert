/**
[Specs]
pattern: UninitializedStateVariablePattern
 */
pragma solidity ^0.5.4;

contract Uninitialized {
    address payable destination; // violation
    mapping (address=>uint) unused;

    function transfer() payable public {
        destination.transfer(msg.value);
    }
}