pragma solidity ^0.5.0;

contract TestContract {

    function main() public payable {
        if (msg.value > 10) {
            sink(10);
        }
    }


    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
