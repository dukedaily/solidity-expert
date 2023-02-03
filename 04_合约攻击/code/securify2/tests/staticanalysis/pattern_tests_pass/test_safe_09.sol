pragma solidity ^0.5.0;

contract TestContract {

    function taint(uint a, uint b, uint c) public returns (uint, uint) {
        return (a + b, 5);
    }

    function main() public payable {
        uint a = msg.value;
        uint b = msg.value;
        uint r1;
        uint r2;

        (r1, r2) = taint(a, 4, 6);

        //sink(r1); // Tainted
        sink(r2); // Untainted

        b = r2;

        (r1, r2) = taint(b, b, a);

        sink(r1); // Untainted
        sink(r2); // Untainted
    }

    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}
    function sink(uint _) pure public {}
}
