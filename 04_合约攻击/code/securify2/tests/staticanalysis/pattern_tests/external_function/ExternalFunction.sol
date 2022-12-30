/**
[Specs]
pattern: ExternalFunctionPattern
*/

contract ExternalFunctions {

    function set_test1() external {
    }

    function set_test2() external {
    }

    function test1() public returns (uint){ // violation
        return 1;
    }

    function test2() public returns (uint){ // compliant
        return 2;
    }

    function test3() public returns (uint){ // violation
        test2();
        return 3;
    }

    function exec() external {
    }
}

contract OtherContract{
    ExternalFunctions t;

    function foo(ExternalFunctions t) external {
        t.test1();
    }

}



