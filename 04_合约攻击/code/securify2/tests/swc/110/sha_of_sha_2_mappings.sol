/*
 * @source: ChainSecurity
 * @author: Anton Permenev
 */
contract ShaOfSha2Mappings{

    mapping(bytes32=>uint) m;
    mapping(bytes32=>uint) n;

    constructor() public {
        m[keccak256(abi.encode("AAA", msg.sender))] = 100;
    }

    function check(address a) public {
        assert(n[keccak256(abi.encode("BBB", a))] == 0);
    }

}
