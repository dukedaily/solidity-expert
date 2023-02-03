pragma solidity ^0.5.0;

contract TestContract {
    uint storedVar;

    function store(uint v) public {
        storedVar = v;
    }

    function load() public returns (uint) {
        return storedVar;
    }

    function loadAndSink() public {
        sink(load());
    }

    function main() public payable {
        if (msg.value == 10)
            store(5);
        else
            store(5);

        loadAndSink();
    }

    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
