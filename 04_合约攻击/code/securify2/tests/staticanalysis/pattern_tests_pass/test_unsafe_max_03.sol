contract TestContract {
    function sink(address _) pure public {}
    function sink(uint _) pure public {}

    function f1(uint256 x) internal returns (uint256) {
        uint256 b = x;

        if (x == 1) {
            b = 1;
        } else {
            b = 1;
        }

        return b;
    }

    function f2(uint256 x) internal returns (uint256) {
        uint256 b = x;

        if (x == 1) {
            b = 1;
        } else {
            b = b + b;
        }

        return b;
    }

    function test() public payable {
        uint256 a = msg.value;

        if (msg.value == 1) {
            a = f2(msg.value);
        } else {
            a = f1(msg.value);
        }

        sink(a); // Unsafe
    }
}