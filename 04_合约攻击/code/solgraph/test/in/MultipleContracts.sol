pragma solidity ^0.4.23;

contract ContractOne {
    uint constant someVal = 1;

    function functionOne() public pure returns (uint) {
        return someVal;
    }
}

contract ContractTwo {
    uint someVal;

    function functionTwo() public payable returns (uint) {
        someVal = msg.value;
    }
}


contract ContractThree {
    uint someVal = 3;

    event anEvent();
    function functionThree() public returns (uint) {
        msg.sender.transfer(address(this).balance);
        emit anEvent();
        return someVal;
    }

}
