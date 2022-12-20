/*
 * @source: https://github.com/trailofbits/not-so-smart-contracts/blob/master/wrong_constructor_name/incorrect_constructor.sol
 * @author: Ben Perez
 * Modified by Gerhard Wagner
 */

contract Missing{
    address payable private owner;

    modifier onlyowner {
        require(msg.sender==owner);
        _;
    }
    
    function missing()
        public 
    {
        owner = msg.sender;
    }

    function () external payable {}

    function withdraw() 
        public 
        onlyowner
    {
       owner.transfer(address(this).balance);
    }
}

