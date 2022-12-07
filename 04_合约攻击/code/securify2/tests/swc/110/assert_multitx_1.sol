/*
 * @source: https://github.com/ConsenSys/evm-analyzer-benchmark-suite
 * @author: Suhabe Bugrara
 */

contract AssertMultiTx1 {
    uint256 private param;

    constructor(uint256 _param) public {
        require(_param > 0);
        param = _param;
    }

    function run() public {
        assert(param > 0);
    }

}
