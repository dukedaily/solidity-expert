contract B {

    event Log(string s);

    modifier MB(uint i) {
        emit Log("START MB");
        _;
        emit Log("END MB");
    }

    constructor () public  MB(log("Params MB")) {
        emit Log("START B");
        emit Log("END B");
    }

    function log(string memory s) public returns (uint) {
        emit Log(s);
        return 1;
    }

}
contract C is B {

    modifier M(uint i) {
        emit Log("START M");
        _;
        emit Log("END M");
    }

    constructor () public M(log("Params M1")) B() M(log("Params M2")) {
        emit Log("START C");
        emit Log("END C");
    }

}