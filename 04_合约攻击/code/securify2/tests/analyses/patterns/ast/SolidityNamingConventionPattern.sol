/**
[TestInfo]
pattern: SolidityNamingConventionPattern

 */

pragma solidity ^0.5.4;

contract Test { // ok

    struct Ok { uint a; } // ok
    struct notOk { uint a; } // violation

}

contract test { // violation

    constructor () internal {

    }

    enum Groups {A, B} // ok
    enum groups {A, B} // violation

    uint constant ANSWER = 42; // ok
    uint constant answer = 42; // violation
    uint constant ANSWER_2 = 42; // ok

    uint not_ok = 0; // violation
    uint NotOk1 = 2; // violation

    uint public _notOk = 1; // violation
    uint public not_Ok = 1; // violation

    uint thisIsOk = 1; // ok
    uint _alsoOk = 2; // ok

}

contract AnotherTest {

    constructor () public {

    }

    function _thisIsOk() private {

    }

    function _thisIsOkAsWell() internal {

    }

    function _thisIsNotOk() public {} // violation
    function _thisIsNotOkEither() external {} // violation
    function NeitherIsThis() external {} // violation
    function OR_THIS() external {} // violation

    function butThisIkOk() private { } // ok
    function asIsThis() public { } // ok

    function () external {} // ok

    modifier thisModifierIsOk { _; } // ok
    modifier ThisModifierIsNotOk { _; } // violation
    modifier _thisModifierIsNotOkEither { _; } // violation

}