/*
 * @source: TrailofBits workshop at TruffleCon 2018
 * @author: Josselin Feist (adapted for SWC by Bernhard Mueller)
 * Assert violation with 3 message calls:
 * - airdrop()
 * - backdoor() 
 * - test_invariants()
 */


contract Token{

    mapping(address => uint) public balances;
    function airdrop() public{
        balances[msg.sender] = 1000;
    }

    function consume() public{ 
        require(balances[msg.sender]>0);
        balances[msg.sender] -= 1;
    }

    function backdoor() public{
        balances[msg.sender] += 1;
    }
 
   function test_invariants() public {
      assert(balances[msg.sender] <= 1000);
  }
}
