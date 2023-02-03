/**
[Specs]
pattern: ConstableStatesPattern
 */

contract Test{

    uint a; //compliant
    uint b; //violation
    uint constant c = 3;
    mapping (address => uint32) test;

    function simple() public{
        a = 3;
    }

    function shadow() public view{
        uint b;
        b = 0;
    }

    function just_var() public view{
        b;
    }
}

