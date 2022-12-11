/*
 * @source: https://consensys.github.io/smart-contract-best-practices/recommendations/#avoid-using-txorigin
 * @author: Consensys Diligence  
 * Modified by Gerhard Wagner
 */

contract MyContract {

    address owner;

    constructor() public {
        owner = msg.sender;
    }

    function sendTo(address payable receiver, uint amount) public {
        require(tx.origin == owner);
        receiver.transfer(amount);
    }

}
