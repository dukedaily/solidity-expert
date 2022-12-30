pragma solidity 0.4.25;

//We fix the problem by eliminating the declaration which overrides the prefered hardcap.

contract Tokensale {
    uint public hardcap = 10000 ether;

    function Tokensale() {}

    function fetchCap() public constant returns(uint) {
        return hardcap;
    }
}

contract Presale is Tokensale {
    //uint hardcap = 1000 ether;
    //If the hardcap variables were both needed we would have to rename one to fix this.
    function Presale() Tokensale() {
        hardcap = 1000 ether; //We set the hardcap from the constructor for the Tokensale to be 1000 instead of 10000
    }
}
