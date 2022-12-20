/**
[Specs]
pattern: UnrestrictedEtherFlowPattern

# compliant: L0, L1, ...
# violation: L0, L1, ...

 */
contract TestContract {
    address owner;

    function main(uint v) public {
        msg.sender.send(5); // violation

        if (msg.sender == owner)
            msg.sender.send(5); // compliant

        storeUsedNonCompliantly(v);
    }

    function test(uint v) public {
        require(msg.sender == owner);
        msg.sender.send(5); // compliant
        storeUsedCompliantly(v);
    }

    function storeUsedCompliantly(uint v) private {
        msg.sender.send(5); // compliant
    }

    function storeUsedNonCompliantly(uint v) private {
        msg.sender.send(5); // violation
    }
}