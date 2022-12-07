/**
[TestInfo]
pattern: CallToDefaultConstructorPattern

 */

pragma solidity ^0.5.4;

contract Base {}

contract Contract1 is Base {

    constructor () public Base() {} // violation

}

contract Contract2 is Base {

    constructor () public {} // OK

}
