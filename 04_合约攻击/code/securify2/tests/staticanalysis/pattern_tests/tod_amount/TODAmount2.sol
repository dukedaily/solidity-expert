/**
[Specs]
pattern: TODAmountPattern

 */
contract TokenMarket {
    mapping(address => uint) balances;
    uint price = 10;
    address owner;

    function resetOwner() public {
        if (msg.sender == owner)
            owner = address (0);
    }

    function sellTokens() public {
        if (msg.sender == owner)
            msg.sender.transfer(10); // compliant
    }
}
