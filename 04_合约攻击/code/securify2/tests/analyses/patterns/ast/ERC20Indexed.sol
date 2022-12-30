/**
[TestInfo]
pattern: ERC20IndexedPattern
*/
contract IERC20Good {
    function transfer(address to, uint value) external returns (bool);
    function approve(address spender, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function totalSupply() external view returns (uint);
    function balanceOf(address who) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    event Transfer(address indexed from, address indexed to, uint value); // compliant
    event Approval(address indexed owner, address indexed spender, uint value); // compliant
}

contract IERC20Bad { 
    function transfer(address to, uint value) external returns (bool);
    function approve(address spender, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function totalSupply() external view returns (uint);
    function balanceOf(address who) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    event Transfer(address from, address to, uint value); //violation
    event Approval(address owner, address indexed spender, uint value); //violation
}

contract ERC20BadDerived is IERC20Bad {}