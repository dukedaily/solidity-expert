pragma solidity ^0.5.0;

contract Logging {
    event Log(string);
    event Log(uint);
    event Log(string, uint);

    function log(uint i) internal {
        emit Log(i);
    }

    function log(string memory s) internal {
        emit Log(s);
    }

    function logWithInt(string memory s, uint i) internal returns(uint) {
        emit Log(s, i);
        return i;
    }
}

contract A0 is Logging {

    constructor (uint a) public {
        logWithInt("A0", a);
    }

}

contract A1 is Logging {

    constructor (uint a) public {
        logWithInt("A1", a);
    }

}

contract B0 is A0 {

    constructor (uint t) public {
        logWithInt("B0", t);
    }

}

contract B1 is A1, A0  {
    constructor (uint q) A0(logWithInt("increment3", q + 1)) public {
        logWithInt("B1", q);
    }

}

contract C is B0(2), B1 {

    constructor (uint a) B1(logWithInt("increment1", a+=10)) A1(logWithInt("increment2", a+=100))  public {
        logWithInt("C", a);
    }

}

// Insight: incremet1, increment3 and increment2 will be executed before anything else