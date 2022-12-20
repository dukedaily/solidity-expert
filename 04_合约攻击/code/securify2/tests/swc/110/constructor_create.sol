/*
 * @source: ChainSecurity
 * @author: Anton Permenev
 */

contract ConstructorCreate{
    B b = new B();

    function check() public {
        assert(b.foo() == 10);
    }

}

contract B{

    function foo() public returns(uint){
        return 11;
    }
}
