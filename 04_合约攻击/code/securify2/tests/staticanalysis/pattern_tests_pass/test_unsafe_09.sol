pragma solidity ^0.5.0;

contract TestContract {

    function main() public payable {
        uint i = 1;

        while (i < msg.value) {
            i += 1;
            if (i == 200)
                return;
        }

        sink(i);
    }


    // Sink functions (need to be part of the contract)
    function sink(address _) pure public {}

    function sink(uint _) pure public {}
}
