/**
[Specs]
pattern: MulAfterDivPattern
 */
pragma solidity ^0.5.0;

contract MulAfterDiv {

    mapping(address => uint256) private tokens;

    function deposit() public payable {
        tokens[msg.sender] = msg.value / 10;
    }

    function withdraw() public {
        tokens[msg.sender] = 0;
        msg.sender.transfer(tokens[msg.sender] * 10); // compliant
    }

    function violation() public payable {
        uint tmp = msg.value / 3;
        msg.sender.transfer(tmp * 3); // violation
    }
}
