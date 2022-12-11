/**
[TestInfo]
pattern: AssemblyUsagePattern

 */

pragma solidity ^0.5.4;

contract AssemblyUsage {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {// violation
            size := extcodesize(account)
        }
        return size > 0;
    }
}

