/* User can add pay in and withdraw Ether.
   Unfortunatelty, the developer was drunk and used the wrong comparison operator in "withdraw()"
   Anybody can withdraw arbitrary amounts of Ether :()
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
        require(amount >= balances[msg.sender]);
        msg.sender.transfer(amount);
        balances[msg.sender] -= amount;
    }

    // In an emergency the owner can migrate  allfunds to a different address.

    function migrateTo(address payable to) public {
        require(creator == msg.sender);
        address(to).transfer(address(this).balance);
    }

}

