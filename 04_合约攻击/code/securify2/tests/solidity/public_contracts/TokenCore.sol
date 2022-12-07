/**
 *Submitted for verification at Etherscan.io on 2019-10-31
*/

/**************************************************************************
 *            ____        _
 *           / ___|      | |     __ _  _   _   ___  _ __
 *          | |    _____ | |    / _` || | | | / _ \| '__|
 *          | |___|_____|| |___| (_| || |_| ||  __/| |
 *           \____|      |_____|\__,_| \__, | \___||_|
 *                                     |___/
 *
 **************************************************************************
 *
 *  The MIT License (MIT)
 *
 * Copyright (c) 2016-2019 Cyril Lapinte
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 **************************************************************************
 *
 * Flatten Contract: TokenCore
 *
 * Git Commit:
 * https://github.com/c-layer/contracts/tree/43925ba24cc22f42d0ff7711d0e169e8c2a0e09f
 *
 **************************************************************************/

// File: contracts/abstract/Storage.sol

pragma solidity >=0.5.0 <0.6.0;


/**
 * @title Storage
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 *
 * Error messages
 **/
contract Storage {

  mapping(address => address) public proxyDelegates;
  address[] public delegates;
}

// File: contracts/util/governance/Ownable.sol

pragma solidity >=0.5.0 <0.6.0;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 *
 * Error messages
 *   OW01: Only accessible as owner
 *   OW02: New owner must be non null
 */
contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner, "OW01");
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0), "OW02");
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts/operable/OperableStorage.sol

pragma solidity >=0.5.0 <0.6.0;



/**
 * @title OperableStorage
 * @dev The Operable contract enable the restrictions of operations to a set of operators
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 *
 * Error messages
 */
contract OperableStorage is Ownable, Storage {

  // Hardcoded role granting all - non sysop - privileges
  bytes32 constant internal ALL_PRIVILEGES = bytes32("AllPrivileges");
  address constant internal ALL_PROXIES = address(0x416c6c50726f78696573); // "AllProxies"

  struct RoleData {
    mapping(bytes4 => bool) privileges;
  }

  struct OperatorData {
    bytes32 coreRole;
    mapping(address => bytes32) proxyRoles;
  }

  // Mapping address => role
  // Mapping role => bytes4 => bool
  mapping (address => OperatorData) internal operators;
  mapping (bytes32 => RoleData) internal roles;

  /**
   * @dev core role
   * @param _address operator address
   */
  function coreRole(address _address) public view returns (bytes32) {
    return operators[_address].coreRole;
  }

  /**
   * @dev proxy role
   * @param _address operator address
   */
  function proxyRole(address _proxy, address _address)
    public view returns (bytes32)
  {
    return operators[_address].proxyRoles[_proxy];
  }

  /**
   * @dev has role privilege
   * @dev low level access to role privilege
   * @dev ignores ALL_PRIVILEGES role
   */
  function rolePrivilege(bytes32 _role, bytes4 _privilege)
    public view returns (bool)
  {
    return roles[_role].privileges[_privilege];
  }

  /**
   * @dev roleHasPrivilege
   */
  function roleHasPrivilege(bytes32 _role, bytes4 _privilege) public view returns (bool) {
    return (_role == ALL_PRIVILEGES) || roles[_role].privileges[_privilege];
  }

  /**
   * @dev hasCorePrivilege
   * @param _address operator address
   */
  function hasCorePrivilege(address _address, bytes4 _privilege) public view returns (bool) {
    bytes32 role = operators[_address].coreRole;
    return (role == ALL_PRIVILEGES) || roles[role].privileges[_privilege];
  }

  /**
   * @dev hasProxyPrivilege
   * @dev the default proxy role can be set with proxy address(0)
   * @param _address operator address
   */
  function hasProxyPrivilege(address _address, address _proxy, bytes4 _privilege) public view returns (bool) {
    OperatorData storage data = operators[_address];
    bytes32 role = (data.proxyRoles[_proxy] != bytes32(0)) ?
      data.proxyRoles[_proxy] : data.proxyRoles[ALL_PROXIES];
    return (role == ALL_PRIVILEGES) || roles[role].privileges[_privilege];
  }
}

// File: contracts/util/convert/BytesConvert.sol

pragma solidity >=0.5.0 <0.6.0;


/**
 * @title BytesConvert
 * @dev Convert bytes into different types
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 *
 * Error Messages:
 *   BC01: source must be a valid 32-bytes length
 *   BC02: source must not be greater than 32-bytes
 **/
library BytesConvert {

  /**
  * @dev toUint256
  */
  function toUint256(bytes memory _source) internal pure returns (uint256 result) {
    require(_source.length == 32, "BC01");
    // solhint-disable-next-line no-inline-assembly
    assembly {
      result := mload(add(_source, 0x20))
    }
  }

  /**
  * @dev toBytes32
  */
  function toBytes32(bytes memory _source) internal pure returns (bytes32 result) {
    require(_source.length <= 32, "BC02");
    // solhint-disable-next-line no-inline-assembly
    assembly {
      result := mload(add(_source, 0x20))
    }
  }
}

// File: contracts/abstract/Core.sol

pragma solidity >=0.5.0 <0.6.0;




/**
 * @title Core
 * @dev Solidity version 0.5.x prevents to mark as view
 * @dev functions using delegate call.
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 *
 * Error messages
 *   CO01: Only Proxy may access the function
 *   CO02: The proxy has no delegates
 *   CO03: Delegatecall should be successfull
 *   CO04: Invalid delegateId
 *   CO05: Proxy must exist
 **/
contract Core is Storage {
  using BytesConvert for bytes;

  modifier onlyProxy {
    require(proxyDelegates[msg.sender] != address(0), "CO01");
    _;
  }

  function delegateCall(address _proxy) internal returns (bool status)
  {
    address delegate = proxyDelegates[_proxy];
    require(delegate != address(0), "CO02");
    // solhint-disable-next-line avoid-low-level-calls
    (status, ) = delegate.delegatecall(msg.data);
    require(status, "CO03");
  }

  function delegateCallUint256(address _proxy)
    internal returns (uint256)
  {
    return delegateCallBytes(_proxy).toUint256();
  }

  function delegateCallBytes(address _proxy)
    internal returns (bytes memory result)
  {
    bool status;
    address delegate = proxyDelegates[_proxy];
    require(delegate != address(0), "CO04");
    // solhint-disable-next-line avoid-low-level-calls
    (status, result) = delegate.delegatecall(msg.data);
    require(status, "CO03");
  }

  function defineProxy(
    address _proxy,
    uint256 _delegateId)
    internal returns (bool)
  {
    require(_delegateId < delegates.length, "CO04");
    address delegate = delegates[_delegateId];

    require(_proxy != address(0), "CO05");
    proxyDelegates[_proxy] = delegate;
    return true;
  }

  function removeProxy(address _proxy)
    internal returns (bool)
  {
    delete proxyDelegates[_proxy];
    return true;
  }
}

// File: contracts/operable/OperableCore.sol

pragma solidity >=0.5.0 <0.6.0;




/**
 * @title OperableCore
 * @dev The Operable contract enable the restrictions of operations to a set of operators
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 *
 * Error messages
 *   OC01: Sender is not a system operator
 *   OC02: Sender is not a core operator
 *   OC03: Sender is not a proxy operator
 *   OC04: AllPrivileges is a reserved role
 */
contract OperableCore is Core, OperableStorage {

  constructor() public {
    operators[msg.sender].coreRole = ALL_PRIVILEGES;
    operators[msg.sender].proxyRoles[ALL_PROXIES] = ALL_PRIVILEGES;
  }

  /**
   * @dev onlySysOp modifier
   * @dev for safety reason, core owner
   * @dev can always define roles and assign or revoke operatos
   */
  modifier onlySysOp() {
    require(msg.sender == owner || hasCorePrivilege(msg.sender, msg.sig), "OC01");
    _;
  }

  /**
   * @dev onlyCoreOp modifier
   */
  modifier onlyCoreOp() {
    require(hasCorePrivilege(msg.sender, msg.sig), "OC02");
    _;
  }

  /**
   * @dev onlyProxyOp modifier
   */
  modifier onlyProxyOp(address _proxy) {
    require(hasProxyPrivilege(msg.sender, _proxy, msg.sig), "OC03");
    _;
  }

  /**
   * @dev defineRoles
   * @param _role operator role
   * @param _privileges as 4 bytes of the method
   */
  function defineRole(bytes32 _role, bytes4[] memory _privileges)
    public onlySysOp returns (bool)
  {
    require(_role != ALL_PRIVILEGES, "OC04");
    delete roles[_role];
    for (uint256 i=0; i < _privileges.length; i++) {
      roles[_role].privileges[_privileges[i]] = true;
    }
    emit RoleDefined(_role);
    return true;
  }

  /**
   * @dev assignOperators
   * @param _role operator role. May be a role not defined yet.
   * @param _operators addresses
   */
  function assignOperators(bytes32 _role, address[] memory _operators)
    public onlySysOp returns (bool)
  {
    for (uint256 i=0; i < _operators.length; i++) {
      operators[_operators[i]].coreRole = _role;
      emit OperatorAssigned(_role, _operators[i]);
    }
    return true;
  }

  /**
   * @dev assignProxyOperators
   * @param _role operator role. May be a role not defined yet.
   * @param _operators addresses
   */
  function assignProxyOperators(
    address _proxy, bytes32 _role, address[] memory _operators)
    public onlySysOp returns (bool)
  {
    for (uint256 i=0; i < _operators.length; i++) {
      operators[_operators[i]].proxyRoles[_proxy] = _role;
      emit ProxyOperatorAssigned(_proxy, _role, _operators[i]);
    }
    return true;
  }

  /**
   * @dev removeOperator
   * @param _operators addresses
   */
  function revokeOperators(address[] memory _operators)
    public onlySysOp returns (bool)
  {
    for (uint256 i=0; i < _operators.length; i++) {
      delete operators[_operators[i]];
      emit OperatorRevoked(_operators[i]);
    }
    return true;
  }

  event RoleDefined(bytes32 role);
  event OperatorAssigned(bytes32 role, address operator);
  event ProxyOperatorAssigned(address proxy, bytes32 role, address operator);
  event OperatorRevoked(address operator);
}

// File: contracts/util/math/SafeMath.sol

pragma solidity >=0.5.0 <0.6.0;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/interface/IRule.sol

pragma solidity >=0.5.0 <0.6.0;


/**
 * @title IRule
 * @dev IRule interface
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 **/
interface IRule {
  function isAddressValid(address _address) external view returns (bool);
  function isTransferValid(address _from, address _to, uint256 _amount)
    external view returns (bool);
}

// File: contracts/interface/IClaimable.sol

pragma solidity >=0.5.0 <0.6.0;


/**
 * @title IClaimable
 * @dev IClaimable interface
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 **/
contract IClaimable {
  function hasClaimsSince(address _address, uint256 at)
    external view returns (bool);
}

// File: contracts/interface/IUserRegistry.sol

pragma solidity >=0.5.0 <0.6.0;


/**
 * @title IUserRegistry
 * @dev IUserRegistry interface
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 **/
contract IUserRegistry {

  event UserRegistered(uint256 indexed userId);
  event AddressAttached(uint256 indexed userId, address address_);
  event AddressDetached(uint256 indexed userId, address address_);

  function registerManyUsersExternal(address[] calldata _addresses, uint256 _validUntilTime)
    external returns (bool);
  function registerManyUsersFullExternal(
    address[] calldata _addresses,
    uint256 _validUntilTime,
    uint256[] calldata _values) external returns (bool);
  function attachManyAddressesExternal(uint256[] calldata _userIds, address[] calldata _addresses)
    external returns (bool);
  function detachManyAddressesExternal(address[] calldata _addresses)
    external returns (bool);
  function suspendManyUsers(uint256[] calldata _userIds) external returns (bool);
  function unsuspendManyUsersExternal(uint256[] calldata _userIds) external returns (bool);
  function updateManyUsersExternal(
    uint256[] calldata _userIds,
    uint256 _validUntilTime,
    bool _suspended) external returns (bool);
  function updateManyUsersExtendedExternal(
    uint256[] calldata _userIds,
    uint256 _key, uint256 _value) external returns (bool);
  function updateManyUsersAllExtendedExternal(
    uint256[] calldata _userIds,
    uint256[] calldata _values) external returns (bool);
  function updateManyUsersFullExternal(
    uint256[] calldata _userIds,
    uint256 _validUntilTime,
    bool _suspended,
    uint256[] calldata _values) external returns (bool);

  function name() public view returns (string memory);
  function currency() public view returns (bytes32);

  function userCount() public view returns (uint256);
  function userId(address _address) public view returns (uint256);
  function validUserId(address _address) public view returns (uint256);
  function validUser(address _address, uint256[] memory _keys)
    public view returns (uint256, uint256[] memory);
  function validity(uint256 _userId) public view returns (uint256, bool);

  function extendedKeys() public view returns (uint256[] memory);
  function extended(uint256 _userId, uint256 _key)
    public view returns (uint256);
  function manyExtended(uint256 _userId, uint256[] memory _key)
    public view returns (uint256[] memory);

  function isAddressValid(address _address) public view returns (bool);
  function isValid(uint256 _userId) public view returns (bool);

  function defineExtendedKeys(uint256[] memory _extendedKeys) public returns (bool);

  function registerUser(address _address, uint256 _validUntilTime)
    public returns (bool);
  function registerUserFull(
    address _address,
    uint256 _validUntilTime,
    uint256[] memory _values) public returns (bool);

  function attachAddress(uint256 _userId, address _address) public returns (bool);
  function detachAddress(address _address) public returns (bool);
  function detachSelf() public returns (bool);
  function detachSelfAddress(address _address) public returns (bool);
  function suspendUser(uint256 _userId) public returns (bool);
  function unsuspendUser(uint256 _userId) public returns (bool);
  function updateUser(uint256 _userId, uint256 _validUntilTime, bool _suspended)
    public returns (bool);
  function updateUserExtended(uint256 _userId, uint256 _key, uint256 _value)
    public returns (bool);
  function updateUserAllExtended(uint256 _userId, uint256[] memory _values)
    public returns (bool);
  function updateUserFull(
    uint256 _userId,
    uint256 _validUntilTime,
    bool _suspended,
    uint256[] memory _values) public returns (bool);
}

// File: contracts/interface/IRatesProvider.sol

pragma solidity >=0.5.0 <0.6.0;


/**
 * @title IRatesProvider
 * @dev IRatesProvider interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 */
contract IRatesProvider {

  function defineRatesExternal(uint256[] calldata _rates) external returns (bool);

  function name() public view returns (string memory);

  function rate(bytes32 _currency) public view returns (uint256);

  function currencies() public view
    returns (bytes32[] memory, uint256[] memory, uint256);
  function rates() public view returns (uint256, uint256[] memory);

  function convert(uint256 _amount, bytes32 _fromCurrency, bytes32 _toCurrency)
    public view returns (uint256);

  function defineCurrencies(
    bytes32[] memory _currencies,
    uint256[] memory _decimals,
    uint256 _rateOffset) public returns (bool);
  function defineRates(uint256[] memory _rates) public returns (bool);

  event RateOffset(uint256 rateOffset);
  event Currencies(bytes32[] currencies, uint256[] decimals);
  event Rate(uint256 at, bytes32 indexed currency, uint256 rate);
}

// File: contracts/TokenStorage.sol

pragma solidity >=0.5.0 <0.6.0;








/**
 * @title Token storage
 * @dev Token storage
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 */
contract TokenStorage is OperableStorage {
  using SafeMath for uint256;

  enum TransferCode {
    UNKNOWN,
    OK,
    INVALID_SENDER,
    NO_RECIPIENT,
    INSUFFICIENT_TOKENS,
    LOCKED,
    FROZEN,
    RULE,
    LIMITED_RECEPTION
  }

  struct Proof {
    uint256 amount;
    uint64 startAt;
    uint64 endAt;
  }

  struct AuditData {
    uint64 createdAt;
    uint64 lastTransactionAt;
    uint64 lastEmissionAt;
    uint64 lastReceptionAt;
    uint256 cumulatedEmission;
    uint256 cumulatedReception;
  }

  struct AuditStorage {
    mapping (address => bool) selector;

    AuditData sharedData;
    mapping(uint256 => AuditData) userData;
    mapping(address => AuditData) addressData;
  }

  struct Lock {
    uint256 startAt;
    uint256 endAt;
    mapping(address => bool) exceptions;
  }

  struct TokenData {
    string name;
    string symbol;
    uint256 decimals;

    uint256 totalSupply;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    bool mintingFinished;

    uint256 allTimeIssued; // potential overflow
    uint256 allTimeRedeemed; // potential overflow
    uint256 allTimeSeized; // potential overflow

    mapping (address => Proof[]) proofs;
    mapping (address => uint256) frozenUntils;

    Lock lock;
    IRule[] rules;
    IClaimable[] claimables;
  }
  mapping (address => TokenData) internal tokens_;
  mapping (address => mapping (uint256 => AuditStorage)) internal audits;

  IUserRegistry internal userRegistry;
  IRatesProvider internal ratesProvider;

  bytes32 internal currency;
  uint256[] internal userKeys;

  string internal name_;

  /**
   * @dev currentTime()
   */
  function currentTime() internal view returns (uint64) {
    // solhint-disable-next-line not-rely-on-time
    return uint64(now);
  }

  event OraclesDefined(
    IUserRegistry userRegistry,
    IRatesProvider ratesProvider,
    bytes32 currency,
    uint256[] userKeys);
  event AuditSelectorDefined(
    address indexed scope, uint256 scopeId, address[] addresses, bool[] values);
  event Issue(address indexed token, uint256 amount);
  event Redeem(address indexed token, uint256 amount);
  event Mint(address indexed token, uint256 amount);
  event MintFinished(address indexed token);
  event ProofCreated(address indexed token, address indexed holder, uint256 proofId);
  event RulesDefined(address indexed token, IRule[] rules);
  event LockDefined(
    address indexed token,
    uint256 startAt,
    uint256 endAt,
    address[] exceptions
  );
  event Seize(address indexed token, address account, uint256 amount);
  event Freeze(address address_, uint256 until);
  event ClaimablesDefined(address indexed token, IClaimable[] claimables);
  event TokenDefined(
    address indexed token,
    uint256 delegateId,
    string name,
    string symbol,
    uint256 decimals);
  event TokenRemoved(address indexed token);
}

// File: contracts/interface/ITokenCore.sol

pragma solidity >=0.5.0 <0.6.0;







/**
 * @title ITokenCore
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 *
 * Error messages
 **/
contract ITokenCore {

  function name() public view returns (string memory);
  function oracles() public view returns
    (IUserRegistry, IRatesProvider, bytes32, uint256[] memory);

  function auditSelector(
    address _scope,
    uint256 _scopeId,
    address[] memory _addresses)
    public view returns (bool[] memory);
  function auditShared(
    address _scope,
    uint256 _scopeId) public view returns (
    uint64 createdAt,
    uint64 lastTransactionAt,
    uint64 lastEmissionAt,
    uint64 lastReceptionAt,
    uint256 cumulatedEmission,
    uint256 cumulatedReception);
  function auditUser(
    address _scope,
    uint256 _scopeId,
    uint256 _userId) public view returns (
    uint64 createdAt,
    uint64 lastTransactionAt,
    uint64 lastEmissionAt,
    uint64 lastReceptionAt,
    uint256 cumulatedEmission,
    uint256 cumulatedReception);
  function auditAddress(
    address _scope,
    uint256 _scopeId,
    address _holder) public view returns (
    uint64 createdAt,
    uint64 lastTransactionAt,
    uint64 lastEmissionAt,
    uint64 lastReceptionAt,
    uint256 cumulatedEmission,
    uint256 cumulatedReception);

  /***********  TOKEN DATA   ***********/
  function token(address _token) public view returns (
    bool mintingFinished,
    uint256 allTimeIssued,
    uint256 allTimeRedeemed,
    uint256 allTimeSeized,
    uint256[2] memory lock,
    uint256 freezedUntil,
    IRule[] memory,
    IClaimable[] memory);
  function tokenProofs(address _token, address _holder, uint256 _proofId)
    public view returns (uint256, uint64, uint64);
  function canTransfer(address, address, uint256)
    public returns (uint256);

  /***********  TOKEN ADMIN  ***********/
  function issue(address, uint256)
    public returns (bool);
  function redeem(address, uint256)
    public returns (bool);
  function mint(address, address, uint256)
    public returns (bool);
  function finishMinting(address)
    public returns (bool);
  function mintAtOnce(address, address[] memory, uint256[] memory)
    public returns (bool);
  function seize(address _token, address, uint256)
    public returns (bool);
  function freezeManyAddresses(
    address _token,
    address[] memory _addresses,
    uint256 _until) public returns (bool);
  function createProof(address, address)
    public returns (bool);
  function defineLock(address, uint256, uint256, address[] memory)
    public returns (bool);
  function defineRules(address, IRule[] memory) public returns (bool);
  function defineClaimables(address, IClaimable[] memory) public returns (bool);

  /************  CORE ADMIN  ************/
  function defineToken(
    address _token,
    uint256 _delegateId,
    string memory _name,
    string memory _symbol,
    uint256 _decimals) public returns (bool);
  function removeToken(address _token) public returns (bool);
  function defineOracles(
    IUserRegistry _userRegistry,
    IRatesProvider _ratesProvider,
    uint256[] memory _userKeys) public returns (bool);
  function defineAuditSelector(
    address _scope,
    uint256 _scopeId,
    address[] memory _selectorAddresses,
    bool[] memory _selectorValues) public returns (bool);


  event OraclesDefined(
    IUserRegistry userRegistry,
    IRatesProvider ratesProvider,
    bytes32 currency,
    uint256[] userKeys);
  event AuditSelectorDefined(
    address indexed scope, uint256 scopeId, address[] addresses, bool[] values);
  event Issue(address indexed token, uint256 amount);
  event Redeem(address indexed token, uint256 amount);
  event Mint(address indexed token, uint256 amount);
  event MintFinished(address indexed token);
  event ProofCreated(address indexed token, address holder, uint256 proofId);
  event RulesDefined(address indexed token, IRule[] rules);
  event LockDefined(
    address indexed token,
    uint256 startAt,
    uint256 endAt,
    address[] exceptions
  );
  event Seize(address indexed token, address account, uint256 amount);
  event Freeze(address address_, uint256 until);
  event ClaimablesDefined(address indexed token, IClaimable[] claimables);
  event TokenDefined(
    address indexed token,
    uint256 delegateId,
    string name,
    string symbol,
    uint256 decimals);
  event TokenRemoved(address indexed token);
}

// File: contracts/TokenCore.sol

pragma solidity >=0.5.0 <0.6.0;





/**
 * @title TokenCore
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 *
 * Error messages
 *   TC01: Currency stored values must remain consistent
 *   TC02: The audit selector definition requires the same number of addresses and values
 **/
contract TokenCore is ITokenCore, OperableCore, TokenStorage {

  /**
   * @dev constructor
   *
   * @dev It is desired for now that delegates
   * @dev cannot be changed once the core has been deployed.
   */
  constructor(string memory _name, address[] memory _delegates) public {
    name_ = _name;
    delegates = _delegates;
  }

  function name() public view returns (string memory) {
    return name_;
  }

  function oracles() public view returns
    (IUserRegistry, IRatesProvider, bytes32, uint256[] memory)
  {
    return (userRegistry, ratesProvider, currency, userKeys);
  }

  function auditSelector(
    address _scope,
    uint256 _scopeId,
    address[] memory _addresses)
    public view returns (bool[] memory)
  {
    AuditStorage storage auditStorage = audits[_scope][_scopeId];
    bool[] memory selector = new bool[](_addresses.length);
    for (uint256 i=0; i < _addresses.length; i++) {
      selector[i] = auditStorage.selector[_addresses[i]];
    }
    return selector;
  }

  function auditShared(
    address _scope,
    uint256 _scopeId) public view returns (
    uint64 createdAt,
    uint64 lastTransactionAt,
    uint64 lastEmissionAt,
    uint64 lastReceptionAt,
    uint256 cumulatedEmission,
    uint256 cumulatedReception)
  {
    AuditData memory audit = audits[_scope][_scopeId].sharedData;
    createdAt = audit.createdAt;
    lastTransactionAt = audit.lastTransactionAt;
    lastReceptionAt = audit.lastReceptionAt;
    lastEmissionAt = audit.lastEmissionAt;
    cumulatedReception = audit.cumulatedReception;
    cumulatedEmission = audit.cumulatedEmission;
  }

  function auditUser(
    address _scope,
    uint256 _scopeId,
    uint256 _userId) public view returns (
    uint64 createdAt,
    uint64 lastTransactionAt,
    uint64 lastEmissionAt,
    uint64 lastReceptionAt,
    uint256 cumulatedEmission,
    uint256 cumulatedReception)
  {
    AuditData memory audit = audits[_scope][_scopeId].userData[_userId];
    createdAt = audit.createdAt;
    lastTransactionAt = audit.lastTransactionAt;
    lastReceptionAt = audit.lastReceptionAt;
    lastEmissionAt = audit.lastEmissionAt;
    cumulatedReception = audit.cumulatedReception;
    cumulatedEmission = audit.cumulatedEmission;
  }

  function auditAddress(
    address _scope,
    uint256 _scopeId,
    address _holder) public view returns (
    uint64 createdAt,
    uint64 lastTransactionAt,
    uint64 lastEmissionAt,
    uint64 lastReceptionAt,
    uint256 cumulatedEmission,
    uint256 cumulatedReception)
  {
    AuditData memory audit = audits[_scope][_scopeId].addressData[_holder];
    createdAt = audit.createdAt;
    lastTransactionAt = audit.lastTransactionAt;
    lastReceptionAt = audit.lastReceptionAt;
    lastEmissionAt = audit.lastEmissionAt;
    cumulatedReception = audit.cumulatedReception;
    cumulatedEmission = audit.cumulatedEmission;
  }

  /**************  ERC20  **************/
  function tokenName() public view returns (string memory) {
    return tokens_[msg.sender].name;
  }

  function tokenSymbol() public view returns (string memory) {
    return tokens_[msg.sender].symbol;
  }

  function tokenDecimals() public view returns (uint256) {
    return tokens_[msg.sender].decimals;
  }

  function tokenTotalSupply() public view returns (uint256) {
    return tokens_[msg.sender].totalSupply;
  }

  function tokenBalanceOf(address _owner) public view returns (uint256) {
    return tokens_[msg.sender].balances[_owner];
  }

  function tokenAllowance(address _owner, address _spender)
    public view returns (uint256)
  {
    return tokens_[msg.sender].allowed[_owner][_spender];
  }

  function transfer(address, address, uint256)
    public onlyProxy returns (bool status)
  {
    return delegateCall(msg.sender);
  }

  function transferFrom(address, address, address, uint256)
    public onlyProxy returns (bool status)
  {
    return delegateCall(msg.sender);
  }

  function approve(address, address, uint256)
    public onlyProxy returns (bool status)
  {
    return delegateCall(msg.sender);
  }

  function increaseApproval(address, address, uint256)
    public onlyProxy returns (bool status)
  {
    return delegateCall(msg.sender);
  }

  function decreaseApproval(address, address, uint256)
    public onlyProxy returns (bool status)
  {
    return delegateCall(msg.sender);
  }

  function canTransfer(address, address, uint256)
    public onlyProxy returns (uint256)
  {
    return delegateCallUint256(msg.sender);
  }

  /***********  TOKEN DATA   ***********/
  function token(address _token) public view returns (
    bool mintingFinished,
    uint256 allTimeIssued,
    uint256 allTimeRedeemed,
    uint256 allTimeSeized,
    uint256[2] memory lock,
    uint256 frozenUntil,
    IRule[] memory rules,
    IClaimable[] memory claimables) {
    TokenData storage tokenData = tokens_[_token];

    mintingFinished = tokenData.mintingFinished;
    allTimeIssued = tokenData.allTimeIssued;
    allTimeRedeemed = tokenData.allTimeRedeemed;
    allTimeSeized = tokenData.allTimeSeized;
    lock = [ tokenData.lock.startAt, tokenData.lock.endAt ];
    frozenUntil = tokenData.frozenUntils[msg.sender];
    rules = tokenData.rules;
    claimables = tokenData.claimables;
  }

  function tokenProofs(address _token, address _holder, uint256 _proofId)
    public view returns (uint256, uint64, uint64)
  {
    Proof[] storage proofs = tokens_[_token].proofs[_holder];
    if (_proofId < proofs.length) {
      Proof storage proof = proofs[_proofId];
      return (proof.amount, proof.startAt, proof.endAt);
    }
    return (uint256(0), uint64(0), uint64(0));
  }

  /***********  TOKEN ADMIN  ***********/
  function issue(address _token, uint256)
    public onlyProxyOp(_token) returns (bool)
  {
    return delegateCall(_token);
  }

  function redeem(address _token, uint256)
    public onlyProxyOp(_token) returns (bool)
  {
    return delegateCall(_token);
  }

  function mint(address _token, address, uint256)
    public onlyProxyOp(_token) returns (bool)
  {
    return delegateCall(_token);
  }

  function finishMinting(address _token)
    public onlyProxyOp(_token) returns (bool)
  {
    return delegateCall(_token);
  }

  function mintAtOnce(address _token, address[] memory, uint256[] memory)
    public onlyProxyOp(_token) returns (bool)
  {
    return delegateCall(_token);
  }

  function seize(address _token, address, uint256)
    public onlyProxyOp(_token) returns (bool)
  {
    return delegateCall(_token);
  }

  function freezeManyAddresses(
    address _token,
    address[] memory,
    uint256) public onlyProxyOp(_token) returns (bool)
  {
    return delegateCall(_token);
  }

  function createProof(address _token, address)
    public returns (bool)
  {
    return delegateCall(_token);
  }

  function defineLock(address _token, uint256, uint256, address[] memory)
    public onlyProxyOp(_token) returns (bool)
  {
    return delegateCall(_token);
  }

  function defineRules(address _token, IRule[] memory)
    public onlyProxyOp(_token) returns (bool)
  {
    return delegateCall(_token);
  }

  function defineClaimables(address _token, IClaimable[] memory)
    public onlyProxyOp(_token) returns (bool)
  {
    return delegateCall(_token);
  }

  /************  CORE ADMIN  ************/
  function defineToken(
    address _token,
    uint256 _delegateId,
    string memory _name,
    string memory _symbol,
    uint256 _decimals)
    public onlyCoreOp returns (bool)
  {
    defineProxy(_token, _delegateId);
    TokenData storage tokenData = tokens_[_token];
    tokenData.name = _name;
    tokenData.symbol = _symbol;
    tokenData.decimals = _decimals;

    emit TokenDefined(_token, _delegateId, _name, _symbol, _decimals);
    return true;
  }

  function removeToken(address _token)
    public onlyCoreOp returns (bool)
  {
    removeProxy(_token);
    delete tokens_[_token];

    emit TokenRemoved(_token);
    return true;
  }

  function defineOracles(
    IUserRegistry _userRegistry,
    IRatesProvider _ratesProvider,
    uint256[] memory _userKeys)
    public onlyCoreOp returns (bool)
  {
    if (currency != bytes32(0)) {
      // Updating the core currency is not yet supported
      require(_userRegistry.currency() == currency, "TC01");
    } else {
      currency = _userRegistry.currency();
    }
    userRegistry = _userRegistry;
    ratesProvider = _ratesProvider;
    userKeys = _userKeys;

    emit OraclesDefined(userRegistry, ratesProvider, currency, userKeys);
    return true;
  }

  function defineAuditSelector(
    address _scope,
    uint256 _scopeId,
    address[] memory _selectorAddresses,
    bool[] memory _selectorValues) public onlyCoreOp returns (bool)
  {
    require(_selectorAddresses.length == _selectorValues.length, "TC02");

    AuditStorage storage auditStorage = audits[_scope][_scopeId];
    for (uint256 i=0; i < _selectorAddresses.length; i++) {
      auditStorage.selector[_selectorAddresses[i]] = _selectorValues[i];
    }

    emit AuditSelectorDefined(_scope, _scopeId, _selectorAddresses, _selectorValues);
    return true;
  }
}