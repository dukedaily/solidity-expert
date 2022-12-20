contract SimpleSuicide {

  function sudicideAnyone() public {
    selfdestruct(msg.sender);
  }

}

