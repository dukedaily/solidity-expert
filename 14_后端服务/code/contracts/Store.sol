// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.15;

contract Store {
  event ItemSet(address indexed sender, bytes32 key, bytes32 value);

  string public version;
  mapping (bytes32 => bytes32) public items;

  constructor(string memory _version) {
    version = _version;
  }

  function setItem(bytes32 key, bytes32 value) external {
    items[key] = value;
    emit ItemSet(msg.sender, key, value);
  }
}