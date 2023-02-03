/*
 * @source: ChainSecurity
 * @author: Anton Permenev
 * Assert violation with 2 message calls:
 * - B.set_x(X): X != 10
 * - ContructorCreateModifiable.check()
 */

contract ContructorCreateModifiable{
    B b = new B(10);

    function check() public {
        assert(b.foo() == 10);
    }

}

contract B{

    uint x_;
    constructor(uint x) public {
        x_ = x;
    }

    function foo() public returns(uint){
        return x_;
    }

    function set_x(uint x) public {
        x_ = x;
    }
}
