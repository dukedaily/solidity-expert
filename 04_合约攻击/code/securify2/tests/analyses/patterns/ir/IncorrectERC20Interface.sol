/**
[TestInfo]
pattern: IncorrectERC20InterfacePattern

 */
pragma solidity ^0.5.0;

contract ContractNotApplicable {
    function transfer(uint value) external {}
}

contract TokenCompliant {// compliant
    function transfer(address to, uint value) external returns (bool) {return true;}

    function approve(address spender, uint value) external returns (bool) {return true;}

    function transferFrom(address from, address to, uint value) external returns (bool) {return true;}

    function totalSupply() external returns (uint256) {return 0;}

    function balanceOf(address who) external returns (uint256) {return 0;}

    function allowance(address owner, address spender) external returns (uint256) {return 0;}
}

contract TokenViolation { // violation
    function transfer(address to, uint value) external {} // incorrect return signature

    function approve(address spender, uint value) external returns (bool) {return true;}

    function transferFrom(address from, address to, uint value) external returns (bool) {return true;}

    function totalSupply() external returns (uint256) {return 0;}

    function balanceOf(address who) external returns (uint256) {return 0;}

    function allowance(address owner, address spender) external {} // incorrect return signature
}