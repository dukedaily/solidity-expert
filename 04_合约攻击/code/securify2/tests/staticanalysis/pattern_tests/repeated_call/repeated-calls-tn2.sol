/**
[Specs]
pattern: RepeatedCallPattern
 */
interface A {
    function f() external view returns(address);
}

contract B {
    mapping(address => bool) approved;
    mapping(address => bool) modified;
    function g(A a) public {
        require(approved[(address(a.f()))]); // compliant
    }
    function h(A a) public {
        modified[(address(a.f()))] = true; // compliant
    }
}
