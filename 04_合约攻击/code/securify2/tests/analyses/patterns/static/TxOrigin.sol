/**

[TestInfo]
pattern: TxOriginPattern

 */
pragma solidity ^0.5.4;

contract Contract {

    address payable owner;

    constructor () public{
        owner = msg.sender;
    }

    function test1() public {
        require(tx.origin == owner); // violation
        msg.sender.send(240194);
    }

    function test2() public {
        if (tx.origin != owner) // violation
            assert(false);
    }

    function test3() public {
        require(msg.sender == tx.origin); // compliant
        msg.sender.send(240194);
    }

    function test4() public {
        selfdestruct(tx.origin); // ok
    }
}
