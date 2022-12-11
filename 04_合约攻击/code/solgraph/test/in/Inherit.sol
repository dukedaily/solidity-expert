pragma solidity ^0.4.23;

import "./imports/issue14_parent.sol";

contract ChildContract is ParentContract{

    function someFunction() public {
        emit anEvent(msg.sender);
    }

}
