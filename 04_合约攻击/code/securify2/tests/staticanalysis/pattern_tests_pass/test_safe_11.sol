pragma solidity ^0.5.0;

contract TestContract {

    function double(uint value) public returns (uint){
        return value * 2;
    }

    function main() public payable {
        uint a = double(msg.value);
        uint b = double(10);
        sink(b);
    }


    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
