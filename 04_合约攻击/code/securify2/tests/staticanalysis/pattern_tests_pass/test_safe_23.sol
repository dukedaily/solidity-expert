pragma solidity ^0.5.0;

contract TestContract {
    uint storageVar;

    function fibonacci(uint n) public returns (uint) {
        if (n >= 2) {
            return fibonacci(n-1) + fibonacci(n-2);
        }

        return 0;
    }

    function main() public payable {
        fibonacci(msg.value);
        sink(fibonacci(4));
    }

    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
