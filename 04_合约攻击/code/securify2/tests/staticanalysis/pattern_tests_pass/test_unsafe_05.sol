pragma solidity ^0.5.0;

contract TestContract {
    function sink(address _) pure public {}

    function sink(uint _) pure public {}

    function f() public returns (address) {
        return msg.sender;
    }

    function sink2(address a) public {
        sink(a);
    }

    function test() public payable {
        sink2(address(0));
        sink2(f()); // Tainted
    }
}
