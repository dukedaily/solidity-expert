/**
[Specs]
pattern: UninitializedStateVariablePattern
 */
pragma solidity ^0.5.4;

contract Uninitialized {
    address payable destination = address(0); // compliant

    function transfer() payable public {
        destination.transfer(msg.value);
    }
}