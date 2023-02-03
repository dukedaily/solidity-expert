/**
[Specs]
pattern: LockedEtherPattern

# compliant: L0, L1, ...
# violation: L0, L1, ...

 */
library TestLibrary {} // not applicable

contract TestContract {} // violation

contract TestContract1 { // violation
    function notAccessible() private {
        msg.sender.send(4);
    }
}

contract TestContract2 { // compliant
    function notAccessible() public {
        msg.sender.send(4);
    }
}

contract TestContract3 { // violation
    function notAccessible() public {
        msg.sender.send(0);
    }
}

contract TestContract4 { // compliant
    function() external {}
}

contract TestContract5 { // compliant
    function kill() public {
        selfdestruct(address(0));
    }
}