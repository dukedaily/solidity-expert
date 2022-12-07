pragma solidity ^0.4.25;

contract TypoOneCommand {
    uint numberOne = 1;

    function alwaysOne() public {
        numberOne =+ 1;
    }
}
