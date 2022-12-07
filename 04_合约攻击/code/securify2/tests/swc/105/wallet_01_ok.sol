pragma solidity ^0.4.24;

/* User can add pay in and withdraw Ether.
   Nobody can withdraw more Ether than they paid in.
*/

contract Wallet {
    address creator;
    
    mapping(address => uint256) balances;

    constructor() public {
        creator = msg.sender;
    }

    function deposit() public payable {
        assert(balances[msg.sender] + msg.value > balances[msg.sender]);
        balances[msg.sender] += msg.value;
    }
    
    function withdraw(uint256 amount) public {
        require(amount <= balances[msg.sender]);
        msg.sender.transfer(amount);
        balances[msg.sender] -= amount;
    }

    function refund() public {
        msg.sender.transfer(balances[msg.sender]);
        balances[msg.sender] = 0;
    }

    // In an emergency the owner can migrate  allfunds to a different address.

    function migrateTo(address to) public {
        require(creator == msg.sender);
        to.transfer(this.balance);
    }

}
