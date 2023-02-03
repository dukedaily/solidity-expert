/* User can add pay in and withdraw Ether.
   Unfortunately the developer forgot set the user's balance to 0 when refund() is called.
   An attacker can pay in a small amount of Ether and call refund() repeatedly to empty the contract.
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
    }

    // In an emergency the owner can migrate  allfunds to a different address.

    function migrateTo(address payable to) public {
        require(creator == msg.sender);
        to.transfer(address(this).balance);
    }

}
