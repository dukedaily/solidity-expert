pragma solidity ^0.5.0;

contract TestContract {
    function sink(address _) pure public {}
    function sink(uint _) pure public {}

    function f(uint256 x) public returns (uint256) {
        return x;
    }

    function test() public payable {
        uint256 a = msg.value;

        a = f(a) * f(a);
        uint256 b = f(a) + f(a);
        b = 1;
        b = f(b);

        sink(b); // Safe
    }
}
