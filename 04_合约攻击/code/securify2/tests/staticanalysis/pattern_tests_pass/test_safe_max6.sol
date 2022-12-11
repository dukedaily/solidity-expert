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

    // result is tainted iff y is tainted
    function f2(uint256 x, uint256 y) public returns (uint256) {
        uint256 g = x;
        uint256 h = y; // h is tainted iff y is tainted
        return f(h, g); // result is tainted iff h is tainted
    }

    function test() public payable {
        uint256 a = msg.value;
        uint256 b = 15;
        
        a = f2(a, b); // b not tainted => a is not tainted
        b = f2(msg.value, a); // a not tainted => b is not tainted

        sink(b); // Safe
    }
}