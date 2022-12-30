pragma solidity ^0.5.1;

contract Logging {
    event Log(string);
    event Log(uint);

    function log(uint i) internal {
        emit Log(i);
    }

    function log(string memory s) internal {
        emit Log(s);
    }

    function logWithInt(string memory s, uint i) internal returns(uint) {
        emit Log(s);
        return i;
    }
}

contract A is Logging{
    uint state = 2;

    constructor () public {
        state = 5;
    }
}

contract B is A {
    uint state2 = state; // 2

    constructor () public {
        log(state);   // 5
        log(state2);  // 2
    }

}

// Note: state variables of the whole inheritance
//       hierarchy will be initialized before any
//       constructor is executed.