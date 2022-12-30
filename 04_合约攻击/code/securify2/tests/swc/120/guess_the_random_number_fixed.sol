/*
 * @source: https://capturetheether.com/challenges/lotteries/guess-the-random-number/
 * @author: Steve Marx
 */

contract GuessTheRandomNumberChallenge {
    uint8 answer;
    uint8 commitedGuess;
    uint commitBlock;
    address guesser;

    constructor() public payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    //Guess the modulo of the blockhash 20 blocks from your guess
    function guess(uint8 _guess) public payable {
        require(msg.value == 1 ether);
        commitedGuess = _guess;
        commitBlock = block.number;
        guesser = msg.sender;
    }
    function recover() public {
      //This must be called after the guessed block and before commitBlock+20's blockhash is unrecoverable
      require(block.number > commitBlock + 20 && commitBlock+20 > block.number - 256);
      require(guesser == msg.sender);

      if(uint(blockhash(commitBlock+20)) == commitedGuess){
        msg.sender.transfer(2 ether);
      }
    }
}
