pragma solidity ^0.4.23;

contract MyContract {
    uint someVal;
    function Foo() public payable returns (uint) {
        someVal = msg.value;
    }
}
