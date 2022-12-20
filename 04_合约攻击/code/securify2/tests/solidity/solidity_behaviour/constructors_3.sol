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

contract A0 is Logging {

    constructor (uint a) public {
        log("A0");
    }

}

contract A1 is Logging {

    constructor (uint a) public {
        log("A1");
    }

}

contract B0 is A0 {

    constructor (uint t) public {
        log("B0");
    }

}

contract B1 is A1 {

    constructor () public {
        log("B1");
    }

}

contract C is A0(1), B0(2), B1 {

    constructor () A1(2) public {
        log("C");
    }

}