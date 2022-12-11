contract TestContract {
    function sink(address _) pure public {}
    function sink(uint _) pure public {}

    function f1(uint256 x) internal returns (uint256) {
        return 1;
    }

    function test() public payable {
        uint256 a = msg.value;

        if (msg.value == 1) {
            a = f1(msg.value);
        } else {
            a = f1(msg.value);
        }

        sink(a); // Safe
    }
}