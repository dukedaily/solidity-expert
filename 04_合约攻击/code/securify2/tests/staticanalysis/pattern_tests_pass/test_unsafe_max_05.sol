pragma solidity ^0.5.0;

contract TestContract {
    function sink(address _) pure public {}
    function sink(uint _) pure public {}

    // result is tainted iff x is tainted
    function f(uint256 x, uint256 y) public returns (uint256) {
        uint256 z = y;
        if (z == 1) {
            z = 1;
        }
        else {
            z = 1;
        }
        return 2 * x * z;
    }

    function test() public payable {
        uint256 a = msg.value;
        uint256 b = 15;
        
        b = f(a, b); // a tainted => b tainted
        a = 1;
        a = f(b, a); // b tainted => a tainted

        sink(b); // Unsafe
    }
}
