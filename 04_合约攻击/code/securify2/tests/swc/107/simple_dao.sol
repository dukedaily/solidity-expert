/*
 * @source: http://blockchain.unica.it/projects/ethereum-survey/attacks.html#simpledao
 * @author: Atzei N., Bartoletti M., Cimoli T
 * Modified by Josselin Feist
 */
contract SimpleDAO {
  mapping (address => uint) public credit;
    
  function donate(address to) payable public{
    credit[to] += msg.value;
  }
    
  function withdraw(uint amount) public{
    if (credit[msg.sender]>= amount) {
    bool flag;
    (flag,) = msg.sender.call.value(amount)("");
    require(flag);
    credit[msg.sender]-=amount;
    }
  }  

  function queryCredit(address to) view public returns(uint){
    return credit[to];
  }
}

