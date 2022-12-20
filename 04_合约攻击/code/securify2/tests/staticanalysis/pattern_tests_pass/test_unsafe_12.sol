pragma solidity ^0.5.0;

contract TestContract {

    function double(uint value) public returns (uint){
        return value * 2;
    }

    function main() public payable {
        uint a = msg.value;
        uint b = double(a);
        sink(b);
    }


    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
