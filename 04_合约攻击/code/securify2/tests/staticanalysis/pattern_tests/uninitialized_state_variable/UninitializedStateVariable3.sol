/**
[Specs]
pattern: UninitializedStateVariablePattern
 */
pragma solidity ^0.5.4;

contract Uninitialized {
    address payable destination; // warning
    address payable destination1; // violation
    address payable destination2; // compliant

    constructor () public {
        if (msg.sender != address(0x100000)) {
            destination = msg.sender;
        }

        if (msg.sender != address(0x100000)) {
            destination2 = msg.sender;
        } else {
            destination2 = address(0x20000);
        }
    }

    function transfer() payable public {
        destination.transfer(msg.value);
        destination1.transfer(msg.value);
        destination2.transfer(msg.value);
    }
}