/**
[Specs]
pattern: UnrestrictedWritePattern

# compliant: L0, L1, ...
# violation: L0, L1, ...

 */
contract Ownable {
    address owner;

    function transferOwnership(address _newOwner) public {
        owner = _newOwner; // violation
    }
}
