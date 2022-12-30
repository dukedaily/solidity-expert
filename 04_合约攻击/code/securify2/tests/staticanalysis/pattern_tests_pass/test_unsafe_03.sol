pragma solidity ^0.5.0;

contract TestContract {
    function sink(address _) pure public {}
    function sink(uint _) pure public {}

    function test() public payable {
        uint256 tmp = 0;
        if (msg.sender == address(0x1234)) {
          tmp = 1;
        }
        sink(tmp); // Tainted
    }
}
