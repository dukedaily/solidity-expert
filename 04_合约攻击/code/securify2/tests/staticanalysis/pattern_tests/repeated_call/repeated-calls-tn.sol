/**
[Specs]
pattern: RepeatedCallPattern
 */
interface A {
    function f() external view returns(address);
}

contract B {
    mapping(address => bool) approved;
    function g(A a) public {
        require(approved[(address(a.f()))]); // compliant
    }
}
