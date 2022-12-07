pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

import "./base_fixed.sol";

contract DerivedA is Base {

    int internal j = 500;

    function call(int a) public {
        assign1(a);
    }

    function assign3(A memory x) public returns (uint) {
        return g[1] + x.a + uint(j);
    }

    function ret() public returns (int){
        return this.e();

    }

}