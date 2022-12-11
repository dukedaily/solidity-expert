/**
[Specs]
pattern: LockedEtherPattern

# compliant: L0, L1, ...
# violation: L0, L1, ...

 */
contract MarketPlace { // violation
    function deposit() payable public {
    }

    function transfer() payable public {
        uint x = msg.value;
    }
}
