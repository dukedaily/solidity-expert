/**
[Specs]
pattern: ShadowedStateVariablePattern
 */
pragma solidity ^0.5.0;

contract B {
    address owner; // compliant
}

contract C is B {
    address owner; // violation

    address owner1; // compliant
}