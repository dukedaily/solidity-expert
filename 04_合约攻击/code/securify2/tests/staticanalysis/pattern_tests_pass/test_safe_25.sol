pragma solidity ^0.5.0;

contract TestContract {
    function main() public payable {
        uint a = 0;
        for (uint i = 0; i < 10; i++) {
            a = a + 1;
        }
        sink(a); // Safe
    }

    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
