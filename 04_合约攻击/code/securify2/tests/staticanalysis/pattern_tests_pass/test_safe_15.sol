pragma solidity ^0.5.0;

contract TestContract {

    function main() public payable {
        uint a = 5;

        if (msg.value > 10)
            a = 5;

        sink(a);
    }

    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
