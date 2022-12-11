/**
[Specs]
pattern: TODAmountPattern

 */
contract TokenMarket {
    mapping(address => uint) balances;
    uint price = 10;
    address owner;

    function setPrice(uint newPrice) public {
        if (msg.sender == owner)
        price = newPrice;
    }

    function sellTokens() public {
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(amount * price); // violation
    }
}
