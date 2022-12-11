contract ReturnValue {

  function callchecked(address callee) public {
    bool flag;
    (flag,) = callee.call("");
    require(flag);
  }

  function callnotchecked(address callee) public {
    callee.call("");
  }
}

