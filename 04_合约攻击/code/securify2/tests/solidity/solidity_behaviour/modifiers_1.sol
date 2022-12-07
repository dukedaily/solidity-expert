pragma solidity ^0.5.1;

contract C {
    event Log(string);

    modifier M1(uint i) {
        emit Log("M1 Start");
        i *= 3;
        _;
        emit Log("M1 End");
    }

    modifier M2(uint i) {
        emit Log("M2 Start");
        i *= 5;
        _;
        emit Log("M2 End");
    }


    modifier M2N(uint i) {
        emit Log("M2N Start");
        i *= 5;
        if (i == 100000) {
            _;
        }
        emit Log("M2N End");
    }

    modifier M3() {
        _;
        _;
    }

    function add1(uint a) private returns (uint) {
        emit Log("Add1");
        return a + 1;
    }

    function mul2(uint a) private returns (uint) {
        emit Log("Mul2");
        return a * 2;
    }

    // Modifiers are nested from left to right (i.e. most nested level is on the right side)
    // Parameters are evaluated from left to right
    function foo1(uint p) public M1(p = add1(p)) M2(p = mul2(p)) returns (uint) {
        return p;
    }

    // The actual function can be skipped
    function foo2(uint p) public M1(++p) M2N(p *= 2) returns (uint) {
        emit Log("Function Executed");
        return p;
    }

    // Return values are only initialized once, regardless of placeholders
    function foo3() public M3() returns (uint r) {
        r += 4;
    }

    // Return values are only initialized once, regardless of the number of modifiers
    function foo4() public M3() M3() returns (uint r) {
        r += 4;
    }

    // Parameter values are only initialized once, regardless of placeholders or modifier invocations
    function foo5(uint r) public M1(r += 10) M3() returns (uint) {
        r += 4;
        return r;
    }
}