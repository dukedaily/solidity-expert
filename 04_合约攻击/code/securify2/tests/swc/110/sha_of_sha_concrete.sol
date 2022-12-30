/*
 * @source: ChainSecurity
 * @author: Anton Permenev
 */

contract ShaOfShaConcrete{

    mapping(bytes32=>uint) m;
    uint b;

    constructor() public {
        b = 1;
    }

    function check(uint x) public {
        assert(m[keccak256(abi.encodePacked(x, "B"))] == 0);
    }

}
