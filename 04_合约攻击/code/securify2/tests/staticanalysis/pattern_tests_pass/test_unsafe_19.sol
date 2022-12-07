pragma solidity ^0.5.0;

contract TestContract {

    function swapAllAndMix23(uint a, uint b, uint c) public returns (uint, uint, uint) {
        uint mixed = mixParameters(b, c);
        uint a1;
        uint b1;

        // Weed out solutions with less than 2-context-sensitivity
        swapParameters(a, b);
        swapParameters(b, c);
        swapParameters(a, c);
        mixParameters(a, c);
        mixParameters(a, b);

        (b1, a1) = swapParameters(mixed, a);

        return (c, a1, b1);
    }

    function mixParameters(uint a, uint b) public returns (uint) {
        return a * b;
    }

    function swapParameters(uint a, uint b) public returns (uint, uint) {
        uint a1;
        uint b1;

        a1 = b + 5;
        // Add some "noise instructions"
        b1 = a + 5;

        return (a1 - 5, b1 - 5);
    }

    function main() public payable {
        swapAllAndMix23(msg.value, msg.value, msg.value);

        (uint a, uint b, uint c) = swapAllAndMix23(4, msg.value, 5);

        sink(b);
    }


    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
