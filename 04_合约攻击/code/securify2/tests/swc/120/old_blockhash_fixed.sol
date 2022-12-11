//Based on the the Capture the Ether challange at https://capturetheether.com/challenges/lotteries/predict-the-block-hash/
//Note that while it seems to have a 1/2^256 chance you guess the right hash, actually blockhash returns zero for blocks numbers that are more than 256 blocks ago so you can guess zero and wait.
contract PredictTheBlockHashChallenge {

    struct guess{
      uint block;
      bytes32 guess;
    }

    mapping(address => guess) guesses;

    constructor() public payable {
        require(msg.value == 1 ether);
    }

    function lockInGuess(bytes32 hash) public payable {
        require(guesses[msg.sender].block == 0);
        require(msg.value == 1 ether);

        guesses[msg.sender].guess = hash;
        guesses[msg.sender].block  = block.number + 1;
    }

    function settle() public {
        require(block.number > guesses[msg.sender].block +10);
        //Note that this solution prevents the attack where blockhash(guesses[msg.sender].block) is zero
        //Also we add ten block cooldown period so that a minner cannot use foreknowlege of next blockhashes
        if(guesses[msg.sender].block - block.number < 256){
          bytes32 answer = blockhash(guesses[msg.sender].block);

          guesses[msg.sender].block = 0;
          if (guesses[msg.sender].guess == answer) {
              msg.sender.transfer(2 ether);
          }
        }
        else{
          revert("Sorry your lottery ticket has expired");
        }
    }
}

