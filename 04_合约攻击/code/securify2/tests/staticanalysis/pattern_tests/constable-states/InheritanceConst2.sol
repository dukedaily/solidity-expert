/**
[Specs]
pattern: ConstableStatesPattern
 */

contract Test{
    uint a; //violation
}

contract NewTest is Test{
    uint a; //compliant
    function foo() public {
        a = 3;
    }
}

