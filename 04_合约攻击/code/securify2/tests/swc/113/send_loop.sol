/*
 * @source: https://consensys.github.io/smart-contract-best-practices/known_attacks/#dos-with-unexpected-revert
 * @author: ConsenSys Diligence
 * Modified by Bernhard Mueller
 */

contract Refunder {
    
address payable[] private refundAddresses;
mapping (address => uint) public refunds;

    constructor() public {
        refundAddresses.push(address(0x79B483371E87d664cd39491b5F06250165e4b184));
        refundAddresses.push(address(0x0079B483371E87d664cd39491b5F06250165e4b185));
    }

    // bad
    function refundAll() public {
        for(uint x; x < refundAddresses.length; x++) { // arbitrary length iteration based on how many addresses participated
            require(refundAddresses[x].send(refunds[refundAddresses[x]])); // doubly bad, now a single failure on send will hold up all funds
        }
    }

}

