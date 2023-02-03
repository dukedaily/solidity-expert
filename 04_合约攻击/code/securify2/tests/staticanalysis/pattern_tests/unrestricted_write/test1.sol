/**
[Specs]
pattern: UnrestrictedWritePattern

# compliant: L0, L1, ...
# violation: L0, L1, ...

 */
contract TestContract {
    address owner;

    uint a;
    uint b;

    function main(uint v) public {
        a = v; // violation

        if (msg.sender == owner)
            a = v; // compliant

        storeUsedNonCompliantly(v);
    }

    function test(uint v) public {
        require(msg.sender == owner);
        a = v; // compliant
        storeUsedCompliantly(v);
    }

    function storeUsedCompliantly(uint v) private {
        a = v; // compliant
    }

    function storeUsedNonCompliantly(uint v) private {
        a = v; // violation
    }
}