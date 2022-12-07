contract Logging {
    event Log(string);
    event Log(uint);

    function log(uint i) internal {
        emit Log(i);
    }

    function log(string memory s) internal {
        emit Log(s);
    }

    function logWithInt(string memory s, uint i) internal returns (uint) {
        emit Log(s);
        return i;
    }
}

contract B is Logging {

    modifier MB(uint i) {
        log("START MB");
        _;
        log("END MB");
    }

    constructor (uint a) public  MB(logWithInt("Params MB", 1)) {
        log("START B");
        state += a;
        log("END B");
    }

    uint state;
}

contract C is B {

    modifier M(uint i) {
        log("START M");
        _;
        log("END M");
    }

    // Note that B(test += 30 is executed before the other modifiers!)
    constructor (uint test) public M(logWithInt("Params M1", test += 100)) B(test += 30) M(logWithInt("Params M2", 20)) {
        log(test); // 130
        log(state); // 30
        log("START C");
        log("END C");
    }

}