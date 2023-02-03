pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

import "./base.sol";

contract DerivedA is Base {
    // i is not used in the current contract
    A i = A(1);

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