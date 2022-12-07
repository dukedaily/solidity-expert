/* User can add pay in and withdraw Ether.
   The constructor is wrongly named, so anyone can become 'creator' and withdraw all funds.
*/

contract Wallet {
    address creator;
    
    mapping(address => uint256) balances;

    function initWallet() public {
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

    // In an emergency the owner can migrate  allfunds to a different address.

    function migrateTo(address payable to) public {
        require(creator == msg.sender);
        to.transfer(address(this).balance);
    }

}

