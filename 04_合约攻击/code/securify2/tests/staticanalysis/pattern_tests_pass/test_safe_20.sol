pragma solidity ^0.5.0;

contract TestContract {
    uint storageVar;

    function main() public payable {
        if (false) {
            sink(msg.value);
        }

        sink(5);
    }

    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
