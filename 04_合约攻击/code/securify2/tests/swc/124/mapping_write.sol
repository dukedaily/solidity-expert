//This code is derived from the Capture the Ether https://capturetheether.com/challenges/math/mapping/

contract Map {
    address public owner;
    uint256[] map;

    function set(uint256 key, uint256 value) public {
        if (map.length <= key) {
            map.length = key + 1;
        }

        map[key] = value;
    }

    function get(uint256 key) public view returns (uint256) {
        return map[key];
    }
    function withdraw() public{
      require(msg.sender == owner);
      msg.sender.transfer(address(this).balance);
    }
}

