
// File: openzeppelin-solidity/contracts/math/SafeMath.sol


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

// File: contracts/interfaces/IERC223ReceivingContract.sol


/// @title Contract that supports the receival of ERC223 tokens.
contract IERC223ReceivingContract {

    /// @dev Standard ERC223 function that will handle incoming token transfers.
    /// @param _from  Token sender address.
    /// @param _value Amount of tokens.
    /// @param _data  Transaction metadata.
    function tokenFallback(address _from, uint _value, bytes memory _data) public;

}

// File: contracts/interfaces/IDetherToken.sol


contract IDetherToken {
    function mintingFinished() view public returns(bool);
    function name() view public returns(string memory);
    function approve(address _spender, uint256 _value) public returns(bool);
    function totalSupply() view public returns(uint256);
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool);
    function decimals() view public returns(uint8);
    function mint(address _to, uint256 _amount) public returns(bool);
    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns(bool);
    function balanceOf(address _owner) view public returns(uint256 balance);
    function finishMinting() public returns(bool);
    function owner() view public returns(address);
    function symbol() view public returns(string memory);
    function transfer(address _to, uint256 _value) public returns(bool);
    function transfer(address _to, uint256 _value, bytes memory _data) public returns(bool);
    function increaseApproval(address _spender, uint256 _addedValue) public returns(bool);
    function allowance(address _owner, address _spender) view public returns(uint256);
    function transferOwnership(address newOwner) public;
}

// File: contracts/interfaces/IControl.sol


contract IControl {
    function cmo() view public returns(address);
    function cfo() view public returns(address);
    function paused() view public returns(bool);
    function shopModerators(address) view public returns(bool);
    function cso() view public returns(address);
    function ceo() view public returns(address);
    function tellerModerators(address) view public returns(bool);
    function setCEO(address _who) external;
    function setCSO(address _who) external;
    function setCMO(address _who) external;
    function setCFO(address _who) external;
    function setShopModerator(address _who) external;
    function removeShopModerator(address _who) external;
    function setTellerModerator(address _who) external;
    function removeTellerModerator(address _who) external;
    // function pause() external;
    // function unpause() external;
    function isCEO(address _who) view external returns(bool);
    function isCSO(address _who) view external returns(bool);
    function isCMO(address _who) view external returns(bool);
    function isCFO(address _who) view external returns(bool);
    function isTellerModerator(address _who) view external returns(bool);
    function isShopModerator(address _who) view external returns(bool);
}

// File: contracts/interfaces/IGeoRegistry.sol


contract IGeoRegistry {
    function countryIsEnabled(bytes2) view public returns(bool);
    function enabledCountries(uint256) view public returns(bytes2);
    function level_2(bytes2, bytes3) view public returns(bytes4);
    function shopLicensePrice(bytes2) view public returns(uint256);
    function control() view public returns(address);
    function countryTierDailyLimit(bytes2, uint256) view public returns(uint256);
    function validGeohashChars(bytes memory _bytes) public returns(bool);
    function validGeohashChars12(bytes12 _bytes) public returns(bool);
    function zoneInsideCountry(bytes2 _countryCode, bytes4 _zone) view public returns(bool);
    function setCountryTierDailyLimit(bytes2 _countryCode, uint256 _tier, uint256 _limitUsd) public;
    function updateLevel2(bytes2 _countryCode, bytes3 _letter, bytes4 _subLetters) public;
    function updateLevel2batch(bytes2 _countryCode, bytes3[] memory _letters, bytes4[] memory _subLetters) public;
    function enableCountry(bytes2 _country) external;
    function disableCountry(bytes2 _country) external;
}

// File: contracts/interfaces/IZoneFactory.sol


contract IZoneFactory {
    function dth() view public returns(address);
    function zoneToGeohash(address) view public returns(bytes6);
    function geohashToZone(bytes6) view public returns(address);
    function renounceOwnership() public;
    function owner() view public returns(address);
    function isOwner() view public returns(bool);
    function zoneImplementation() view public returns(address);
    function tellerImplementation() view public returns(address);
    function control() view public returns(address);
    function geo() view public returns(address);
    function users() view public returns(address);
    function transferOwnership(address newOwner) public;
    function zoneExists(bytes6 _geohash) view external returns(bool);
    function proxyUpdateUserDailySold(bytes2 _countryCode, address _from, address _to, uint256 _amount) external;
    function tokenFallback(address _from, uint256 _value, bytes memory _data) public;
}

// File: contracts/interfaces/IZone.sol


contract IZone {
    function dth() view public returns(address);
    function geohash() view public returns(bytes6);
    function currentAuctionId() view public returns(uint256);
    function auctionBids(uint256, address) view public returns(uint256);
    function withdrawableDth(address) view public returns(uint256);
    function teller() view public returns(address);
    function zoneFactory() view public returns(address);
    function MIN_STAKE() view public returns(uint256);
    function country() view public returns(bytes2);
    function control() view public returns(address);
    function geo() view public returns(address);
    function withdrawableEth(address) view public returns(uint256);
    function init(bytes2 _countryCode, bytes6 _geohash, address _zoneOwner, uint256 _dthAmount, address _dth, address _geo, address _control, address _zoneFactory) external;
    function connectToTellerContract(address _teller) external;
    function ownerAddr() view external returns(address);
    function computeCSC(bytes6 _geohash, address _addr) pure public returns(bytes12);
    function calcHarbergerTax(uint256 _startTime, uint256 _endTime, uint256 _dthAmount) view public returns(uint256 taxAmount, uint256 keepAmount);
    function calcEntryFee(uint256 _value) view public returns(uint256 burnAmount, uint256 bidAmount);
    function auctionExists(uint256 _auctionId) view external returns(bool);
    function getZoneOwner() view external returns(address, uint256, uint256, uint256, uint256, uint256);
    function getAuction(uint256 _auctionId) view public returns(uint256, uint256, uint256, uint256, address, uint256);
    function getLastAuction() view external returns(uint256, uint256, uint256, uint256, address, uint256);
    function processState() external;
    function tokenFallback(address _from, uint256 _value, bytes memory _data) public;
    function release() external;
    function withdrawFromAuction(uint256 _auctionId) external;
    function withdrawFromAuctions(uint256[] calldata _auctionIds) external;
    function withdrawDth() external;
    function withdrawEth() external;
    function proxyUpdateUserDailySold(address _to, uint256 _amount) external;
}

// File: contracts/interfaces/ITeller.sol


contract ITeller {
    function funds() view public returns(uint256);
    function control() view public returns(address);
    function geo() view public returns(address);
    function withdrawableEth(address) view public returns(uint256);
    function canPlaceCertifiedComment(address, address) view public returns(uint256);
    function zone() view public returns(address);
    function init(address _geo, address _control, address _zone) external;
    function getCertifiedComments() view external returns(bytes32[] memory);
    function getComments() view external returns(bytes32[] memory);
    function calcReferrerFee(uint256 _value) view public returns(uint256 referrerAmount);
    function getTeller() view external returns(address, uint8, bytes16, bytes12, bytes1, int16, int16, uint256, address);
    function hasTeller() view external returns(bool);
    function removeTellerByZone() external;
    function removeTeller() external;
    function addTeller(bytes calldata _position, uint8 _currencyId, bytes16 _messenger, int16 _sellRate, int16 _buyRate, bytes1 _settings, address _referrer) external;
    function addFunds() payable external;
    function sellEth(address _to, uint256 _amount) external;
    function addCertifiedComment(bytes32 _commentHash) external;
    function addComment(bytes32 _commentHash) external;
}

// File: contracts/map/Zone.sol










contract Zone is IERC223ReceivingContract {
  // ------------------------------------------------
  //
  // Library init
  //
  // ------------------------------------------------

  using SafeMath for uint;

  // ------------------------------------------------
  //
  // Enums
  //
  // ------------------------------------------------

  enum AuctionState { Started, Ended }

  // ------------------------------------------------
  //
  // Structs
  //
  // ------------------------------------------------

  // NOTE:
  // evm will convert to uint256 when doing calculations, so 1 time higher storage cost
  // will be less than all the increased gas costs if we were to use smaller uints in the struct

  struct ZoneOwner {
    address addr;
    uint startTime;
    uint staked;
    uint balance;
    uint lastTaxTime;
    uint auctionId;
  }

  struct Auction {
    // since we do a lot of calcuations with these uints, it's best to leave them uint256
    // evm will convert to uint256 anyways when doing calculations
    uint startTime;
    uint endTime;
    AuctionState state;
    address highestBidder;
  }

  // ------------------------------------------------
  //
  // Variables Private
  //
  // ------------------------------------------------

  uint public constant MIN_STAKE = 100 * 1 ether; // DTH, which is also 18 decimals!
  uint private constant BID_PERIOD = 24 * 1 hours;
  uint private constant COOLDOWN_PERIOD = 48 * 1 hours;
  uint private constant ENTRY_FEE_PERCENTAGE = 1; // 1%
  uint private constant TAX_PERCENTAGE = 1; // 1% daily
  uint private constant REFERRER_FEE_PERCENTAGE = 1; // 0.1%
  address private constant ADDRESS_BURN = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

  ZoneOwner private zoneOwner;

  mapping(uint => Auction) private auctionIdToAuction;

  // ------------------------------------------------
  //
  // Variables Public
  //
  // ------------------------------------------------

  bool private inited;
  bool private tellerConnected;

  IDetherToken public dth;
  IGeoRegistry public geo;
  IControl public control;
  IZoneFactory public zoneFactory;
  ITeller public teller;

  bytes2 public country;
  bytes6 public geohash;

  mapping(address => uint) public withdrawableDth;
  mapping(address => uint) public withdrawableEth;

  uint public currentAuctionId; // starts at 0, first auction will get id 1, etc.

  //      auctionId       bidder     dthAmount
  mapping(uint => mapping(address => uint)) public auctionBids;

  // ------------------------------------------------
  //
  // Events
  //
  // ------------------------------------------------

  // TODO

  // ------------------------------------------------
  //
  // Modifiers
  //
  // ------------------------------------------------

  modifier onlyWhenInited() {
    require(inited == true, "contract not yet initialized");
    _;
  }
  modifier onlyWhenNotInited() {
    require(inited == false, "contract already initialized");
    _;
  }

  modifier onlyWhenTellerConnected() {
    require(tellerConnected == true, "teller contract not yet connected");
    _;
  }
  modifier onlyWhenTellerNotConnected() {
    require(tellerConnected == false, "teller contract already connected");
    _;
  }

  modifier onlyWhenCountryEnabled {
    require(geo.countryIsEnabled(country), "country is disabled");
    _;
  }

  modifier updateState {
    _processState();
    _;
  }

  modifier onlyWhenZoneHasOwner {
    require(zoneOwner.addr != address(0), "zone has no owner");
    _;
  }

  modifier onlyWhenCallerIsNotZoneOwner {
    require(msg.sender != zoneOwner.addr, "can not be called by zoneowner");
    _;
  }

  modifier onlyWhenCallerIsZoneOwner {
    require(msg.sender == zoneOwner.addr, "caller is not zoneowner");
    _;
  }

  modifier onlyByTellerContract {
    require(msg.sender == address(teller), "can only be called by teller contract");
    _;
  }

  modifier onlyWhenZoneHasNoOwner {
    require(zoneOwner.addr == address(0), "can not claim zone with owner");
    _;
  }

  // ------------------------------------------------
  //
  // Constructor
  //
  // ------------------------------------------------

  // executed by ZoneFactory.sol when this Zone does not yet exist (= not yet deployed)
  function init(
    bytes2 _countryCode,
    bytes6 _geohash,
    address _zoneOwner,
    uint _dthAmount,
    address _dth,
    address _geo,
    address _control,
    address _zoneFactory
  )
    onlyWhenNotInited
    external
  {
    require(_dthAmount >= MIN_STAKE, "zone dth stake shoulld be at least minimum (100DTH)");

    country = _countryCode;
    geohash = _geohash;

    dth = IDetherToken(_dth);
    geo = IGeoRegistry(_geo);
    control = IControl(_control);
    zoneFactory = IZoneFactory(_zoneFactory);

    zoneOwner.addr = _zoneOwner;
    zoneOwner.startTime = now;
    zoneOwner.staked = _dthAmount;
    zoneOwner.balance = _dthAmount;
    zoneOwner.lastTaxTime = now;
    zoneOwner.auctionId = 0; // was not gained by winning an auction

    inited = true;
  }

  function connectToTellerContract(address _teller)
    onlyWhenInited
    onlyWhenTellerNotConnected
    external
  {
    teller = ITeller(_teller);

    tellerConnected = true;
  }

  // ------------------------------------------------
  //
  // Functions Getters Public
  //
  // ------------------------------------------------

  function ownerAddr()
    external view
    returns (address)
  {
    return zoneOwner.addr;
  }

  function computeCSC(bytes6 _geohash, address _addr)
    public
    pure
    returns (bytes12)
  {
    return bytes12(keccak256(abi.encodePacked(_geohash, _addr)));
  }

  function calcHarbergerTax(uint _startTime, uint _endTime, uint _dthAmount)
    public
    view
    returns (uint taxAmount, uint keepAmount)
  {
    // TODO use smaller uint variables, hereby preventing under/overflows, so no need for SafeMath
    // source: https://programtheblockchain.com/posts/2018/09/19/implementing-harberger-tax-deeds/
    taxAmount = _dthAmount.mul(_endTime.sub(_startTime)).mul(TAX_PERCENTAGE).div(100).div(1 days);
    keepAmount = _dthAmount.sub(taxAmount);
  }

  function calcEntryFee(uint _value)
    public
    view
    returns (uint burnAmount, uint bidAmount)
  {
    burnAmount = _value.div(100).mul(ENTRY_FEE_PERCENTAGE); // 1%
    bidAmount = _value.sub(burnAmount); // 99%
  }

  function auctionExists(uint _auctionId)
    external
    view
    returns (bool)
  {
    // if aucton does not exist we should get back zero, otherwise this field
    // will contain a block.timestamp, set whe creating an Auction, in constructor() and bid()
    return auctionIdToAuction[_auctionId].startTime > 0;
  }

  /// @notice get current zone owner data
  function getZoneOwner()
    external
    view
    returns (address, uint, uint, uint, uint, uint)
  {
    return (
      zoneOwner.addr,        // address of current owner
      zoneOwner.startTime,   // time this address became owner
      zoneOwner.staked,      // "price you sell at"
      zoneOwner.balance,     // will decrease whenever harberger taxes are paid
      zoneOwner.lastTaxTime, // time until taxes have been paid
      zoneOwner.auctionId    // if gained by winning auction, the auction id, otherwise zero
    );
  }

  /// @notice get a specific auction
  function getAuction(uint _auctionId)
    public
    view
    returns (uint, uint, uint, uint, address, uint)
  {
    require(_auctionId > 0 && _auctionId <= currentAuctionId, "auction does not exist");

    Auction memory auction = auctionIdToAuction[_auctionId];

    uint highestBid = auctionBids[_auctionId][auction.highestBidder];

    // for current zone owner his existing zone stake is added to his bid
    if (auction.state == AuctionState.Started &&
        auction.highestBidder == zoneOwner.addr)
    {
      highestBid = highestBid.add(zoneOwner.staked);
    }

    return (
      _auctionId,
      uint(auction.state),
      auction.startTime,
      auction.endTime,
      auction.highestBidder,
      highestBid
    );
  }

  /// @notice get the last auction
  function getLastAuction()
    external view
    returns (uint, uint, uint, uint, address, uint)
  {
    return getAuction(currentAuctionId);
  }

  // ------------------------------------------------
  //
  // Functions Getters Private
  //
  // ------------------------------------------------

  function toBytes1(bytes memory _bytes, uint _start)
    private pure
    returns (bytes1) {
      require(_bytes.length >= (_start + 1), " not long enough");
      bytes1 tempBytes1;

      assembly {
          tempBytes1 := mload(add(add(_bytes, 0x20), _start))
      }

      return tempBytes1;
  }
  function toBytes7(bytes memory _bytes, uint _start)
    private pure
    returns (bytes7) {
      require(_bytes.length >= (_start + 7), " not long enough");
      bytes7 tempBytes7;

      assembly {
          tempBytes7 := mload(add(add(_bytes, 0x20), _start))
      }

      return tempBytes7;
  }
    function toBytes6(bytes memory _bytes, uint _start)
    private
    pure
    returns (bytes6)
  {
    require(_bytes.length >= (_start + 6), " not long enough");
    bytes6 tempBytes6;

    assembly {
        tempBytes6 := mload(add(add(_bytes, 0x20), _start))
    }

    return tempBytes6;
  }
  function toBytes12(bytes memory _bytes, uint _start)
    private pure
    returns (bytes12) {
      require(_bytes.length >= (_start + 12), " not long enough");
      bytes12 tempBytes12;

      assembly {
          tempBytes12 := mload(add(add(_bytes, 0x20), _start))
      }

      return tempBytes12;
  }

  // ------------------------------------------------
  //
  // Functions Setters Private
  //
  // ------------------------------------------------

  function _removeZoneOwner()
    private
  {
    withdrawableDth[zoneOwner.addr] = withdrawableDth[zoneOwner.addr].add(zoneOwner.balance);

    if (teller.hasTeller()) {
      teller.removeTellerByZone();
    }

    zoneOwner.addr = address(0);
    zoneOwner.startTime = 0;
    zoneOwner.staked = 0;
    zoneOwner.balance = 0;
    zoneOwner.lastTaxTime = 0;
    zoneOwner.auctionId = 0;
  }

  function _handleTaxPayment()
    private
  {
    // processState ensured that: no running auction + there is a zone owner

    if (zoneOwner.lastTaxTime >= now) {
      return; // short-circuit: multiple txes in 1 block OR many blocks but in same Auction
    }

    (uint taxAmount, uint keepAmount) = calcHarbergerTax(zoneOwner.lastTaxTime, now, zoneOwner.staked);

    if (taxAmount >= zoneOwner.balance) {
      // zone owner does not have enough balance, remove him as zone owner
      uint oldZoneOwnerBalance = zoneOwner.balance;
      _removeZoneOwner();
      dth.transfer(ADDRESS_BURN, oldZoneOwnerBalance);
    } else {
      // zone owner can pay due taxes
      zoneOwner.balance = zoneOwner.balance.sub(taxAmount);
      zoneOwner.lastTaxTime = now;
      dth.transfer(ADDRESS_BURN, taxAmount);
    }
  }

  function _endAuction()
    private
  {
    Auction storage lastAuction = auctionIdToAuction[currentAuctionId];

    lastAuction.state = AuctionState.Ended;

    uint highestBid = auctionBids[currentAuctionId][lastAuction.highestBidder];
    uint auctionEndTime = auctionIdToAuction[currentAuctionId].endTime;

    if (zoneOwner.addr == lastAuction.highestBidder) {
      // current zone owner won the auction, extend his zone ownershp
      zoneOwner.staked = zoneOwner.staked.add(highestBid);
      zoneOwner.balance = zoneOwner.balance.add(highestBid);

      // need to set it since it might've been zero
      zoneOwner.auctionId = currentAuctionId; // the (last) auctionId that gave the zoneOwner zone ownership
    } else {
      // we need to update the zone owner
      _removeZoneOwner();

      zoneOwner.addr = lastAuction.highestBidder;
      zoneOwner.startTime = auctionEndTime;
      zoneOwner.staked = highestBid; // entry fee is already deducted when user calls bid()
      zoneOwner.balance = highestBid;
      zoneOwner.auctionId = currentAuctionId; // the auctionId that gave the zoneOwner zone ownership
    }

    // (new) zone owner needs to pay taxes from the moment he acquires zone ownership until now
    (uint taxAmount, uint keepAmount) = calcHarbergerTax(auctionEndTime, now, zoneOwner.staked);
    zoneOwner.balance = zoneOwner.balance.sub(taxAmount);
    zoneOwner.lastTaxTime = now;
  }

  function processState()
    external
    /* onlyByTellerContract */
  {
    _processState();
  }

  /// @notice private function to update the current auction state
  function _processState()
    private
  {
    if (currentAuctionId > 0 && auctionIdToAuction[currentAuctionId].state == AuctionState.Started) {
      // while uaction is running, no taxes need to be paid

      // handling of taxes around change of zone ownership are handled inside _endAuction
      if (now >= auctionIdToAuction[currentAuctionId].endTime) _endAuction();
    } else { // no running auction, currentAuctionId could be zero
      if (zoneOwner.addr != address(0)) _handleTaxPayment();
    }
  }

  function _joinAuction(address _sender, uint _dthAmount)
    private
  {
    Auction storage lastAuction = auctionIdToAuction[currentAuctionId];

    //------------------------------------------------------------------------------//
    // there is a running auction, lets see if we can join the auction with our bid //
    //------------------------------------------------------------------------------//

    require(_sender != lastAuction.highestBidder, "highest bidder cannot bid");

    uint currentHighestBid = auctionBids[currentAuctionId][lastAuction.highestBidder];

    if (_sender == zoneOwner.addr) {
      uint dthAddedBidsAmount = auctionBids[currentAuctionId][_sender].add(_dthAmount); // NOTE: _dthAmount
      // the current zone owner's stake also counts in his bid
      require(zoneOwner.staked.add(dthAddedBidsAmount) > currentHighestBid, "bid + already staked is less than current highest");
      auctionBids[currentAuctionId][_sender] = dthAddedBidsAmount;
    } else {
      // _sender is not the current zone owner
      if (auctionBids[currentAuctionId][_sender] == 0) {
        // this is the first bid of this challenger, deduct entry fee
        (uint burnAmount, uint bidAmount) = calcEntryFee(_dthAmount);
        require(bidAmount > currentHighestBid, "bid is less than current highest");
        auctionBids[currentAuctionId][_sender] = bidAmount;
        dth.transfer(ADDRESS_BURN, burnAmount);
      } else {
        // not the first bid, no entry fee
        uint newUserTotalBid = auctionBids[currentAuctionId][_sender].add(_dthAmount);
        require(newUserTotalBid > currentHighestBid, "bid is less than current highest");
        auctionBids[currentAuctionId][_sender] = newUserTotalBid;
      }
    }

    // it worked, _sender placed a bid
    lastAuction.highestBidder = _sender;
  }

  function _createAuction(address _sender, uint _dthAmount)
    private
  {
    require(_sender != zoneOwner.addr, "zoneowner cannot start an auction");

    (uint burnAmount, uint bidAmount) = calcEntryFee(_dthAmount);
    require(bidAmount > zoneOwner.staked, "bid is lower than current zone stake");

    // save the new Auction
    uint newAuctionId = ++currentAuctionId;

    auctionIdToAuction[newAuctionId] = Auction({
      state: AuctionState.Started,
      startTime: now,
      endTime: now.add(BID_PERIOD),
      highestBidder: _sender // caller (challenger)
    });

    auctionBids[newAuctionId][_sender] = bidAmount;

    dth.transfer(ADDRESS_BURN, burnAmount);
  }

  /// @notice private function to update the current auction state
  function _bid(address _sender, uint _dthAmount) // GAS COST +/- 223.689
    private
    onlyWhenZoneHasOwner
  {
    if (currentAuctionId > 0 && auctionIdToAuction[currentAuctionId].state == AuctionState.Started) {
      _joinAuction(_sender, _dthAmount);
    } else { // there currently is no running auction
      if (zoneOwner.auctionId == 0) {
        // current zone owner did not become owner by winning an auction, but by creating this zone or caliming it when it was free
        require(now > zoneOwner.startTime.add(COOLDOWN_PERIOD), "cooldown period did not end yet");
      } else {
        // current zone owner became owner by winning an auction (which has ended)
        require(now > auctionIdToAuction[currentAuctionId].endTime.add(COOLDOWN_PERIOD), "cooldown period did not end yet");
      }
      _createAuction(_sender, _dthAmount);
    }
  }

  function _claimFreeZone(address _sender, uint _dthAmount) // GAS COSt +/- 177.040
    private
    onlyWhenZoneHasNoOwner
  {
    require(_dthAmount >= MIN_STAKE, "need at least minimum zone stake amount (100 DTH)");

    // NOTE: empty zone claim will not have entry fee deducted, its not bidding it's taking immediately
    zoneOwner.addr = _sender;
    zoneOwner.startTime = now;
    zoneOwner.staked = _dthAmount;
    zoneOwner.balance = _dthAmount;
    zoneOwner.lastTaxTime = now;
    zoneOwner.auctionId = 0; // since it was not gained wby winning an auction
  }

  function _topUp(address _sender, uint _dthAmount) // GAS COST +/- 104.201
    private
    onlyWhenZoneHasOwner
  {
    require(_sender == zoneOwner.addr, "caller is not zoneowner");
    require(currentAuctionId == 0 || auctionIdToAuction[currentAuctionId].state == AuctionState.Ended, "cannot top up while auction running");

    uint oldBalance = zoneOwner.balance;
    uint newBalance = oldBalance.add(_dthAmount);
    zoneOwner.balance = newBalance;

    // a zone owner can currently keep calling this to increase his dth balance inside the zone
    // without a change in his sell price (= zone.staked) or tax amount he needs to pay
    //
    // TODO:
    // - should we also increse his dth stake when he tops up his dth balance?
    // - or should we limit his max topup to make his balance not bigger
    //   than his zone.staked amount (over which he pays taxes), or maybe not more than 10% above his zone.staked
  }

  // ------------------------------------------------
  //
  // Functions Setters Public
  //
  // ------------------------------------------------

  /// @notice ERC223 receiving function called by Dth contract when Eth is sent to this contract
  /// @param _from Who send DTH to this contract
  /// @param _value How much DTH was sent to this contract
  /// @param _data Additional bytes data sent
  function tokenFallback(address _from, uint _value, bytes memory _data)
    public
    onlyWhenInited
    onlyWhenTellerConnected
    onlyWhenCountryEnabled
  {
    require(msg.sender == address(dth), "can only be called by dth contract");

    bytes1 func = toBytes1(_data, 0);

    require(func == bytes1(0x40) || func == bytes1(0x41) || func == bytes1(0x42) || func == bytes1(0x43), "did not match Zone function");

    if (func == bytes1(0x40)) { // zone was created by factory, sending through DTH
      return; // just retun success
    }

    _processState();

    if (func == bytes1(0x41)) { // claimFreeZone
      _claimFreeZone(_from, _value);
    } else if (func == bytes1(0x42)) { // bid
      _bid(_from, _value);
    } else if (func == bytes1(0x43)) { // topUp
      _topUp(_from, _value);
    }
  }

  /// @notice release zone ownership
  /// @dev can only be called by current zone owner, when there is no running auction
  function release() // GAS COST +/- 72.351
    external
    onlyWhenInited
    onlyWhenTellerConnected
    updateState
    onlyWhenCallerIsZoneOwner
  {
    // allow also when country is disabled, otherwise no way for zone owner to get their eth/dth back

    require(currentAuctionId == 0 || auctionIdToAuction[currentAuctionId].state == AuctionState.Ended, "cannot release while auction running");

    uint ownerBalance = zoneOwner.balance;

    _removeZoneOwner();

    // if msg.sender is a contract, the DTH ERC223 contract will try to call tokenFallback
    // on msg.sender, this could lead to a reentrancy. But we prevent this by resetting
    // zoneOwner before we do dth.transfer(msg.sender)
    dth.transfer(msg.sender, ownerBalance);
  }

  // offer three different withdraw functions, single auction, multiple auctions, all auctions

  /// @notice withdraw losing bids from a specific auction
  /// @param _auctionId The auction id
  function withdrawFromAuction(uint _auctionId) // GAS COST +/- 125.070
    external
    onlyWhenInited
    onlyWhenTellerConnected
    updateState
  {
    // even when country is disabled, otherwise users cannot withdraw their bids
    require(_auctionId > 0 && _auctionId <= currentAuctionId, "auctionId does not exist");

    require(auctionIdToAuction[_auctionId].state == AuctionState.Ended, "cannot withdraw while auction is active");
    require(auctionIdToAuction[_auctionId].highestBidder != msg.sender, "auction winner can not withdraw");
    require(auctionBids[_auctionId][msg.sender] > 0, "nothing to withdraw");

    uint withdrawAmount = auctionBids[_auctionId][msg.sender];
    auctionBids[_auctionId][msg.sender] = 0;

    dth.transfer(msg.sender, withdrawAmount);
  }

  /// @notice withdraw from a given list of auction ids
  function withdrawFromAuctions(uint[] calldata _auctionIds) // GAS COST +/- 127.070
    external
    onlyWhenInited
    onlyWhenTellerConnected
    updateState
  {
    // even when country is disabled, can withdraw
    require(currentAuctionId > 0, "there are no auctions");

    require(_auctionIds.length > 0, "auctionIds list is empty");
    require(_auctionIds.length <= currentAuctionId, "auctionIds list is longer than allowed");

    uint withdrawAmountTotal = 0;

    for (uint idx = 0; idx < _auctionIds.length; idx++) {
      uint auctionId = _auctionIds[idx];
      require(auctionId > 0 && auctionId <= currentAuctionId, "auctionId does not exist");
      require(auctionIdToAuction[auctionId].state == AuctionState.Ended, "cannot withdraw from running auction");
      require(auctionIdToAuction[auctionId].highestBidder != msg.sender, "auction winner can not withdraw");
      uint withdrawAmount = auctionBids[auctionId][msg.sender];
      if (withdrawAmount > 0) {
        // if user supplies the same auctionId multiple times in auctionIds,
        // only the first one will get a withdrawal amount
        auctionBids[auctionId][msg.sender] = 0;
        withdrawAmountTotal = withdrawAmountTotal.add(withdrawAmount);
      }
    }

    require(withdrawAmountTotal > 0, "nothing to withdraw");

    dth.transfer(msg.sender, withdrawAmountTotal);
  }

  // - bids in past auctions
  // - zone owner stake
  function withdrawDth()
    external
    onlyWhenInited
    onlyWhenTellerConnected
    updateState
  {
    uint dthWithdraw = withdrawableDth[msg.sender];
    require(dthWithdraw > 0, "nothing to withdraw");

    if (dthWithdraw > 0) {
      withdrawableDth[msg.sender] = 0;
      dth.transfer(msg.sender, dthWithdraw);
    }
  }

  function withdrawEth()
    external
    onlyWhenInited
    onlyWhenTellerConnected
    updateState
  {
    uint ethWithdraw = withdrawableEth[msg.sender];
    require(ethWithdraw > 0, "nothing to withdraw");

    if (ethWithdraw > 0) {
      withdrawableEth[msg.sender] = 0;
      msg.sender.transfer(ethWithdraw);
    }
  }

  // teller --> zone --> zonefactory --> users
  function proxyUpdateUserDailySold(address _to, uint _amount)
    external
    onlyWhenInited
    onlyWhenTellerConnected
    onlyByTellerContract
  {
    zoneFactory.proxyUpdateUserDailySold(country, zoneOwner.addr, _to, _amount); // MIGHT THROW if exceeds daily limit
  }
}
