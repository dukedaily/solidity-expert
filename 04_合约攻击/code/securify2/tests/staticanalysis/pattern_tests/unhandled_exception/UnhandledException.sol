/**
[Specs]
pattern: UnhandledExceptionPattern

# compliant: L0, L1, ...
# violation: L0, L1, ...

 */
contract SimpleBank {
    mapping(address => uint) balances;

    function withdraw() public {
        msg.sender.send(balances[msg.sender]); // violation
        balances[msg.sender] = 0;
    }
}
