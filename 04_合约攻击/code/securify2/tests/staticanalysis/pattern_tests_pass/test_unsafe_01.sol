pragma solidity ^0.5.0;

contract TestContract {
    function sink(address _) pure public {}
    function sink(uint _) pure public {}

    function test() public payable {
        uint256 tmp = msg.value;
        sink(tmp); // Tainted
    }

    function test2() public payable {
        uint256 tmp = 1234;
        sink(tmp); // Safe
    }
}
