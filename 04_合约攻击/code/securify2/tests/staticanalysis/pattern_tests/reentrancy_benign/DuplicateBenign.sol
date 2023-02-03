/**
[Specs]
pattern: ReentrancyBenignPattern
 */

contract A {
    function g() external{

    }
}


contract B {

    A a;
    uint y;

    modifier mod {
        a.g(); //warning
        _;
    }

    function f() mod external {
        y = 10;
    }

    function h() mod external {
        y = 11;
    }

}