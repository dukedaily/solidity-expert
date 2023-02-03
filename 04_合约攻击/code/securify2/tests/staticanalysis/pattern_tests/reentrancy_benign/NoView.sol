/**
[Specs]
pattern: ReentrancyBenignPattern
 */

contract A {
    uint public x;

    function foo() external returns (int){
        return 1;
    }
}

contract View {
    uint public x;

    function foo() external view returns (int){
        return 1;
    }
}

contract B {

    A a;
    View v;
    uint y;

    function f() external {
        a.foo(); // violation
        v.foo();
        y = 10;
    }
}