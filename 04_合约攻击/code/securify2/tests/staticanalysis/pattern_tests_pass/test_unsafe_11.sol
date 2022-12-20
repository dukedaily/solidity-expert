pragma solidity ^0.5.0;

contract TestContract {

    function main() public payable {
        uint a = 0;

        a += msg.value;

        sink(a);
    }


    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
