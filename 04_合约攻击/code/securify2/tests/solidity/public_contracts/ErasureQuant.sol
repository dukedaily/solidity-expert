
// File: contracts/IPFSWrapper.sol



/**
 * @title IPFSWrapper
 * @dev Contract that handles IPFS multi hash data structures and encoding/decoding
 *   Learn more here: https://github.com/multiformats/multihash
 */
contract IPFSWrapper {

    struct IPFSMultiHash {
        uint8 hashFunction;
        uint8 digestSize;
        bytes32 hash;
    }

    // INTERNAL FUNCTIONS

    /**
    * @dev Given an IPFS multihash struct, returns the full base58-encoded IPFS hash
    * @param _multiHash IPFSMultiHash struct that has the hashFunction, digestSize and the hash
    * @return the base58-encoded full IPFS hash
    */
    function combineIPFSHash(IPFSMultiHash memory _multiHash) internal pure returns (bytes memory out) {
        out = new bytes(34);

        out[0] = byte(_multiHash.hashFunction);
        out[1] = byte(_multiHash.digestSize);

        uint8 i;
        for (i = 0; i < 32; i++) {
            out[i+2] = _multiHash.hash[i];
        }
    }

    /**
    * @dev Given a base58-encoded IPFS hash, divides into its individual parts and returns a struct
    * @param _source base58-encoded IPFS hash
    * @return IPFSMultiHash that has the hashFunction, digestSize and the hash
    */
    function splitIPFSHash(bytes memory _source) internal pure returns (IPFSMultiHash memory multihash) {
        uint8 hashFunction = uint8(_source[0]);
        uint8 digestSize = uint8(_source[1]);
        bytes32 hash;

        require(_source.length == digestSize + 2, "input wrong size");

        assembly {
            hash := mload(add(_source, 34))
        }

        return (IPFSMultiHash({
            hashFunction: hashFunction,
            digestSize: digestSize,
            hash: hash
        }));
    }
}

// File: interfaces/INMR.sol


interface INMR {

    /* ERC20 Interface */

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    /* NMR Special Interface */

    // used for user balance management
    function withdraw(address _from, address _to, uint256 _value) external returns(bool ok);

    // used like burn(uint256)
    function mint(uint256 _value) external returns (bool ok);

    // used like burnFrom(address, uint256)
    function numeraiTransfer(address _to, uint256 _value) external returns (bool ok);

    // used to check if upgrade completed
    function contractUpgradable() external view returns (bool);

    function getTournament(uint256 _tournamentID) external view returns (uint256, uint256[] memory);

    function getRound(uint256 _tournamentID, uint256 _roundID) external view returns (uint256, uint256, uint256);

    function getStake(uint256 _tournamentID, uint256 _roundID, address _staker, bytes32 _tag) external view returns (uint256, uint256, bool, bool);

}

// File: zos-lib/contracts/Initializable.sol



/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool wasInitializing = initializing;
    initializing = true;
    initialized = true;

    _;

    initializing = wasInitializing;
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: contracts/NMRUser.sol




contract NMRUser is Initializable {

    address public token;

    function initialize(address _token) public initializer {
        token = _token;
    }

    function _burn(uint256 _value) internal {
        if (INMR(token).contractUpgradable())
            require(INMR(token).transfer(address(0), _value));
        else
            require(INMR(token).mint(_value), "burn not successful");
    }

    function _burnFrom(address _from, uint256 _value) internal {
        if (INMR(token).contractUpgradable())
            require(INMR(token).transferFrom(_from, address(0), _value));
        else
            require(INMR(token).numeraiTransfer(_from, _value), "burnFrom not successful");
    }

}

// File: interfaces/IErasureProof.sol


interface IErasureProof {

    // Events

    event ProofCreation(bytes32 proofHash, address indexed owner, uint64 timestamp, bytes32 prevHash);

    // State Modifier

    function createProof(address owner, bytes32 prevHash, bytes32 dataHash, bytes calldata sig) external returns (bytes32 proofHash);

    // View

    // Callable On-Chain
    function verifyProof(bytes32 proofHash, bytes calldata data) external view returns (bool);
    function getProof(bytes32 proofHash) external view returns (address owner, uint64 timestamp, bytes32 prevHash, bytes32 nextHash);
    function getHashes() external view returns (bytes32[] memory hashes);

    // Pure

    function getDataHash(address owner, bytes32 prevHash, bytes calldata data) external pure returns (bytes32 dataHash);
    function getProofHash(address owner, bytes32 prevHash, bytes32 dataHash) external pure returns (bytes32 proofHash);
    function getRecover(bytes32 proofHash, bytes calldata sig) external pure returns (address owner);

}

// File: openzeppelin-eth/contracts/math/SafeMath.sol


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/ErasureQuant.sol







/*
    deployment bytecode size: 191 bytes
*/

contract ErasureQuant is Initializable, NMRUser, IPFSWrapper {

    using SafeMath for uint88;
    using SafeMath for uint64;
    using SafeMath for uint32;

    address public erasureProof;

    uint32 public feedNonce;
    mapping (uint32 => Feed) private feeds;

    /*

    CgtP: Cost to buyer greater than Punishment to seller
    CltP: Cost to buyer less than Punishment to seller
    CeqP: Cost to buyer equal to Punishment to seller:
    InfGrief: Buyer can punish seller at no cost.
    NoGrief: Buyer cannot punish seller.

    */
    enum GriefType { CgtP, CltP, CeqP, InfGreif, NoGreif }

    struct Feed {
        address seller;
        uint64 griefPeriod;     // seconds
        uint32 griefRatio;      // amount of seller stake to burn for each unit of buyer burn
        GriefType griefType;    // uint8 from 0-4 representing the type of griefing { CgtP, CltP, CeqP, NoGreif, InfGreif }
        uint32 predictionNonce; // incremental nonce
        uint64 closeTimestamp;  // unix timestamp
        uint88 stakeBurned;     // wei
        uint88 stake;           // wei
        IPFSMultiHash feedMetadata;
        address[] bidders;
        mapping (address => Bid) bids;
        mapping (uint32 => Prediction) predictions;
    }

    struct Bid {
        uint32 index;
        uint88 price;   // amount of wei per prediction
        uint88 deposit; // amount of wei deposited
        uint88 priceDecrease;     // amount of wei decrease requested
        uint88 depositDecrease;   // amount of wei decrease requested
        uint64 decreaseTimestamp; // unix timestamp
    }

    struct Prediction {
        address buyer;
        bytes32 proofHash;      // keccak256(seller,prevHash,dataHash)
        uint64 commitTimestamp; // unix timestamp
        uint64 revealTimestamp; // unix timestamp
        uint88 price;           // wei paid
        uint88 griefCost;       // wei burned
        IPFSMultiHash encryptedPrediction;
        IPFSMultiHash revealedPrediction;
    }

    function initialize(address _token, address _erasureProof) public initializer {
        NMRUser.initialize(_token);
        erasureProof = _erasureProof;
    }

    event FeedOpened(
        uint32 indexed feedID,
        address indexed seller,
        uint64 griefPeriod,
        uint32 griefRatio,
        GriefType indexed griefType,
        uint88 stakeAmount,
        bytes ipfsMetadata
    );
    event PredictionCommit(
        uint32 indexed feedID,
        uint32 indexed predictionID,
        bytes32 proofHash,
        bytes sig
    );
    event PredictionSold(
        uint32 indexed feedID,
        uint32 indexed predictionID,
        bytes32 proofHash,
        address indexed buyer,
        uint88 price,
        bytes ipfsEncryptedPrediction
    );
    event PredictionReveal(
        uint32 indexed feedID,
        uint32 indexed predictionID,
        bytes32 proofHash,
        bytes ipfsRevealedPrediction
    );
    event PredictionGriefed(
        uint32 indexed feedID,
        uint32 indexed predictionID,
        bytes32 proofHash,
        uint88 griefCost,
        uint88 griefPunishment
    );
    event FeedClosed(
        uint32 indexed feedID
    );
    event StakeUpdated(
        uint32 indexed feedID,
        uint88 amount
    );
    event BidUpdated(
        uint32 indexed feedID,
        address indexed buyer,
        uint88 price,
        uint88 deposit
    );

    function _isActiveFeed(uint32 feedID) internal view {
        require(feeds[feedID].closeTimestamp == 0, "Feed closed");
        require(feeds[feedID].seller != address(0), "Feed not opened");
    }

    function _isSeller(uint32 feedID) internal view {
        require(msg.sender == feeds[feedID].seller, "Only seller");
    }

    /////////////
    // Setters //
    /////////////

    function openFeed(
        uint64 griefPeriod,
        uint32 griefRatio,
        GriefType griefType,
        uint88 stakeAmount,
        bytes memory ipfsMetadata
    ) public returns (uint32 feedID) {
        feedID = feedNonce;
        feedNonce = uint32(feedNonce.add(1));

        Feed storage feed = feeds[feedID];

        feed.seller = msg.sender;
        feed.griefPeriod = griefPeriod;
        feed.griefRatio = griefRatio; // amount of seller stake to burn for each unit of buyer burn
        feed.griefType = griefType;
        feed.stake = stakeAmount;
        feed.feedMetadata = splitIPFSHash(ipfsMetadata);

        require(INMR(token).transferFrom(msg.sender, address(this), stakeAmount), "Token transfer was not successful.");

        emit FeedOpened(feedID, msg.sender, griefPeriod, griefRatio, griefType, stakeAmount, ipfsMetadata);
        emit StakeUpdated(feedID, stakeAmount);
    }

    function increaseStake(
        uint32 feedID,
        uint88 increaseAmount
    ) public {
        _isActiveFeed(feedID);

        feeds[feedID].stake = uint88(feeds[feedID].stake.add(increaseAmount));
        require(INMR(token).transferFrom(msg.sender, address(this), increaseAmount), "Token transfer was not successful.");

        emit StakeUpdated(feedID, feeds[feedID].stake);
    }

    function commitPrediction(
        uint32 feedID,
        bytes32 dataHash,
        bytes memory sig
    ) public returns (uint32 predictionID, bytes32 proofHash) {
        _isActiveFeed(feedID);
        _isSeller(feedID);

        Feed storage feed = feeds[feedID];

        predictionID = feed.predictionNonce;
        feed.predictionNonce = uint32(feed.predictionNonce.add(1));

        bytes32 prevHash;
        if (predictionID == 0)
            prevHash = bytes32(0);
        else
            prevHash = feed.predictions[predictionID-1].proofHash;

        proofHash = IErasureProof(erasureProof).createProof(msg.sender, prevHash, dataHash, sig);

        Prediction storage prediction = feed.predictions[predictionID];
        prediction.commitTimestamp = uint64(now);
        prediction.proofHash = proofHash;

        emit PredictionCommit(feedID, predictionID, proofHash, sig);
    }

    function sellPrediction(
        uint32 feedID,
        bytes32 dataHash,
        bytes memory sig,
        address buyer,
        bytes memory ipfsEncryptedPrediction
    ) public returns (uint32 predictionID, bytes32 proofHash) {
        _isActiveFeed(feedID);
        _isSeller(feedID);

        require(hasBid(feedID, buyer), "Buyer must have bid on the feed.");
        require(buyer != address(0), "Buyer cannot be zero address.");

        (predictionID, proofHash) = commitPrediction(feedID, dataHash, sig);

        Bid storage bid = feeds[feedID].bids[buyer];
        Prediction storage prediction = feeds[feedID].predictions[predictionID];

        uint88 price = bid.price;

        prediction.buyer = buyer;
        prediction.price = price;
        prediction.encryptedPrediction = splitIPFSHash(ipfsEncryptedPrediction);

        _decreaseBid(feedID, 0, price, buyer);
        require(INMR(token).transfer(msg.sender, price), "Token transfer was not successful.");

        emit PredictionSold(feedID, predictionID, proofHash, buyer, price, ipfsEncryptedPrediction);
    }

    function revealPrediction(
        uint32 feedID,
        uint32 predictionID,
        bytes memory ipfsRevealedPrediction
    ) public {
        _isActiveFeed(feedID);
        _isSeller(feedID);

        Prediction storage prediction = feeds[feedID].predictions[predictionID];

        require(predictionID == 0 || feeds[feedID].predictions[predictionID - 1].revealTimestamp > 0,
            "Predictions must be revealed in order.");
        require(prediction.commitTimestamp > 0, "Prediction must first be commited.");
        require(prediction.revealTimestamp == 0, "Prediction can only be revealed once.");

        prediction.revealedPrediction = splitIPFSHash(ipfsRevealedPrediction);
        prediction.revealTimestamp = uint64(now);

        emit PredictionReveal(feedID, predictionID, prediction.proofHash, ipfsRevealedPrediction);
    }

    function increaseBid(
        uint32 feedID,
        uint88 priceIncrease,
        uint88 depositIncrease
    ) public {
        _isActiveFeed(feedID);

        if (!hasBid(feedID, msg.sender)) {
            _createBid(feedID, msg.sender);
        }

        Bid storage bid = feeds[feedID].bids[msg.sender];

        bid.price = uint88(bid.price.add(priceIncrease));
        bid.deposit = uint88(bid.deposit.add(depositIncrease));

        if (depositIncrease != 0)
            require(INMR(token).transferFrom(msg.sender, address(this), depositIncrease), "Token transfer was not successful.");

        emit BidUpdated(feedID, msg.sender, bid.price, bid.deposit);
    }

    function requestDecreaseBid(
        uint32 feedID,
        uint88 priceDecrease,
        uint88 depositDecrease
    ) public {
        _isActiveFeed(feedID);

        require(hasBid(feedID, msg.sender), "Buyer must have bid on the feed.");
        Bid storage bid = feeds[feedID].bids[msg.sender];

        bid.priceDecrease = priceDecrease;
        bid.depositDecrease = depositDecrease;
        bid.decreaseTimestamp = uint64(block.timestamp);
    }

    function confirmDecreaseBid(
        uint32 feedID
    ) public {
        _isActiveFeed(feedID);
        require(canConfirmDecrease(feedID, msg.sender), "cannot confirm decrease");

        Bid storage bid = feeds[feedID].bids[msg.sender];

        if (bid.depositDecrease != 0)
            require(INMR(token).transfer(msg.sender, bid.depositDecrease), "Token transfer was not successful.");
        _decreaseBid(feedID, bid.priceDecrease, bid.depositDecrease, msg.sender);
    }

    function grief(
        uint32 feedID,
        uint32 predictionID,
        uint88 griefPunishment
    ) public {
        _isActiveFeed(feedID);

        Feed storage feed = feeds[feedID];

        require(griefPunishment != 0, "Griefing must burn the seller stake");
        require(feed.griefType != GriefType.NoGreif, "Cannot grief a feed set as NoGreif.");
        require(griefPunishment <= feed.stake, "Feed must have sufficient stake.");
        require(feed.predictions[predictionID].buyer == msg.sender, "Only buyer of prediciton can call.");
        require(now <= uint64(feed.predictions[predictionID].commitTimestamp.add(feed.griefPeriod)),
            "Griefing period must be active.");

        uint88 griefCost = getGriefCost(feed.griefRatio, griefPunishment, feed.griefType);

        feed.stakeBurned = uint88(feed.stakeBurned.add(griefPunishment));
        feed.stake = uint88(feed.stake.sub(griefPunishment));
        feed.predictions[predictionID].griefCost = uint88(feed.predictions[predictionID].griefCost.add(griefCost));

        _burn(griefPunishment);
        _burnFrom(msg.sender, griefCost);

        emit PredictionGriefed(feedID, predictionID, feed.predictions[predictionID].proofHash, griefCost, griefPunishment);
        emit StakeUpdated(feedID, feed.stake);
    }

    function closeFeed(
        uint32 feedID
    ) public {
        _isActiveFeed(feedID);
        _isSeller(feedID);

        Feed storage feed = feeds[feedID];

        if (feed.predictionNonce != 0)
            require(now >= uint64(feed.predictions[feed.predictionNonce - 1].commitTimestamp.add(feed.griefPeriod)),
            "Griefing period must be over.");

        feed.closeTimestamp = uint64(now);

        require(INMR(token).transfer(feed.seller, feed.stake), "Token transfer was not successful.");

        emit FeedClosed(feedID);
    }

    // Helpers

    function openAndCommit(
        uint64 griefPeriod,
        uint32 griefRatio,
        GriefType griefType,
        uint88 stakeAmount,
        bytes calldata ipfsMetadata,
        bytes32 dataHash,
        bytes calldata sig
    ) external {
        uint32 feedID = openFeed(griefPeriod, griefRatio, griefType, stakeAmount, ipfsMetadata);
        commitPrediction(feedID, dataHash, sig);
    }

    function revealAndCommit(
        uint32 feedID,
        uint32 predictionID,
        bytes32 dataHash,
        bytes calldata sig,
        bytes calldata ipfsRevealedPrediction
    ) external {
        revealPrediction(feedID, predictionID, ipfsRevealedPrediction);
        commitPrediction(feedID, dataHash, sig);
    }

    function revealAndSell(
        uint32 feedID,
        uint32 predictionID,
        bytes32 dataHash,
        bytes calldata sig,
        bytes calldata ipfsRevealedPrediction,
        address buyer,
        bytes calldata ipfsEncryptedPrediction
    ) external {
        revealPrediction(feedID, predictionID, ipfsRevealedPrediction);
        sellPrediction(feedID, dataHash, sig, buyer, ipfsEncryptedPrediction);
    }

    //////////////
    // Internal //
    //////////////

    function _decreaseBid(uint32 feedID, uint88 priceDecrease, uint88 depositDecrease, address buyer) internal {
        Bid storage bid = feeds[feedID].bids[buyer];

        if (bid.deposit == depositDecrease) {
            _deleteBid(feedID, buyer);
        } else {
            bid.price = uint88(bid.price.sub(priceDecrease));
            bid.deposit = uint88(bid.deposit.sub(depositDecrease));
            bid.priceDecrease = 0;
            bid.depositDecrease = 0;
            bid.decreaseTimestamp = 0;
        }

        emit BidUpdated(feedID, buyer, bid.price, bid.deposit);
    }

    function _createBid(uint32 feedID, address buyer) internal {
        Feed storage feed = feeds[feedID];

        feed.bids[buyer].index = uint32(feed.bidders.length);
        feed.bidders.push(buyer);
    }

    function _deleteBid(uint32 feedID, address buyer) internal {
        Feed storage feed = feeds[feedID];

        uint32 targetIndex = feed.bids[msg.sender].index;

        uint32 lastIndex = uint32(feed.bidders.length - 1);
        address lastAddress = feed.bidders[lastIndex];

        feed.bids[lastAddress].index = targetIndex;
        feed.bidders[targetIndex] = lastAddress;

        delete feed.bids[buyer];
        delete feed.bidders[lastIndex];

        feed.bidders.length--;
    }

    ////////////////////
    // Public Getters //
    ////////////////////

    function getGriefCost(uint32 griefRatio, uint88 griefPunishment, GriefType griefType) public pure returns(uint88 griefCost) {
        /* enum GriefType { CgtP, CltP, CeqP, InfGreif, NoGreif } */
        if (griefType == GriefType.CgtP)
            return uint88(griefPunishment.mul(griefRatio));
        if (griefType == GriefType.CltP)
            return uint88(griefPunishment.div(griefRatio));
        if (griefType == GriefType.CeqP)
            return griefPunishment;
        if (griefType == GriefType.InfGreif)
            return 0;
        if (griefType == GriefType.NoGreif)
            revert();
    }

    function hasBid(uint32 feedID, address buyer) public view returns(bool status) {
        Feed storage feed = feeds[feedID];
        if (feed.bidders.length == 0) return false;
        return (feed.bidders[feed.bids[buyer].index] == buyer);
    }

    function canConfirmDecrease(uint32 feedID, address buyer) public view returns(bool status) {
        Bid storage bid = feeds[feedID].bids[buyer];
        return 0 != bid.decreaseTimestamp && 86400 < block.timestamp - bid.decreaseTimestamp;
    }

    //////////////////////
    // External Getters //
    //////////////////////

    function verifyProof(uint32 feedID, uint32 predictionID, bytes calldata predictionData) external view returns (bool result) {
        bytes32 proofHash = feeds[feedID].predictions[predictionID].proofHash;
        result = IErasureProof(erasureProof).verifyProof(proofHash, predictionData);
    }

    function getBidders(uint32 feedID) external view returns(address[] memory bidders) {
        return feeds[feedID].bidders;
    }

    function getBid(uint32 feedID, address buyer) external view returns (
        uint32 index,
        uint88 price,
        uint88 deposit,
        uint88 priceDecrease,
        uint88 depositDecrease,
        uint64 decreaseTimestamp
    ) {
        Bid storage bid = feeds[feedID].bids[buyer];
        return (
            bid.index,
            bid.price,
            bid.deposit,
            bid.priceDecrease,
            bid.depositDecrease,
            bid.decreaseTimestamp
        );
    }

    function getFeed(uint32 feedID) external view returns (
        address seller,
        uint64 griefPeriod,
        uint32 griefRatio,
        GriefType griefType,
        uint32 predictionNonce,
        uint64 closeTimestamp,
        uint88 stakeBurned,
        uint88 stake,
        bytes memory feedMetadata,
        address[] memory bidders
    ) {
        Feed storage feed = feeds[feedID];
        return (
            feed.seller,
            feed.griefPeriod,
            feed.griefRatio,
            feed.griefType,
            feed.predictionNonce,
            feed.closeTimestamp,
            feed.stakeBurned,
            feed.stake,
            combineIPFSHash(feed.feedMetadata),
            feed.bidders
        );
    }

    function getPrediction(uint32 feedID, uint32 predictionID) external view returns (
        address buyer,
        uint64 commitTimestamp,
        uint64 revealTimestamp,
        bytes32 proofHash,
        uint88 price,
        uint88 griefCost,
        bytes memory encryptedPrediction,
        bytes memory revealedPrediction
    ) {
        Prediction storage prediction = feeds[feedID].predictions[predictionID];
        return (
            prediction.buyer,
            prediction.commitTimestamp,
            prediction.revealTimestamp,
            prediction.proofHash,
            prediction.price,
            prediction.griefCost,
            combineIPFSHash(prediction.encryptedPrediction),
            combineIPFSHash(prediction.revealedPrediction)
        );
    }
}
