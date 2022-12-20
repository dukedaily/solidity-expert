
// File: contracts/MerkleTreeWithHistory.sol

// https://tornado.cash
/*
* d888888P                                           dP              a88888b.                   dP
*    88                                              88             d8'   `88                   88
*    88    .d8888b. 88d888b. 88d888b. .d8888b. .d888b88 .d8888b.    88        .d8888b. .d8888b. 88d888b.
*    88    88'  `88 88'  `88 88'  `88 88'  `88 88'  `88 88'  `88    88        88'  `88 Y8ooooo. 88'  `88
*    88    88.  .88 88       88    88 88.  .88 88.  .88 88.  .88 dP Y8.   .88 88.  .88       88 88    88
*    dP    `88888P' dP       dP    dP `88888P8 `88888P8 `88888P' 88  Y88888P' `88888P8 `88888P' dP    dP
* ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
*/


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

  constructor(uint256 tree_levels, uint256 zero_value) public {
    levels = tree_levels;

    _zeros.push(zero_value);
    _filled_subtrees.push(_zeros[0]);

    for (uint8 i = 1; i < levels; i++) {
      _zeros.push(hashLeftRight(_zeros[i-1], _zeros[i-1]));
      _filled_subtrees.push(_zeros[i]);
    }

    _roots = new uint256[](ROOT_HISTORY_SIZE);
    _roots[0] = hashLeftRight(_zeros[levels - 1], _zeros[levels - 1]);
  }

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

  function _insert(uint256 leaf) internal {
    uint32 current_index = next_index;
    require(current_index != 2**levels, "Merkle tree is full. No more leafs can be added");
    next_index += 1;
    uint256 current_level_hash = leaf;
    uint256 left;
    uint256 right;

    for (uint256 i = 0; i < levels; i++) {
      if (current_index % 2 == 0) {
        left = current_level_hash;
        right = _zeros[i];

        _filled_subtrees[i] = current_level_hash;
      } else {
        left = _filled_subtrees[i];
        right = current_level_hash;
      }

      current_level_hash = hashLeftRight(left, right);

      current_index /= 2;
    }

    current_root = (current_root + 1) % ROOT_HISTORY_SIZE;
    _roots[current_root] = current_level_hash;
  }

  function isKnownRoot(uint256 root) public view returns(bool) {
    if (root == 0) {
      return false;
    }
    // search most recent first
    uint256 i;
    for(i = current_root; i < 2**256 - 1; i--) {
      if (root == _roots[i]) {
        return true;
      }
    }

    // process the rest of roots
    for(i = ROOT_HISTORY_SIZE - 1; i > current_root; i--) {
      if (root == _roots[i]) {
        return true;
      }
    }
    return false;

    // or we can do that in other way
    //   uint256 i = _current_root;
    //   do {
    //       if (root == _roots[i]) {
    //           return true;
    //       }
    //       if (i == 0) {
    //           i = ROOT_HISTORY_SIZE;
    //       }
    //       i--;
    //   } while (i != _current_root);
  }

  function getLastRoot() public view returns(uint256) {
    return _roots[current_root];
  }

  function roots() public view returns(uint256[] memory) {
    return _roots;
  }

  function filled_subtrees() public view returns(uint256[] memory) {
    return _filled_subtrees;
  }

  function zeros() public view returns(uint256[] memory) {
    return _zeros;
  }
}

// File: contracts/Mixer.sol

// https://tornado.cash
/*
* d888888P                                           dP              a88888b.                   dP
*    88                                              88             d8'   `88                   88
*    88    .d8888b. 88d888b. 88d888b. .d8888b. .d888b88 .d8888b.    88        .d8888b. .d8888b. 88d888b.
*    88    88'  `88 88'  `88 88'  `88 88'  `88 88'  `88 88'  `88    88        88'  `88 Y8ooooo. 88'  `88
*    88    88.  .88 88       88    88 88.  .88 88.  .88 88.  .88 dP Y8.   .88 88.  .88       88 88    88
*    dP    `88888P' dP       dP    dP `88888P8 `88888P8 `88888P' 88  Y88888P' `88888P8 `88888P' dP    dP
* ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
*/



contract IVerifier {
  function verifyProof(uint256[2] memory a, uint256[2][2] memory b, uint256[2] memory c, uint256[5] memory input) public returns(bool);
}

contract Mixer is MerkleTreeWithHistory {
  bool public isDepositsEnabled = true;
  // operator can disable new deposits in case of emergency
  // it also receives a relayer fee
  address payable public operator;
  mapping(uint256 => bool) public nullifierHashes;
  // we store all commitments just to prevent accidental deposits with the same commitment
  mapping(uint256 => bool) public commitments;
  IVerifier public verifier;
  uint256 public mixDenomination;

  event Deposit(uint256 indexed commitment, uint256 leafIndex, uint256 timestamp);
  event Withdraw(address to, uint256 nullifierHash, address indexed relayer, uint256 fee);

  /**
    @dev The constructor
    @param _verifier the address of SNARK verifier for this contract
    @param _merkleTreeHeight the height of deposits' Merkle Tree
    @param _emptyElement default element of the deposits' Merkle Tree
    @param _operator operator address (see operator above)
  */
  constructor(
    address _verifier,
    uint256 _mixDenomination,
    uint8 _merkleTreeHeight,
    uint256 _emptyElement,
    address payable _operator
  ) MerkleTreeWithHistory(_merkleTreeHeight, _emptyElement) public {
    verifier = IVerifier(_verifier);
    operator = _operator;
    mixDenomination = _mixDenomination;
  }
  /**
    @dev Deposit funds into mixer. The caller must send value equal to `mixDenomination` of this mixer.
    @param commitment the note commitment, which is PedersenHash(nullifier + secret)
  */
  /**
    @dev Deposit funds into the mixer. The caller must send ETH value equal to `userEther` of this mixer.
    The caller also has to have at least `mixDenomination` amount approved for the mixer.
    @param commitment the note commitment, which is PedersenHash(nullifier + secret)
  */
  function deposit(uint256 commitment) public payable {
    require(isDepositsEnabled, "deposits disabled");
    require(!commitments[commitment], "The commitment has been submitted");
    _processDeposit();
    _insert(commitment);
    commitments[commitment] = true;

    emit Deposit(commitment, next_index - 1, block.timestamp);
  }
  /**
    @dev Withdraw deposit from the mixer. `a`, `b`, and `c` are zkSNARK proof data, and input is an array of circuit public inputs
    `input` array consists of:
      - merkle root of all deposits in the mixer
      - hash of unique deposit nullifier to prevent double spends
      - the receiver of funds
      - optional fee that goes to the transaction sender (usually a relay)
  */
  function withdraw(uint256[2] memory a, uint256[2][2] memory b, uint256[2] memory c, uint256[5] memory input) public {
    uint256 root = input[0];
    uint256 nullifierHash = input[1];
    address payable receiver = address(input[2]);
    address payable relayer = address(input[3]);
    uint256 fee = input[4];
    require(fee < mixDenomination, "Fee exceeds transfer value");
    require(!nullifierHashes[nullifierHash], "The note has been already spent");

    require(isKnownRoot(root), "Cannot find your merkle root"); // Make sure to use a recent one
    require(verifier.verifyProof(a, b, c, input), "Invalid withdraw proof");
    nullifierHashes[nullifierHash] = true;
    _processWithdraw(receiver, relayer, fee);
    emit Withdraw(receiver, nullifierHash, relayer, fee);
  }

  function toggleDeposits() external {
    require(msg.sender == operator, "unauthorized");
    isDepositsEnabled = !isDepositsEnabled;
  }

  function changeOperator(address payable _newAccount) external {
    require(msg.sender == operator, "unauthorized");
    operator = _newAccount;
  }

  function isSpent(uint256 nullifier) public view returns(bool) {
    return nullifierHashes[nullifier];
  }

  function _processDeposit() internal {}
  function _processWithdraw(address payable _receiver, address payable _relayer, uint256 _fee) internal {}

}

// File: contracts/ERC20Mixer.sol

// https://tornado.cash
/*
* d888888P                                           dP              a88888b.                   dP
*    88                                              88             d8'   `88                   88
*    88    .d8888b. 88d888b. 88d888b. .d8888b. .d888b88 .d8888b.    88        .d8888b. .d8888b. 88d888b.
*    88    88'  `88 88'  `88 88'  `88 88'  `88 88'  `88 88'  `88    88        88'  `88 Y8ooooo. 88'  `88
*    88    88.  .88 88       88    88 88.  .88 88.  .88 88.  .88 dP Y8.   .88 88.  .88       88 88    88
*    dP    `88888P' dP       dP    dP `88888P8 `88888P8 `88888P' 88  Y88888P' `88888P8 `88888P' dP    dP
* ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
*/



contract ERC20Mixer is Mixer {
  address public token;
  // ether value to cover network fee (for relayer) and to have some ETH on a brand new address
  uint256 public userEther;

  constructor(
    address _verifier,
    uint256 _userEther,
    uint8 _merkleTreeHeight,
    uint256 _emptyElement,
    address payable _operator,
    address _token,
    uint256 _mixDenomination
  ) Mixer(_verifier, _mixDenomination, _merkleTreeHeight, _emptyElement, _operator) public {
    token = _token;
    userEther = _userEther;
  }

  function _processDeposit() internal {
    require(msg.value == userEther, "Please send `userEther` ETH along with transaction");
    safeErc20TransferFrom(msg.sender, address(this), mixDenomination);
  }

  function _processWithdraw(address payable _receiver, address payable _relayer, uint256 _fee) internal {
    _receiver.transfer(userEther);

    safeErc20Transfer(_receiver, mixDenomination - _fee);
    if (_fee > 0) {
      safeErc20Transfer(_relayer, _fee);
    }
  }

  function safeErc20TransferFrom(address from, address to, uint256 amount) internal {
    bool success;
    bytes memory data;
    bytes4 transferFromSelector = 0x23b872dd;
    (success, data) = token.call(
        abi.encodeWithSelector(
            transferFromSelector,
            from, to, amount
        )
    );
    require(success, "not enough allowed tokens");

    // if contract returns some data let's make sure that is `true` according to standard
    if (data.length > 0) {
      assembly {
        success := mload(add(data, 0x20))
      }
      require(success, "not enough allowed tokens");
    }
  }

  function safeErc20Transfer(address to, uint256 amount) internal {
    bool success;
    bytes memory data;
    bytes4 transferSelector = 0xa9059cbb;
    (success, data) = token.call(
        abi.encodeWithSelector(
            transferSelector,
            to, amount
        )
    );
    require(success, "not enough tokens");

    // if contract returns some data let's make sure that is `true` according to standard
    if (data.length > 0) {
      assembly {
        success := mload(add(data, 0x20))
      }
      require(success, "not enough tokens");
    }
  }
}
