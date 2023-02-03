/**
[Specs]
pattern: DAOConstantGasPattern
 */
pragma solidity ^0.5.0;
contract MarketPlace {
    uint balance = 0;

    //TODO: originally the calls were `msg.sender.call.value(x)("")

    function noReentrancy() public {
        uint x = balance;
        balance = 0;
        msg.sender.send(x); // compliant
    }
    
    function reentrancy() public {
        uint x = balance;
        msg.sender.send(x); // violation
        balance = 0;
    }
    
}

