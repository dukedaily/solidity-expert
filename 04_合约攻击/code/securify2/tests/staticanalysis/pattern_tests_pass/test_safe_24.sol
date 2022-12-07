pragma solidity ^0.5.0;

contract TestContract {
    function main() public payable {
        if (msg.sender == address (0)) {
            return;
            sink(msg.sender);
        } else {
            return;
            sink(msg.sender);
        }

        sink(msg.sender);
    }

    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
