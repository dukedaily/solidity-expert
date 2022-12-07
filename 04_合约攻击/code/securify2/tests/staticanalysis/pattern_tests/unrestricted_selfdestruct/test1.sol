/**
[Specs]
pattern: UnrestrictedSelfdestructPattern

# compliant: L0, L1, ...
# violation: L0, L1, ...

 */
contract TestContract {
    address owner;

    function main(uint v) public {
        if (msg.sender == owner)
            selfdestruct(msg.sender); // compliant
    }

    function main2() public {
        selfdestruct(msg.sender); // violation
    }

    function main3() public {
        if (msg.sender == owner){

        } else {

        }

        selfdestructUsedNonCompliantly(1);
    }

    function test(uint v) public {
        require(msg.sender == owner);
        if (true) {

            selfdestruct(address(0)); // compliant
        }
        selfdestructUsedCompliantly(v);
    }

    function selfdestructUsedCompliantly(uint v) private {
        selfdestruct(address(0)); // compliant
    }

    function selfdestructUsedNonCompliantly(uint v) private {
        selfdestruct(address (0)); // violation
    }
}