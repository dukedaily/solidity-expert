/**
[TestInfo]
pattern: ShadowedBuiltinPattern

 */

pragma solidity ^0.5.4;

contract selfdestruct { // violation
    uint this = 1; // violation

    function require() public payable { // violation
    }

    function test1(uint block) public payable { // violation
    }

    function test2() public payable returns (uint keccak256) { // violation
        keccak256 = 3;
    }

    enum ripemd160 { // violation
        mulmod, // violation
        thisIsOk,
        addmod // violation
    }

    struct Test {
        uint mulmod; // violation
        uint assert; // violation
    }
}

