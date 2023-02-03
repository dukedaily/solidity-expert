pragma solidity ^0.5.0;

contract TestContract {
    function main() public payable {
        if (msg.value == 0) {
            sink(5);
        } else {
            sink(5);
        }
    }

    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
