pragma solidity ^0.5.0;

contract TestContract {
    uint storageVar;

    function main() public payable {
        uint val = msg.value;
        while (!(val == 2)) {
            return;
        }

        sink(5);
    }

    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
