/**
[Specs]
pattern: DAOConstantGasPattern
 */
pragma solidity ^0.5.0;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
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


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title RefundVault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress.
 */
contract Vault is Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) public deposited;
  address payable[] fundsOwners;
  address payable public wallet;

  event Refunded(address beneficiary, uint256 weiAmount);
  event Deposited(address beneficiary, uint256 weiAmount);
  event Released(address beneficiary, uint256 weiAmount);
  event PartialRefund(address beneficiary, uint256 weiAmount);

  /**
   * @param _wallet Vault address
   */
  constructor(address payable _wallet) public {
    require(_wallet != address(0));
    wallet = _wallet;
  }

  /**
   * @param beneficiary Investor address
   */
  function deposit(address payable beneficiary) onlyOwner public payable {
    deposited[beneficiary] = deposited[beneficiary].add(msg.value);
    fundsOwners.push(beneficiary);
    emit Deposited(beneficiary, msg.value);
  }

  /**
   * @param beneficiary Investor address
   */
  function release(address payable beneficiary, uint256 overflow) onlyOwner public {
    uint256 amount = deposited[beneficiary].sub(overflow);
    deposited[beneficiary] = 0;

    wallet.transfer(amount); // compliant
    if (overflow > 0) {
      beneficiary.transfer(overflow); // compliant
      emit PartialRefund(beneficiary, overflow);
    }
    emit Released(beneficiary, amount);
  }

  /**
   * @param beneficiary Investor address
   */
  function refund(address payable beneficiary) onlyOwner public {
    uint256 depositedValue = deposited[beneficiary];
    deposited[beneficiary] = 0;
    
    emit Refunded(beneficiary, depositedValue);
    beneficiary.transfer(depositedValue); // TODO: this looks ok, but is actually violates for our dao pattern due to the use in the for loop
  }

  /**
   * refunds all funds on the vault to the corresponding beneficiaries
   * @param indexes list of indexes to look up for in the fundsOwner array to refund
   */
  function refundAll(uint[] memory indexes) onlyOwner public {
    require(indexes.length <= fundsOwners.length);
    for (uint i = 0; i < indexes.length; i++) {
      refund(fundsOwners[indexes[i]]);
    }
  }
}

