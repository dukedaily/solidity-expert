pragma solidity ^0.5.0;

contract TestContract {
    function sink(address _) pure public {}

    function sink(uint _) pure public {}

    uint a;

    function taint() internal {
        a = msg.value;
    }

    function untaint() internal {
        a = 0;
    }

    function test() public payable {
        untaint();
        taint();
        sink(a);
    }
}
