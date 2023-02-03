pragma solidity ^0.5.0;

contract TestContract {
    function main() public payable {
        if (msg.value == 3) {
            sinkProxy();
        } else {
            sinkProxy();
        }
    }

    function sinkProxy() public {
        sink(4);
    }

    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
