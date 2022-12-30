pragma solidity ^0.5.2;

contract Base {
    uint _val;

    constructor (uint v) public {
        _val = v;
    }
}

contract C is Base {
    constructor (uint v) public Base(v+1) {
      v+=1;
    }
}