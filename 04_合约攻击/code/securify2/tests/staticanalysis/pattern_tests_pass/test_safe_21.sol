pragma solidity ^0.5.0;

contract TestContract {
    uint storageVar;

    function main() public payable {
        uint a = 5 + 5;
        if (a != 10) {
            sink(msg.value);
        }
    }

    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
