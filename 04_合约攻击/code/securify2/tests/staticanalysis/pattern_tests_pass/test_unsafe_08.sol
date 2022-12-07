pragma solidity ^0.5.0;

contract TestContract {

    function main() public payable {
        uint i = 1;

        for (i = 0; i < msg.value; i++) {
            uint a = 0;
        }
        sink(i);
    }


    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
