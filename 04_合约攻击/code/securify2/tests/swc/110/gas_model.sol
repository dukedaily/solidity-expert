/*
 * @source: ChainSecurity
 * @author: Anton Permenev
 */
contract GasModel{
    uint x = 100;
    function check() public{
        uint a = gasleft();
        x = x + 1;
        uint b = gasleft();
        assert(b > a);
    }
}
