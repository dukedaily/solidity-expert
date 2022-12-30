/**
[TestInfo]
pattern: TooManyDigitsPattern

 */

pragma solidity ^0.5.4;

contract AssemblyUsage {
    uint isThisOneEther = 1000000 szabo; // violation
    uint thisIsOneEther = 1 ether;

    function accept() public payable {
        require(msg.value >= 200000000000000000); // violation
    }
}

