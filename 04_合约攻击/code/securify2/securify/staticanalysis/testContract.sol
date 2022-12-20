pragma solidity ^0.5.4;

contract UnrestrictedDelegateCall2 {
    address callee;
    address owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        callee = address(0x0);
        owner = msg.sender;
    }

    function setCallee(address newCallee) public onlyOwner {
        callee = newCallee;
    }

    function forward(bytes memory _data) public {
        callee.delegatecall(_data);
    }
}

