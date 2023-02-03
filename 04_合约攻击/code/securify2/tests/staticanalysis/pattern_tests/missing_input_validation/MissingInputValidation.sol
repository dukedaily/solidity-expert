/**
[Specs]
pattern: MissingInputValidationPattern
 */
contract SimpleBank {
    mapping(address => uint) balances;

    function withdraw(uint amount) public { // violation
        balances[msg.sender] -= amount;
        msg.sender.transfer(amount);
    }
}
