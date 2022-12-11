pragma solidity ^0.5.0;

contract TestContract {
    function sink(address _) pure public {}

    function sink(uint _) pure public {}

    function test() public payable {
        uint test = 0;
        for (int j = 0; j < 2; j++) {
            for (int k = 0; k < 2; k++) {
                test++;
            }
        }
        sink(test); // Safe
    }
}
