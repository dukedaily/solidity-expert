/*
 * @source: ChainSecurity
 * @author: Anton Permenev
 */
contract RuntimeUserInputCall{

    function check(address b) public {
        assert(B(b).foo() == 10);
    }

}

contract B{
    function foo() public returns(uint);
}
