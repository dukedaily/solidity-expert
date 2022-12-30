pragma solidity ^0.5.0;

contract TestContract {
    uint storageVar;

    function identity(uint i) public returns (uint) {
        return identity1(i);
    }

    function identity1(uint i) public returns (uint) {
        return identity2(i);
    }

    function identity2(uint i) public returns (uint) {
        return identity3(i);
    }

    function identity3(uint i) public returns (uint) {
        return identity4(i);
    }

    function identity4(uint i) public returns (uint) {
        return i;
    }

    function main() public payable {
        storageVar = identity(msg.value);
        storageVar = identity(0);
        sink(identity(0));
        sink(identity(storageVar));
    }

    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
