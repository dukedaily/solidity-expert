/**
[Specs]
pattern: DAOConstantGasPattern
 */
contract Wallet {

  uint balance;
  function send() public {
    if (balance > 0){
      msg.sender.transfer(balance); // violation
      balance = 0;
    }
  }
}
