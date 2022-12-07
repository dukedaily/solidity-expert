/**
[Specs]
pattern: LockedEtherPattern

# compliant: L0, L1, ...
# violation: L0, L1, ...

 */
pragma solidity ^0.5.0;

contract Test { // compliant

    function payout(address a) public {
        bool x;
        bytes memory y;
        (x, y) = a.delegatecall("0x1234");
    }


    function () external payable {

    }
}
