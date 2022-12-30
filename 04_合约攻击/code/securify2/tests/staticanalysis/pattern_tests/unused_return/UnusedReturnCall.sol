/**
[Specs]
pattern: UnusedReturnPattern
 */

contract Test{
    function f() public returns(uint) {
        return 1;
    }

    function b(uint a) public returns(uint) {
        return a;
    }
}

contract Target{

    Test t;

    function test() external{
       //uint a;
       //a = t.f();
       t.b(t.f());
    }
}
