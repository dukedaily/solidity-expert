// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

contract Test{
    uint totalSupply = 1e18;
    mapping(address => uint) balance;
    event TransferTo(address to,uint value);

    constructor() {
        balance[msg.sender] = totalSupply;
    }

    function transferTo(address _to,uint _value) public {
        balance[msg.sender] -= _value;
        balance[_to] += _value;
        emit TransferTo(_to,_value);
    }

    function BalanceOf(address _owner) public view  returns(uint){
        return balance[_owner];
    }
}