/*
 * @source: ChainSecurity
 * @author: Anton Permenev
 */
contract ConstructorCreateArgument{
    B b = new B(11);

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
}
