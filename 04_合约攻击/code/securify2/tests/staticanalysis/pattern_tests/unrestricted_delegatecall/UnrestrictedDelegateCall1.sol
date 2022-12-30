/**
[Specs]
pattern: UnrestrictedDelegateCallPattern
 */
pragma solidity ^0.5.0;

contract Example1 {

    address owner;
    address target1;
    address target2;

    constructor (address someContract) public {
        owner = msg.sender;
        target1 = someContract;
        target2 = someContract;
    }

    function callable(address someContract) public payable {
        target2 = someContract;
    }

    function test1(address someContract) public payable {
        target1.delegatecall(""); // compliant
    }

    function test2(address someContract) public payable {
        target2.delegatecall(""); // warning
    }

    function test3(address someContract) public payable {
        if (msg.sender == owner) {
            someContract.delegatecall(""); // compliant
        }
    }

    function test4(address someContract) public payable {
        someContract.delegatecall(""); // violation
    }
}
