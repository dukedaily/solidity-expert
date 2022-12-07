pragma solidity ^0.5.0;

contract TestContract {
    function sink(address _) pure public {}

    function sink(uint _) pure public {}

    function f() public returns (address) {
        return msg.sender;
    }

    function dontSinkThis(address a) public {
        sink(address(0));
    }

    function test() public payable {
        dontSinkThis(f()); // Safe
    }
}
