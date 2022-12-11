pragma solidity ^0.5.0;

contract TestContract {
    function sink(address _) pure public {}
    function sink(uint _) pure public {}

    function test() public payable {
        uint256 a = msg.value;

        if (msg.value == 1) {
            a = 1;
        } else {
            a = 2 * a;
        }

        sink(a); // Unsafe
    }
}
