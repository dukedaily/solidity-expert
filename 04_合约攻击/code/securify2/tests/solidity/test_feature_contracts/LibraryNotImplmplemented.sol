
library MiMC {
  function MiMCSponge(uint256 in_xL, uint256 in_xR, uint256 in_k) public pure returns (uint256 xL, uint256 xR);
}

contract MerkleTreeWithHistory {
  uint256 public levels;

  uint8 constant ROOT_HISTORY_SIZE = 100;
  uint256[] private _roots;
  uint256 public current_root = 0;

  uint256[] private _filled_subtrees;
  uint256[] private _zeros;

  uint32 public next_index = 0;


  function hashLeftRight(uint256 left, uint256 right) public pure returns (uint256 mimc_hash) {
    uint256 k = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 R = 0;
    uint256 C = 0;

    R = addmod(R, left, k);
    (R, C) = MiMC.MiMCSponge(R, C, 0);

    R = addmod(R, right, k);
    (R, C) = MiMC.MiMCSponge(R, C, 0);

    mimc_hash = R;
  }

}

