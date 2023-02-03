/**
[Specs]
pattern: ConstableStatesPattern
 */

contract Test{
    uint a; // compliant
}

contract NewTest is Test{
    function foo() public {
        a = 3;
    }
}

