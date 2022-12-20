/**
[Specs]
pattern: TODTransferPattern

 */
contract Game {
    bool won = false;

    function play(bytes memory guess) public {
        require(!won);
        if (uint(keccak256(guess)) == 0xDEADBEEF) {
            won = true;
            msg.sender.transfer(10 ** 18); // violation
        }
    }
}
