/*
 * @source: https://forum.zeppelin.solutions/t/using-automatic-analysis-tools-with-makerdao-contracts/1021/3
 * Author: Dan Guido / Trail of Bits
 * Slightly modified by Bernhard Mueller

* An assertion violation is possible in 3 transactions:
*
* etch(addr)
* lookup(slate, addr)
* checkAnInvariant()

* Whereby slate == Keccak(addr)
*
* Ideally tools should output the correct transaction trace.
*/

pragma solidity ^0.5.0;

contract ReturnMemory {
    mapping(bytes32=>address) public slates;
    bool everMatched = false;

    function etch(address yay) public returns (bytes32 slate) {
        bytes32 hash = keccak256(abi.encodePacked(yay));
        slates[hash] = yay;
        return hash;
    }

    function lookup(bytes32 slate, address nay) public {
       if (nay != address(0x0)) {
         everMatched = slates[slate] == nay;
       }
    }
    
    function checkAnInvariant() public returns (bool) {
        assert(!everMatched);
    }
}
