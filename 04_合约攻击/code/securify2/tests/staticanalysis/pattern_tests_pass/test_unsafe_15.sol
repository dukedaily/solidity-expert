pragma solidity ^0.5.0;

contract TestContract {

    address a = address(0);

    function main() public payable {
        uint result = 0;
        if (a == msg.sender) {
            result = 1;
        }

        a = address(0);
        address a0 = a;

        a = msg.sender;
        address a1 = a;

        a = address(0);
        address a2 = a;

        address c;


        a = address(0);
        sink(a0); // Untainted
        sink(a1); // Tainted
        sink(a2); // Untainted

//        sink(result); // Tainted
    }

    // Sink functions (need to be part of the contract)

    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
