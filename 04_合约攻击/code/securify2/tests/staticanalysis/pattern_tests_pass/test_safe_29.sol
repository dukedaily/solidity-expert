pragma solidity ^0.5.0;

contract TestContract {
    function main() public payable {
        uint t = 2147483647;
        if (t + 1147483647 > 0) {
            sink(msg.value);
        }
    }

    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
