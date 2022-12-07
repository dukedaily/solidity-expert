/**
[TestInfo]
pattern: ShadowedLocalVariablePattern

 */
pragma solidity ^0.5.4;

contract Base {
    uint constant stateA = 1;
    uint constant stateB = 2;
}

contract Base2 is Base {
    uint constant stateA = 7;

    function functionA() public {}

    modifier modA { _; }

    event E();

    function functionB() public {
        uint stateA = 3; // violation
        uint stateB = 3; // violation

        function () functionB = functionA; // violation
    }
}

contract Contract is Base2 {
    function shadowingParent(uint stateA, uint arg) public // violation
        returns (uint stateB) { // violation

        for(int arg = 0; arg < 10; arg++) { // violation
            uint test;
        }

        uint test; // ok

        if (stateA == 1) {
            uint test; // violation
            uint test2; // ok
        } else {
            uint test; // violation
            uint test2; // ok
        }

        uint test2; // ok
        uint E; // violation

        return 1;
    }

    modifier modB(uint E) { _; } // violation
    modifier modC(uint modA) { _; } // violation
}