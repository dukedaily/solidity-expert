pragma solidity ^0.5.0;

contract TestContract {
    function main() public payable {
        int256 tmp = 1;
        if (msg.value > 4) {
            tmp = tmp + 2;
        }
        if (tmp > 0) {
            sink(54); //safe
        } else {
            sink(9); //safe
        }
    }

    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
