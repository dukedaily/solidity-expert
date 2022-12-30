
/*
 * @source: https://capturetheether.com/challenges/lotteries/guess-the-random-number/
 * @author: Steve Marx
 */

contract GuessTheRandomNumberChallenge {
    uint256 answer;

    constructor() public payable {
        require(msg.value == 1 ether);
        answer = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), now)));
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require(msg.value == 1 ether);

        if (n == answer) {
            msg.sender.transfer(2 ether);
        }
    }
}

