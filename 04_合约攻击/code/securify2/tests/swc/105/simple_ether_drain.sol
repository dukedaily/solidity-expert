contract SimpleEtherDrain {

  function withdrawAllAnyone() public {
    msg.sender.transfer(address(this).balance);
  }

  function () external payable {
  }

}

