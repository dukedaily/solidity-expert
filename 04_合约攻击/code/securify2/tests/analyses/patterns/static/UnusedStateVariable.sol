/**

[TestInfo]
pattern: UnusedStateVariablePattern

 */
pragma solidity ^0.5.0;

contract UnusedStateVariable {
    uint test1; // violation
    uint test2 = 5; // violation
    uint test3 = 4;
    uint test4 = 8; // violation
    uint test5 = 5; // violation

    function function1() public returns (uint) {
        return test3;
    }
}

contract UnusedStateVariableDerived is UnusedStateVariable {
    function function2() external returns (uint) {
        return test4;
    }

    function function3() private returns (uint) {
        return test5;
    }
}