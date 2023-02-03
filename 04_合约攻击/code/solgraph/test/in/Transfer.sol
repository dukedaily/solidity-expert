pragma solidity ^0.4.23;

contract MyContract {
    function Foo() public returns (uint) {
        msg.sender.transfer(address(this).balance);
    }

}
