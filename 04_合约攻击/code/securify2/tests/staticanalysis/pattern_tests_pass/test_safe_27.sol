pragma solidity ^0.5.0;

contract TestContract {
    function main() public payable {
        uint256 x = msg.value;
        uint256 y = 4;
        uint256 z = 7;
        y = x; // msg.value
        y = z; // 7
        z = x; // msg.value
        x = y; // 7
        y = z; // msg.value
        z = y; // msg.value
        z = x; // 7
        sink(z);
    }

    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
