pragma solidity ^0.5.0;

contract TestContract {

    function mixParameters12(uint a, uint b, uint c) public returns (uint) {
        return a + b;
    }

    function mixParameters23(uint a, uint b, uint c) public returns (uint) {
        return b + c;
    }

    function main() public payable {
        uint tmp1 = mixParameters12(msg.value, msg.value, msg.value);
        uint tmp2 = mixParameters23(msg.value, msg.value, msg.value);

        uint tmp3 = mixParameters23(msg.value, 2, 3);
        uint tmp4 = mixParameters12(tmp3, msg.value, msg.value);
        uint tmp5 = mixParameters12(tmp3, tmp4, msg.value);

        sink(tmp5);
    }


    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
