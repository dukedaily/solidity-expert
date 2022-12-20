/**
[Specs]
pattern: UnusedReturnPattern
 */

library SafeMath{
    function add(uint a, uint b) public returns(uint){
        return a+b;
    }
}

contract Target{
    function f() public returns(uint);
    function always_true() public returns(bool){
        return true;
    }
}



contract User{

    using SafeMath for uint;

    function test(Target t) public{
        uint i = t.f(); // compliant

        // example with library usage
        uint a;
        a.add(0); // violation

        // The value is not used
        // But the detector should not detect it
        // As the value returned by the call is stored
        // (unused local variable should be another issue)
        uint b = a.add(1); // compliant
    }

    function require_test(Target t) public{
        //usage in require statement
        uint a = 0;
        require(t.always_true()); // compliant
        require(a.add(0)>0); // compliant
    }
}