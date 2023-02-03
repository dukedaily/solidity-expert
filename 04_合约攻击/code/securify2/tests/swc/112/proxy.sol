contract Proxy {

  address owner;

  constructor() public {
    owner = msg.sender;  
  }

  function forward(address callee, bytes memory _data) public {
    bool flag;
    (flag,) = callee.delegatecall(_data);
    require(flag);
  }

}
