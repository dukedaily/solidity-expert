pragma solidity ^0.5.12;





/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}




/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}




/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}





/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

library ERC20WithFees {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /// @notice Calls transferFrom on the token, returning the value transferred
    /// after fees.
    function safeTransferFromWithFees(IERC20 token, address from, address to, uint256 value) internal returns (uint256) {
        uint256 balancesBefore = token.balanceOf(to);
        token.safeTransferFrom(from, to, value);
        uint256 balancesAfter = token.balanceOf(to);
        return Math.min(value, balancesAfter.sub(balancesBefore));
    }
}








/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}








/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract PauserRole is Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context, PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

/**
 * @title Pausable token
 * @dev ERC20 with pausable transfers and allowances.
 *
 * Useful if you want to stop trades until the end of a crowdsale, or have
 * an emergency switch for freezing all token transfers in the event of a large
 * bug.
 */
contract ERC20Pausable is ERC20, Pausable {
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {
        return super.decreaseAllowance(spender, subtractedValue);
    }
}



/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev See {ERC20-_burnFrom}.
     */
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}

contract RenToken is Ownable, ERC20Detailed, ERC20Pausable, ERC20Burnable {

    string private constant _name = "Republic Token";
    string private constant _symbol = "REN";
    uint8 private constant _decimals = 18;

    uint256 public constant INITIAL_SUPPLY = 1000000000 * 10**uint256(_decimals);

    /// @notice The RenToken Constructor.
    constructor() ERC20Burnable() ERC20Pausable() ERC20Detailed(_name, _symbol, _decimals) public {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function transferTokens(address beneficiary, uint256 amount) public onlyOwner returns (bool) {
        // Note: The deployed version has no revert reason
        /* solium-disable-next-line error-reason */
        require(amount > 0);

        _transfer(msg.sender, beneficiary, amount);
        emit Transfer(msg.sender, beneficiary, amount);

        return true;
    }
}






/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {

    address public pendingOwner;

    modifier onlyPendingOwner() {
        require(_msgSender() == pendingOwner, "Claimable: caller is not the pending owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        pendingOwner = newOwner;
    }

    function claimOwnership() public onlyPendingOwner {
        _transferOwnership(pendingOwner);
        delete pendingOwner;
    }
}


/**
 * @notice LinkedList is a library for a circular double linked list.
 */
library LinkedList {

    /*
    * @notice A permanent NULL node (0x0) in the circular double linked list.
    * NULL.next is the head, and NULL.previous is the tail.
    */
    address public constant NULL = address(0);

    /**
    * @notice A node points to the node before it, and the node after it. If
    * node.previous = NULL, then the node is the head of the list. If
    * node.next = NULL, then the node is the tail of the list.
    */
    struct Node {
        bool inList;
        address previous;
        address next;
    }

    /**
    * @notice LinkedList uses a mapping from address to nodes. Each address
    * uniquely identifies a node, and in this way they are used like pointers.
    */
    struct List {
        mapping (address => Node) list;
    }

    /**
    * @notice Insert a new node before an existing node.
    *
    * @param self The list being used.
    * @param target The existing node in the list.
    * @param newNode The next node to insert before the target.
    */
    function insertBefore(List storage self, address target, address newNode) internal {
        require(!isInList(self, newNode), "LinkedList: already in list");
        require(isInList(self, target) || target == NULL, "LinkedList: not in list");

        // It is expected that this value is sometimes NULL.
        address prev = self.list[target].previous;

        self.list[newNode].next = target;
        self.list[newNode].previous = prev;
        self.list[target].previous = newNode;
        self.list[prev].next = newNode;

        self.list[newNode].inList = true;
    }

    /**
    * @notice Insert a new node after an existing node.
    *
    * @param self The list being used.
    * @param target The existing node in the list.
    * @param newNode The next node to insert after the target.
    */
    function insertAfter(List storage self, address target, address newNode) internal {
        require(!isInList(self, newNode), "LinkedList: already in list");
        require(isInList(self, target) || target == NULL, "LinkedList: not in list");

        // It is expected that this value is sometimes NULL.
        address n = self.list[target].next;

        self.list[newNode].previous = target;
        self.list[newNode].next = n;
        self.list[target].next = newNode;
        self.list[n].previous = newNode;

        self.list[newNode].inList = true;
    }

    /**
    * @notice Remove a node from the list, and fix the previous and next
    * pointers that are pointing to the removed node. Removing anode that is not
    * in the list will do nothing.
    *
    * @param self The list being using.
    * @param node The node in the list to be removed.
    */
    function remove(List storage self, address node) internal {
        require(isInList(self, node), "LinkedList: not in list");
        if (node == NULL) {
            return;
        }
        address p = self.list[node].previous;
        address n = self.list[node].next;

        self.list[p].next = n;
        self.list[n].previous = p;

        // Deleting the node should set this value to false, but we set it here for
        // explicitness.
        self.list[node].inList = false;
        delete self.list[node];
    }

    /**
    * @notice Insert a node at the beginning of the list.
    *
    * @param self The list being used.
    * @param node The node to insert at the beginning of the list.
    */
    function prepend(List storage self, address node) internal {
        // isInList(node) is checked in insertBefore

        insertBefore(self, begin(self), node);
    }

    /**
    * @notice Insert a node at the end of the list.
    *
    * @param self The list being used.
    * @param node The node to insert at the end of the list.
    */
    function append(List storage self, address node) internal {
        // isInList(node) is checked in insertBefore

        insertAfter(self, end(self), node);
    }

    function swap(List storage self, address left, address right) internal {
        // isInList(left) and isInList(right) are checked in remove

        address previousRight = self.list[right].previous;
        remove(self, right);
        insertAfter(self, left, right);
        remove(self, left);
        insertAfter(self, previousRight, left);
    }

    function isInList(List storage self, address node) internal view returns (bool) {
        return self.list[node].inList;
    }

    /**
    * @notice Get the node at the beginning of a double linked list.
    *
    * @param self The list being used.
    *
    * @return A address identifying the node at the beginning of the double
    * linked list.
    */
    function begin(List storage self) internal view returns (address) {
        return self.list[NULL].next;
    }

    /**
    * @notice Get the node at the end of a double linked list.
    *
    * @param self The list being used.
    *
    * @return A address identifying the node at the end of the double linked
    * list.
    */
    function end(List storage self) internal view returns (address) {
        return self.list[NULL].previous;
    }

    function next(List storage self, address node) internal view returns (address) {
        require(isInList(self, node), "LinkedList: not in list");
        return self.list[node].next;
    }

    function previous(List storage self, address node) internal view returns (address) {
        require(isInList(self, node), "LinkedList: not in list");
        return self.list[node].previous;
    }

}


contract CanReclaimTokens is Ownable {

    mapping(address => bool) private recoverableTokensBlacklist;

    function blacklistRecoverableToken(address _token) public {
        recoverableTokensBlacklist[_token] = true;
    }

    /// @notice Allow the owner of the contract to recover funds accidentally
    /// sent to the contract. To withdraw ETH, the token should be set to `0x0`.
    function recoverTokens(address _token) external onlyOwner {
        require(!recoverableTokensBlacklist[_token], "CanReclaimTokens: token is not recoverable");

        if (_token == address(0x0)) {
            msg.sender.transfer(address(this).balance);
        } else {
            ERC20(_token).transfer(msg.sender, ERC20(_token).balanceOf(address(this)));
        }
    }
}

/// @notice This contract stores data and funds for the DarknodeRegistry
/// contract. The data / fund logic and storage have been separated to improve
/// upgradability.
contract DarknodeRegistryStore is Claimable, CanReclaimTokens {
    using SafeMath for uint256;

    string public VERSION; // Passed in as a constructor parameter.

    /// @notice Darknodes are stored in the darknode struct. The owner is the
    /// address that registered the darknode, the bond is the amount of REN that
    /// was transferred during registration, and the public key is the
    /// encryption key that should be used when sending sensitive information to
    /// the darknode.
    struct Darknode {
        // The owner of a Darknode is the address that called the register
        // function. The owner is the only address that is allowed to
        // deregister the Darknode, unless the Darknode is slashed for
        // malicious behavior.
        address payable owner;

        // The bond is the amount of REN submitted as a bond by the Darknode.
        // This amount is reduced when the Darknode is slashed for malicious
        // behavior.
        uint256 bond;

        // The block number at which the Darknode is considered registered.
        uint256 registeredAt;

        // The block number at which the Darknode is considered deregistered.
        uint256 deregisteredAt;

        // The public key used by this Darknode for encrypting sensitive data
        // off chain. It is assumed that the Darknode has access to the
        // respective private key, and that there is an agreement on the format
        // of the public key.
        bytes publicKey;
    }

    /// Registry data.
    mapping(address => Darknode) private darknodeRegistry;
    LinkedList.List private darknodes;

    // RenToken.
    RenToken public ren;

    /// @notice The contract constructor.
    ///
    /// @param _VERSION A string defining the contract version.
    /// @param _ren The address of the RenToken contract.
    constructor(
        string memory _VERSION,
        RenToken _ren
    ) public {
        VERSION = _VERSION;
        ren = _ren;
        blacklistRecoverableToken(address(ren));
    }

    /// @notice Instantiates a darknode and appends it to the darknodes
    /// linked-list.
    ///
    /// @param _darknodeID The darknode's ID.
    /// @param _darknodeOwner The darknode's owner's address
    /// @param _bond The darknode's bond value
    /// @param _publicKey The darknode's public key
    /// @param _registeredAt The time stamp when the darknode is registered.
    /// @param _deregisteredAt The time stamp when the darknode is deregistered.
    function appendDarknode(
        address _darknodeID,
        address payable _darknodeOwner,
        uint256 _bond,
        bytes calldata _publicKey,
        uint256 _registeredAt,
        uint256 _deregisteredAt
    ) external onlyOwner {
        Darknode memory darknode = Darknode({
            owner: _darknodeOwner,
            bond: _bond,
            publicKey: _publicKey,
            registeredAt: _registeredAt,
            deregisteredAt: _deregisteredAt
        });
        darknodeRegistry[_darknodeID] = darknode;
        LinkedList.append(darknodes, _darknodeID);
    }

    /// @notice Returns the address of the first darknode in the store
    function begin() external view onlyOwner returns(address) {
        return LinkedList.begin(darknodes);
    }

    /// @notice Returns the address of the next darknode in the store after the
    /// given address.
    function next(address darknodeID) external view onlyOwner returns(address) {
        return LinkedList.next(darknodes, darknodeID);
    }

    /// @notice Removes a darknode from the store and transfers its bond to the
    /// owner of this contract.
    function removeDarknode(address darknodeID) external onlyOwner {
        uint256 bond = darknodeRegistry[darknodeID].bond;
        delete darknodeRegistry[darknodeID];
        LinkedList.remove(darknodes, darknodeID);
        require(ren.transfer(owner(), bond), "DarknodeRegistryStore: bond transfer failed");
    }

    /// @notice Updates the bond of a darknode. The new bond must be smaller
    /// than the previous bond of the darknode.
    function updateDarknodeBond(address darknodeID, uint256 decreasedBond) external onlyOwner {
        uint256 previousBond = darknodeRegistry[darknodeID].bond;
        require(decreasedBond < previousBond, "DarknodeRegistryStore: bond not decreased");
        darknodeRegistry[darknodeID].bond = decreasedBond;
        require(ren.transfer(owner(), previousBond.sub(decreasedBond)), "DarknodeRegistryStore: bond transfer failed");
    }

    /// @notice Updates the deregistration timestamp of a darknode.
    function updateDarknodeDeregisteredAt(address darknodeID, uint256 deregisteredAt) external onlyOwner {
        darknodeRegistry[darknodeID].deregisteredAt = deregisteredAt;
    }

    /// @notice Returns the owner of a given darknode.
    function darknodeOwner(address darknodeID) external view onlyOwner returns (address payable) {
        return darknodeRegistry[darknodeID].owner;
    }

    /// @notice Returns the bond of a given darknode.
    function darknodeBond(address darknodeID) external view onlyOwner returns (uint256) {
        return darknodeRegistry[darknodeID].bond;
    }

    /// @notice Returns the registration time of a given darknode.
    function darknodeRegisteredAt(address darknodeID) external view onlyOwner returns (uint256) {
        return darknodeRegistry[darknodeID].registeredAt;
    }

    /// @notice Returns the deregistration time of a given darknode.
    function darknodeDeregisteredAt(address darknodeID) external view onlyOwner returns (uint256) {
        return darknodeRegistry[darknodeID].deregisteredAt;
    }

    /// @notice Returns the encryption public key of a given darknode.
    function darknodePublicKey(address darknodeID) external view onlyOwner returns (bytes memory) {
        return darknodeRegistry[darknodeID].publicKey;
    }
}
interface IDarknodePaymentStore {
}

interface IDarknodePayment {
    function changeCycle() external returns (uint256);
    function store() external returns (IDarknodePaymentStore);
}

interface IDarknodeSlasher {
}

/// @notice DarknodeRegistry is responsible for the registration and
/// deregistration of Darknodes.
contract DarknodeRegistry is Claimable, CanReclaimTokens {
    using SafeMath for uint256;

    string public VERSION; // Passed in as a constructor parameter.

    /// @notice Darknode pods are shuffled after a fixed number of blocks.
    /// An Epoch stores an epoch hash used as an (insecure) RNG seed, and the
    /// blocknumber which restricts when the next epoch can be called.
    struct Epoch {
        uint256 epochhash;
        uint256 blocktime;
    }

    uint256 public numDarknodes;
    uint256 public numDarknodesNextEpoch;
    uint256 public numDarknodesPreviousEpoch;

    /// Variables used to parameterize behavior.
    uint256 public minimumBond;
    uint256 public minimumPodSize;
    uint256 public minimumEpochInterval;

    /// When one of the above variables is modified, it is only updated when the
    /// next epoch is called. These variables store the values for the next epoch.
    uint256 public nextMinimumBond;
    uint256 public nextMinimumPodSize;
    uint256 public nextMinimumEpochInterval;

    /// The current and previous epoch
    Epoch public currentEpoch;
    Epoch public previousEpoch;

    /// Republic ERC20 token contract used to transfer bonds.
    RenToken public ren;

    /// Darknode Registry Store is the storage contract for darknodes.
    DarknodeRegistryStore public store;

    /// The Darknode Payment contract for changing cycle
    IDarknodePayment public darknodePayment;

    /// Darknode Slasher allows darknodes to vote on bond slashing.
    IDarknodeSlasher public slasher;
    IDarknodeSlasher public nextSlasher;

    /// @notice Emitted when a darknode is registered.
    /// @param _operator The owner of the darknode.
    /// @param _darknodeID The ID of the darknode that was registered.
    /// @param _bond The amount of REN that was transferred as bond.
    event LogDarknodeRegistered(address indexed _operator, address indexed _darknodeID, uint256 _bond);

    /// @notice Emitted when a darknode is deregistered.
    /// @param _operator The owner of the darknode.
    /// @param _darknodeID The ID of the darknode that was deregistered.
    event LogDarknodeDeregistered(address indexed _operator, address indexed _darknodeID);

    /// @notice Emitted when a refund has been made.
    /// @param _operator The owner of the darknode.
    /// @param _amount The amount of REN that was refunded.
    event LogDarknodeOwnerRefunded(address indexed _operator, uint256 _amount);

    /// @notice Emitted when a darknode's bond is slashed.
    /// @param _operator The owner of the darknode.
    /// @param _darknodeID The ID of the darknode that was slashed.
    /// @param _challenger The address of the account that submitted the challenge.
    /// @param _percentage The total percentage  of bond slashed.
    event LogDarknodeSlashed(address indexed _operator, address indexed _darknodeID, address indexed _challenger, uint256 _percentage);

    /// @notice Emitted when a new epoch has begun.
    event LogNewEpoch(uint256 indexed epochhash);

    /// @notice Emitted when a constructor parameter has been updated.
    event LogMinimumBondUpdated(uint256 _previousMinimumBond, uint256 _nextMinimumBond);
    event LogMinimumPodSizeUpdated(uint256 _previousMinimumPodSize, uint256 _nextMinimumPodSize);
    event LogMinimumEpochIntervalUpdated(uint256 _previousMinimumEpochInterval, uint256 _nextMinimumEpochInterval);
    event LogSlasherUpdated(address _previousSlasher, address _nextSlasher);
    event LogDarknodePaymentUpdated(IDarknodePayment _previousDarknodePayment, IDarknodePayment _nextDarknodePayment);

    /// @notice Restrict a function to the owner that registered the darknode.
    modifier onlyDarknodeOwner(address _darknodeID) {
        require(store.darknodeOwner(_darknodeID) == msg.sender, "DarknodeRegistry: must be darknode owner");
        _;
    }

    /// @notice Restrict a function to unregistered darknodes.
    modifier onlyRefunded(address _darknodeID) {
        require(isRefunded(_darknodeID), "DarknodeRegistry: must be refunded or never registered");
        _;
    }

    /// @notice Restrict a function to refundable darknodes.
    modifier onlyRefundable(address _darknodeID) {
        require(isRefundable(_darknodeID), "DarknodeRegistry: must be deregistered for at least one epoch");
        _;
    }

    /// @notice Restrict a function to registered nodes without a pending
    /// deregistration.
    modifier onlyDeregisterable(address _darknodeID) {
        require(isDeregisterable(_darknodeID), "DarknodeRegistry: must be deregisterable");
        _;
    }

    /// @notice Restrict a function to the Slasher contract.
    modifier onlySlasher() {
        require(address(slasher) == msg.sender, "DarknodeRegistry: must be slasher");
        _;
    }

    /// @notice The contract constructor.
    ///
    /// @param _VERSION A string defining the contract version.
    /// @param _renAddress The address of the RenToken contract.
    /// @param _storeAddress The address of the DarknodeRegistryStore contract.
    /// @param _minimumBond The minimum bond amount that can be submitted by a
    ///        Darknode.
    /// @param _minimumPodSize The minimum size of a Darknode pod.
    /// @param _minimumEpochIntervalSeconds The minimum number of seconds between epochs.
    constructor(
        string memory _VERSION,
        RenToken _renAddress,
        DarknodeRegistryStore _storeAddress,
        uint256 _minimumBond,
        uint256 _minimumPodSize,
        uint256 _minimumEpochIntervalSeconds
    ) public {
        VERSION = _VERSION;

        store = _storeAddress;
        ren = _renAddress;

        minimumBond = _minimumBond;
        nextMinimumBond = minimumBond;

        minimumPodSize = _minimumPodSize;
        nextMinimumPodSize = minimumPodSize;

        minimumEpochInterval = _minimumEpochIntervalSeconds;
        nextMinimumEpochInterval = minimumEpochInterval;

        currentEpoch = Epoch({
            epochhash: uint256(blockhash(block.number - 1)),
            blocktime: block.timestamp
        });
        numDarknodes = 0;
        numDarknodesNextEpoch = 0;
        numDarknodesPreviousEpoch = 0;
    }

    /// @notice Register a darknode and transfer the bond to this contract.
    /// Before registering, the bond transfer must be approved in the REN
    /// contract. The caller must provide a public encryption key for the
    /// darknode. The darknode will remain pending registration until the next
    /// epoch. Only after this period can the darknode be deregistered. The
    /// caller of this method will be stored as the owner of the darknode.
    ///
    /// @param _darknodeID The darknode ID that will be registered.
    /// @param _publicKey The public key of the darknode. It is stored to allow
    ///        other darknodes and traders to encrypt messages to the trader.
    function register(address _darknodeID, bytes calldata _publicKey) external onlyRefunded(_darknodeID) {
        // Use the current minimum bond as the darknode's bond.
        uint256 bond = minimumBond;

        // Transfer bond to store
        require(ren.transferFrom(msg.sender, address(store), bond), "DarknodeRegistry: bond transfer failed");

        // Flag this darknode for registration
        store.appendDarknode(
            _darknodeID,
            msg.sender,
            bond,
            _publicKey,
            currentEpoch.blocktime.add(minimumEpochInterval),
            0
        );

        numDarknodesNextEpoch = numDarknodesNextEpoch.add(1);

        // Emit an event.
        emit LogDarknodeRegistered(msg.sender, _darknodeID, bond);
    }

    /// @notice Deregister a darknode. The darknode will not be deregistered
    /// until the end of the epoch. After another epoch, the bond can be
    /// refunded by calling the refund method.
    /// @param _darknodeID The darknode ID that will be deregistered. The caller
    ///        of this method store.darknodeRegisteredAt(_darknodeID) must be
    //         the owner of this darknode.
    function deregister(address _darknodeID) external onlyDeregisterable(_darknodeID) onlyDarknodeOwner(_darknodeID) {
        deregisterDarknode(_darknodeID);
    }

    /// @notice Progress the epoch if it is possible to do so. This captures
    /// the current timestamp and current blockhash and overrides the current
    /// epoch.
    function epoch() external {
        if (previousEpoch.blocktime == 0) {
            // The first epoch must be called by the owner of the contract
            require(msg.sender == owner(), "DarknodeRegistry: not authorized (first epochs)");
        }

        // Require that the epoch interval has passed
        require(block.timestamp >= currentEpoch.blocktime.add(minimumEpochInterval), "DarknodeRegistry: epoch interval has not passed");
        uint256 epochhash = uint256(blockhash(block.number - 1));

        // Update the epoch hash and timestamp
        previousEpoch = currentEpoch;
        currentEpoch = Epoch({
            epochhash: epochhash,
            blocktime: block.timestamp
        });

        // Update the registry information
        numDarknodesPreviousEpoch = numDarknodes;
        numDarknodes = numDarknodesNextEpoch;

        // If any update functions have been called, update the values now
        if (nextMinimumBond != minimumBond) {
            minimumBond = nextMinimumBond;
            emit LogMinimumBondUpdated(minimumBond, nextMinimumBond);
        }
        if (nextMinimumPodSize != minimumPodSize) {
            minimumPodSize = nextMinimumPodSize;
            emit LogMinimumPodSizeUpdated(minimumPodSize, nextMinimumPodSize);
        }
        if (nextMinimumEpochInterval != minimumEpochInterval) {
            minimumEpochInterval = nextMinimumEpochInterval;
            emit LogMinimumEpochIntervalUpdated(minimumEpochInterval, nextMinimumEpochInterval);
        }
        if (nextSlasher != slasher) {
            slasher = nextSlasher;
            emit LogSlasherUpdated(address(slasher), address(nextSlasher));
        }
        if (address(darknodePayment) != address(0x0)) {
            darknodePayment.changeCycle();
        }

        // Emit an event
        emit LogNewEpoch(epochhash);
    }

    /// @notice Allows the contract owner to initiate an ownership transfer of
    /// the DarknodeRegistryStore.
    /// @param _newOwner The address to transfer the ownership to.
    function transferStoreOwnership(DarknodeRegistry _newOwner) external onlyOwner {
        store.transferOwnership(address(_newOwner));
        _newOwner.claimStoreOwnership();
    }

    /// @notice Claims ownership of the store passed in to the constructor.
    /// `transferStoreOwnership` must have previously been called when
    /// transferring from another Darknode Registry.
    function claimStoreOwnership() external {
        store.claimOwnership();
    }

    /// @notice Allows the contract owner to update the address of the
    /// darknode payment contract.
    /// @param _darknodePayment The address of the Darknode Payment
    /// contract.
    function updateDarknodePayment(IDarknodePayment _darknodePayment) external onlyOwner {
        require(address(_darknodePayment) != address(0x0), "DarknodeRegistry: invalid Darknode Payment address");
        IDarknodePayment previousDarknodePayment = darknodePayment;
        darknodePayment = _darknodePayment;
        emit LogDarknodePaymentUpdated(previousDarknodePayment, darknodePayment);
    }

    /// @notice Allows the contract owner to update the minimum bond.
    /// @param _nextMinimumBond The minimum bond amount that can be submitted by
    ///        a darknode.
    function updateMinimumBond(uint256 _nextMinimumBond) external onlyOwner {
        // Will be updated next epoch
        nextMinimumBond = _nextMinimumBond;
    }

    /// @notice Allows the contract owner to update the minimum pod size.
    /// @param _nextMinimumPodSize The minimum size of a pod.
    function updateMinimumPodSize(uint256 _nextMinimumPodSize) external onlyOwner {
        // Will be updated next epoch
        nextMinimumPodSize = _nextMinimumPodSize;
    }

    /// @notice Allows the contract owner to update the minimum epoch interval.
    /// @param _nextMinimumEpochInterval The minimum number of blocks between epochs.
    function updateMinimumEpochInterval(uint256 _nextMinimumEpochInterval) external onlyOwner {
        // Will be updated next epoch
        nextMinimumEpochInterval = _nextMinimumEpochInterval;
    }

    /// @notice Allow the contract owner to update the DarknodeSlasher contract
    /// address.
    /// @param _slasher The new slasher address.
    function updateSlasher(IDarknodeSlasher _slasher) external onlyOwner {
        require(address(_slasher) != address(0), "DarknodeRegistry: invalid slasher address");
        nextSlasher = _slasher;
    }

    /// @notice Allow the DarknodeSlasher contract to slash a portion of darknode's
    ///         bond and deregister it.
    /// @param _guilty The guilty prover whose bond is being slashed.
    /// @param _challenger The challenger who should receive a portion of the bond as reward.
    /// @param _percentage The total percentage  of bond to be slashed.
    function slash(address _guilty, address _challenger, uint256 _percentage)
        external
        onlySlasher
    {
        require(_percentage <= 100, "DarknodeRegistry: invalid percent");

        // If the darknode has not been deregistered then deregister it
        if (isDeregisterable(_guilty)) {
            deregisterDarknode(_guilty);
        }

        uint256 totalBond = store.darknodeBond(_guilty);
        uint256 penalty = totalBond.div(100).mul(_percentage);
        uint256 reward = penalty.div(2);
        if (reward > 0) {
            // Slash the bond of the failed prover
            store.updateDarknodeBond(_guilty, totalBond.sub(penalty));

            // Distribute the remaining bond into the darknode payment reward pool
            require(address(darknodePayment) != address(0x0), "DarknodeRegistry: invalid payment address");
            require(ren.transfer(address(darknodePayment.store()), reward), "DarknodeRegistry: reward transfer failed");
            require(ren.transfer(_challenger, reward), "DarknodeRegistry: reward transfer failed");
        }

        emit LogDarknodeSlashed(store.darknodeOwner(_guilty), _guilty, _challenger, _percentage);
    }

    /// @notice Refund the bond of a deregistered darknode. This will make the
    /// darknode available for registration again. Anyone can call this function
    /// but the bond will always be refunded to the darknode owner.
    ///
    /// @param _darknodeID The darknode ID that will be refunded. The caller
    ///        of this method must be the owner of this darknode.
    function refund(address _darknodeID) external onlyRefundable(_darknodeID) {
        address darknodeOwner = store.darknodeOwner(_darknodeID);

        // Remember the bond amount
        uint256 amount = store.darknodeBond(_darknodeID);

        // Erase the darknode from the registry
        store.removeDarknode(_darknodeID);

        // Refund the owner by transferring REN
        require(ren.transfer(darknodeOwner, amount), "DarknodeRegistry: bond transfer failed");

        // Emit an event.
        emit LogDarknodeOwnerRefunded(darknodeOwner, amount);
    }

    /// @notice Retrieves the address of the account that registered a darknode.
    /// @param _darknodeID The ID of the darknode to retrieve the owner for.
    function getDarknodeOwner(address _darknodeID) external view returns (address payable) {
        return store.darknodeOwner(_darknodeID);
    }

    /// @notice Retrieves the bond amount of a darknode in 10^-18 REN.
    /// @param _darknodeID The ID of the darknode to retrieve the bond for.
    function getDarknodeBond(address _darknodeID) external view returns (uint256) {
        return store.darknodeBond(_darknodeID);
    }

    /// @notice Retrieves the encryption public key of the darknode.
    /// @param _darknodeID The ID of the darknode to retrieve the public key for.
    function getDarknodePublicKey(address _darknodeID) external view returns (bytes memory) {
        return store.darknodePublicKey(_darknodeID);
    }

    /// @notice Retrieves a list of darknodes which are registered for the
    /// current epoch.
    /// @param _start A darknode ID used as an offset for the list. If _start is
    ///        0x0, the first dark node will be used. _start won't be
    ///        included it is not registered for the epoch.
    /// @param _count The number of darknodes to retrieve starting from _start.
    ///        If _count is 0, all of the darknodes from _start are
    ///        retrieved. If _count is more than the remaining number of
    ///        registered darknodes, the rest of the list will contain
    ///        0x0s.
    function getDarknodes(address _start, uint256 _count) external view returns (address[] memory) {
        uint256 count = _count;
        if (count == 0) {
            count = numDarknodes;
        }
        return getDarknodesFromEpochs(_start, count, false);
    }

    /// @notice Retrieves a list of darknodes which were registered for the
    /// previous epoch. See `getDarknodes` for the parameter documentation.
    function getPreviousDarknodes(address _start, uint256 _count) external view returns (address[] memory) {
        uint256 count = _count;
        if (count == 0) {
            count = numDarknodesPreviousEpoch;
        }
        return getDarknodesFromEpochs(_start, count, true);
    }

    /// @notice Returns whether a darknode is scheduled to become registered
    /// at next epoch.
    /// @param _darknodeID The ID of the darknode to return
    function isPendingRegistration(address _darknodeID) external view returns (bool) {
        uint256 registeredAt = store.darknodeRegisteredAt(_darknodeID);
        return registeredAt != 0 && registeredAt > currentEpoch.blocktime;
    }

    /// @notice Returns if a darknode is in the pending deregistered state. In
    /// this state a darknode is still considered registered.
    function isPendingDeregistration(address _darknodeID) external view returns (bool) {
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        return deregisteredAt != 0 && deregisteredAt > currentEpoch.blocktime;
    }

    /// @notice Returns if a darknode is in the deregistered state.
    function isDeregistered(address _darknodeID) public view returns (bool) {
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        return deregisteredAt != 0 && deregisteredAt <= currentEpoch.blocktime;
    }

    /// @notice Returns if a darknode can be deregistered. This is true if the
    /// darknodes is in the registered state and has not attempted to
    /// deregister yet.
    function isDeregisterable(address _darknodeID) public view returns (bool) {
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        // The Darknode is currently in the registered state and has not been
        // transitioned to the pending deregistration, or deregistered, state
        return isRegistered(_darknodeID) && deregisteredAt == 0;
    }

    /// @notice Returns if a darknode is in the refunded state. This is true
    /// for darknodes that have never been registered, or darknodes that have
    /// been deregistered and refunded.
    function isRefunded(address _darknodeID) public view returns (bool) {
        uint256 registeredAt = store.darknodeRegisteredAt(_darknodeID);
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        return registeredAt == 0 && deregisteredAt == 0;
    }

    /// @notice Returns if a darknode is refundable. This is true for darknodes
    /// that have been in the deregistered state for one full epoch.
    function isRefundable(address _darknodeID) public view returns (bool) {
        return isDeregistered(_darknodeID) && store.darknodeDeregisteredAt(_darknodeID) <= previousEpoch.blocktime;
    }

    /// @notice Returns if a darknode is in the registered state.
    function isRegistered(address _darknodeID) public view returns (bool) {
        return isRegisteredInEpoch(_darknodeID, currentEpoch);
    }

    /// @notice Returns if a darknode was in the registered state last epoch.
    function isRegisteredInPreviousEpoch(address _darknodeID) public view returns (bool) {
        return isRegisteredInEpoch(_darknodeID, previousEpoch);
    }

    /// @notice Returns if a darknode was in the registered state for a given
    /// epoch.
    /// @param _darknodeID The ID of the darknode
    /// @param _epoch One of currentEpoch, previousEpoch
    function isRegisteredInEpoch(address _darknodeID, Epoch memory _epoch) private view returns (bool) {
        uint256 registeredAt = store.darknodeRegisteredAt(_darknodeID);
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        bool registered = registeredAt != 0 && registeredAt <= _epoch.blocktime;
        bool notDeregistered = deregisteredAt == 0 || deregisteredAt > _epoch.blocktime;
        // The Darknode has been registered and has not yet been deregistered,
        // although it might be pending deregistration
        return registered && notDeregistered;
    }

    /// @notice Returns a list of darknodes registered for either the current
    /// or the previous epoch. See `getDarknodes` for documentation on the
    /// parameters `_start` and `_count`.
    /// @param _usePreviousEpoch If true, use the previous epoch, otherwise use
    ///        the current epoch.
    function getDarknodesFromEpochs(address _start, uint256 _count, bool _usePreviousEpoch) private view returns (address[] memory) {
        uint256 count = _count;
        if (count == 0) {
            count = numDarknodes;
        }

        address[] memory nodes = new address[](count);

        // Begin with the first node in the list
        uint256 n = 0;
        address next = _start;
        if (next == address(0)) {
            next = store.begin();
        }

        // Iterate until all registered Darknodes have been collected
        while (n < count) {
            if (next == address(0)) {
                break;
            }
            // Only include Darknodes that are currently registered
            bool includeNext;
            if (_usePreviousEpoch) {
                includeNext = isRegisteredInPreviousEpoch(next);
            } else {
                includeNext = isRegistered(next);
            }
            if (!includeNext) {
                next = store.next(next);
                continue;
            }
            nodes[n] = next;
            next = store.next(next);
            n += 1;
        }
        return nodes;
    }

    /// Private function called by `deregister` and `slash`
    function deregisterDarknode(address _darknodeID) private {
        // Flag the darknode for deregistration
        store.updateDarknodeDeregisteredAt(_darknodeID, currentEpoch.blocktime.add(minimumEpochInterval));
        numDarknodesNextEpoch = numDarknodesNextEpoch.sub(1);

        // Emit an event
        emit LogDarknodeDeregistered(msg.sender, _darknodeID);
    }
}




/// @notice DarknodePaymentStore is responsible for tracking balances which have
///         been allocated to the darknodes. It is also responsible for holding
///         the tokens to be paid out to darknodes.
contract DarknodePaymentStore is Claimable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    using ERC20WithFees for ERC20;

    string public VERSION; // Passed in as a constructor parameter.

    /// @notice The special address for Ether.
    address constant public ETHEREUM = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// @notice Mapping of darknode -> token -> balance
    mapping(address => mapping(address => uint256)) public darknodeBalances;

    /// @notice Mapping of token -> lockedAmount
    mapping(address => uint256) public lockedBalances;

    /// @notice The contract constructor.
    ///
    /// @param _VERSION A string defining the contract version.
    constructor(
        string memory _VERSION
    ) public {
        VERSION = _VERSION;
    }

    /// @notice Allow direct ETH payments to be made to the DarknodePaymentStore.
    function () external payable {
    }

    /// @notice Get the total balance of the contract for a particular token
    ///
    /// @param _token The token to check balance of
    /// @return The total balance of the contract
    function totalBalance(address _token) public view returns (uint256) {
        if (_token == ETHEREUM) {
            return address(this).balance;
        } else {
            return ERC20(_token).balanceOf(address(this));
        }
    }

    /// @notice Get the available balance of the contract for a particular token
    ///         This is the free amount which has not yet been allocated to
    ///         darknodes.
    ///
    /// @param _token The token to check balance of
    /// @return The available balance of the contract
    function availableBalance(address _token) public view returns (uint256) {
        return totalBalance(_token).sub(lockedBalances[_token]);
    }

    /// @notice Increments the amount of funds allocated to a particular
    ///         darknode.
    ///
    /// @param _darknode The address of the darknode to increase balance of
    /// @param _token The token which the balance should be incremented
    /// @param _amount The amount that the balance should be incremented by
    function incrementDarknodeBalance(address _darknode, address _token, uint256 _amount) external onlyOwner {
        require(_amount > 0, "DarknodePaymentStore: invalid amount");
        require(availableBalance(_token) >= _amount, "DarknodePaymentStore: insufficient contract balance");

        darknodeBalances[_darknode][_token] = darknodeBalances[_darknode][_token].add(_amount);
        lockedBalances[_token] = lockedBalances[_token].add(_amount);
    }

    /// @notice Transfers an amount out of balance to a specified address
    ///
    /// @param _darknode The address of the darknode
    /// @param _token Which token to transfer
    /// @param _amount The amount to transfer
    /// @param _recipient The address to withdraw it to
    function transfer(address _darknode, address _token, uint256 _amount, address payable _recipient) external onlyOwner {
        require(darknodeBalances[_darknode][_token] >= _amount, "DarknodePaymentStore: insufficient darknode balance");
        darknodeBalances[_darknode][_token] = darknodeBalances[_darknode][_token].sub(_amount);
        lockedBalances[_token] = lockedBalances[_token].sub(_amount);

        if (_token == ETHEREUM) {
            _recipient.transfer(_amount);
        } else {
            ERC20(_token).safeTransfer(_recipient, _amount);
        }
    }

}

/// @notice DarknodePayment is responsible for paying off darknodes for their
///         computation.
contract DarknodePayment is Claimable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    using ERC20WithFees for ERC20;

    string public VERSION; // Passed in as a constructor parameter.

    /// @notice The special address for Ether.
    address constant public ETHEREUM = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    DarknodeRegistry public darknodeRegistry; // Passed in as a constructor parameter.

    /// @notice DarknodePaymentStore is the storage contract for darknode
    ///         payments.
    DarknodePaymentStore public store; // Passed in as a constructor parameter.

    /// @notice The address that can call changeCycle()
    //          This defaults to the owner but should be changed to the DarknodeRegistry.
    address public cycleChanger;

    uint256 public currentCycle;
    uint256 public previousCycle;

    /// @notice The list of tokens that will be registered next cycle.
    ///         We only update the shareCount at the change of cycle to
    ///         prevent the number of shares from changing.
    address[] public pendingTokens;

    /// @notice The list of tokens which are already registered and rewards can
    ///         be claimed for.
    address[] public registeredTokens;

    /// @notice Mapping from token -> index. Index starts from 1. 0 means not in
    ///         list.
    mapping(address => uint256) public registeredTokenIndex;

    /// @notice Mapping from token -> amount.
    ///         The amount of rewards allocated for all darknodes to claim into
    ///         their account.
    mapping(address => uint256) public unclaimedRewards;

    /// @notice Mapping from token -> amount.
    ///         The amount of rewards allocated for each darknode.
    mapping(address => uint256) public previousCycleRewardShare;

    /// @notice The time that the current cycle started.
    uint256 public cycleStartTime;

    /// @notice The staged payout percentage to the darknodes per cycle
    uint256 public nextCyclePayoutPercent;

    /// @notice The current cycle payout percentage to the darknodes
    uint256 public currentCyclePayoutPercent;

    /// @notice Mapping of darknode -> cycle -> already_claimed
    ///         Used to keep track of which darknodes have already claimed their
    ///         rewards.
    mapping(address => mapping(uint256 => bool)) public rewardClaimed;

    /// @notice Emitted when a darknode claims their share of reward
    /// @param _darknode The darknode which claimed
    /// @param _cycle The cycle that the darknode claimed for
    event LogDarknodeClaim(address indexed _darknode, uint256 _cycle);

    /// @notice Emitted when someone pays the DarknodePayment contract
    /// @param _payer The darknode which claimed
    /// @param _amount The cycle that the darknode claimed for
    /// @param _token The address of the token that was transferred
    event LogPaymentReceived(address indexed _payer, uint256 _amount, address indexed _token);

    /// @notice Emitted when a darknode calls withdraw
    /// @param _payee The address of the darknode which withdrew
    /// @param _value The amount of DAI withdrawn
    /// @param _token The address of the token that was withdrawn
    event LogDarknodeWithdrew(address indexed _payee, uint256 _value, address indexed _token);

    /// @notice Emitted when the payout percent changes
    /// @param _newPercent The new percent
    /// @param _oldPercent The old percent
    event LogPayoutPercentChanged(uint256 _newPercent, uint256 _oldPercent);

    /// @notice Emitted when the CycleChanger address changes
    /// @param _newCycleChanger The new CycleChanger
    /// @param _oldCycleChanger The old CycleChanger
    event LogCycleChangerChanged(address _newCycleChanger, address _oldCycleChanger);

    /// @notice Emitted when a new token is registered
    /// @param _token The token that was registered
    event LogTokenRegistered(address _token);

    /// @notice Emitted when a token is deregistered
    /// @param _token The token that was deregistered
    event LogTokenDeregistered(address _token);

    /// @notice Emitted when the DarknodeRegistry is updated.
    /// @param _previousDarknodeRegistry The address of the old registry.
    /// @param _nextDarknodeRegistry The address of the new registry.
    event LogDarknodeRegistryUpdated(DarknodeRegistry _previousDarknodeRegistry, DarknodeRegistry _nextDarknodeRegistry);

    /// @notice Restrict a function registered dark nodes to call a function.
    modifier onlyDarknode(address _darknode) {
        require(darknodeRegistry.isRegistered(_darknode), "DarknodePayment: darknode is not registered");
        _;
    }

    /// @notice Restrict a function to have a valid percentage
    modifier validPercent(uint256 _percent) {
        require(_percent <= 100, "DarknodePayment: invalid percentage");
        _;
    }

    /// @notice The contract constructor. Starts the current cycle using the
    ///         time of deploy.
    ///
    /// @param _VERSION A string defining the contract version.
    /// @param _darknodeRegistry The address of the DarknodeRegistry contract
    /// @param _darknodePaymentStore The address of the DarknodePaymentStore
    ///        contract
    constructor(
        string memory _VERSION,
        DarknodeRegistry _darknodeRegistry,
        DarknodePaymentStore _darknodePaymentStore,
        uint256 _cyclePayoutPercent
    ) public validPercent(_cyclePayoutPercent) {
        VERSION = _VERSION;
        darknodeRegistry = _darknodeRegistry;
        store = _darknodePaymentStore;
        nextCyclePayoutPercent = _cyclePayoutPercent;
        // Default the cycleChanger to owner
        cycleChanger = msg.sender;

        // Start the current cycle
        (currentCycle, cycleStartTime) = darknodeRegistry.currentEpoch();
        currentCyclePayoutPercent = nextCyclePayoutPercent;
    }

    /// @notice Allows the contract owner to update the address of the
    /// darknode registry contract.
    /// @param _darknodeRegistry The address of the Darknode Registry
    /// contract.
    function updateDarknodeRegistry(DarknodeRegistry _darknodeRegistry) external onlyOwner {
        require(address(_darknodeRegistry) != address(0x0), "DarknodePayment: invalid Darknode Registry address");
        DarknodeRegistry previousDarknodeRegistry = darknodeRegistry;
        darknodeRegistry = _darknodeRegistry;
        emit LogDarknodeRegistryUpdated(previousDarknodeRegistry, darknodeRegistry);
    }

    /// @notice Transfers the funds allocated to the darknode to the darknode
    ///         owner.
    ///
    /// @param _darknode The address of the darknode
    /// @param _token Which token to transfer
    function withdraw(address _darknode, address _token) public {
        address payable darknodeOwner = darknodeRegistry.getDarknodeOwner(_darknode);
        require(darknodeOwner != address(0x0), "DarknodePayment: invalid darknode owner");

        uint256 amount = store.darknodeBalances(_darknode, _token);
        require(amount > 0, "DarknodePayment: nothing to withdraw");

        store.transfer(_darknode, _token, amount, darknodeOwner);
        emit LogDarknodeWithdrew(_darknode, amount, _token);
    }

    function withdrawMultiple(address _darknode, address[] calldata _tokens) external {
        for (uint i = 0; i < _tokens.length; i++) {
            withdraw(_darknode, _tokens[i]);
        }
    }

    /// @notice Forward all payments to the DarknodePaymentStore.
    function () external payable {
        address(store).transfer(msg.value);
        emit LogPaymentReceived(msg.sender, msg.value, ETHEREUM);
    }

    /// @notice The current balance of the contract available as reward for the
    ///         current cycle
    function currentCycleRewardPool(address _token) external view returns (uint256) {
        uint256 total = store.availableBalance(_token).sub(unclaimedRewards[_token]);
        return total.div(100).mul(currentCyclePayoutPercent);
    }

    function darknodeBalances(address _darknodeID, address _token) external view returns (uint256) {
        return store.darknodeBalances(_darknodeID, _token);
    }

    /// @notice Changes the current cycle.
    function changeCycle() external returns (uint256) {
        require(msg.sender == cycleChanger, "DarknodePayment: not cycle changer");

        // Snapshot balances for the past cycle
        uint arrayLength = registeredTokens.length;
        for (uint i = 0; i < arrayLength; i++) {
            _snapshotBalance(registeredTokens[i]);
        }

        // Start a new cycle
        previousCycle = currentCycle;
        (currentCycle, cycleStartTime) = darknodeRegistry.currentEpoch();
        currentCyclePayoutPercent = nextCyclePayoutPercent;

        // Update the list of registeredTokens
        _updateTokenList();
        return currentCycle;
    }

    /// @notice Deposits token into the contract to be paid to the Darknodes
    ///
    /// @param _value The amount of token deposit in the token's smallest unit.
    /// @param _token The token address
    function deposit(uint256 _value, address _token) external payable {
        uint256 receivedValue;
        if (_token == ETHEREUM) {
            require(_value == msg.value, "DarknodePayment: mismatched deposit value");
            receivedValue = msg.value;
            address(store).transfer(msg.value);
        } else {
            require(msg.value == 0, "DarknodePayment: unexpected ether transfer");
            // Forward the funds to the store
            receivedValue = ERC20(_token).safeTransferFromWithFees(msg.sender, address(store), _value);
        }
        emit LogPaymentReceived(msg.sender, receivedValue, _token);
    }

    /// @notice Forwards any tokens that have been sent to the DarknodePayment contract
    ///         probably by mistake, to the DarknodePaymentStore.
    ///
    /// @param _token The token address
    function forward(address _token) external {
        if (_token == ETHEREUM) {
            // Its unlikely that ETH will need to be forwarded, but it is
            // possible. For example - if ETH had already been sent to the
            // contract's address before it was deployed, or if funds are sent
            // to it as part of a contract's self-destruct.
            address(store).transfer(address(this).balance);
        } else {
            ERC20(_token).safeTransfer(address(store), ERC20(_token).balanceOf(address(this)));
        }
    }

    /// @notice Claims the rewards allocated to the darknode last epoch.
    /// @param _darknode The address of the darknode to claim
    function claim(address _darknode) external onlyDarknode(_darknode) {
        require(darknodeRegistry.isRegisteredInPreviousEpoch(_darknode), "DarknodePayment: cannot claim for this epoch");
        // Claim share of rewards allocated for last cycle
        _claimDarknodeReward(_darknode);
        emit LogDarknodeClaim(_darknode, previousCycle);
    }

    /// @notice Adds tokens to be payable. Registration is pending until next
    ///         cycle.
    ///
    /// @param _token The address of the token to be registered.
    function registerToken(address _token) external onlyOwner {
        require(registeredTokenIndex[_token] == 0, "DarknodePayment: token already registered");
        require(!tokenPendingRegistration(_token), "DarknodePayment: token already pending registration");
        pendingTokens.push(_token);
    }

    function tokenPendingRegistration(address _token) public view returns (bool) {
        uint arrayLength = pendingTokens.length;
        for (uint i = 0; i < arrayLength; i++) {
            if (pendingTokens[i] == _token) {
                return true;
            }
        }
        return false;
    }

    /// @notice Removes a token from the list of supported tokens.
    ///         Deregistration is pending until next cycle.
    ///
    /// @param _token The address of the token to be deregistered.
    function deregisterToken(address _token) external onlyOwner {
        require(registeredTokenIndex[_token] > 0, "DarknodePayment: token not registered");
        _deregisterToken(_token);
    }

    /// @notice Updates the CycleChanger contract address.
    ///
    /// @param _addr The new CycleChanger contract address.
    function updateCycleChanger(address _addr) external onlyOwner {
        require(_addr != address(0), "DarknodePayment: invalid contract address");
        emit LogCycleChangerChanged(_addr, cycleChanger);
        cycleChanger = _addr;
    }

    /// @notice Updates payout percentage
    ///
    /// @param _percent The percentage of payout for darknodes.
    function updatePayoutPercentage(uint256 _percent) external onlyOwner validPercent(_percent) {
        uint256 oldPayoutPercent = nextCyclePayoutPercent;
        nextCyclePayoutPercent = _percent;
        emit LogPayoutPercentChanged(nextCyclePayoutPercent, oldPayoutPercent);
    }

    /// @notice Allows the contract owner to initiate an ownership transfer of
    ///         the DarknodePaymentStore.
    ///
    /// @param _newOwner The address to transfer the ownership to.
    function transferStoreOwnership(DarknodePayment _newOwner) external onlyOwner {
        store.transferOwnership(address(_newOwner));
        _newOwner.claimStoreOwnership();
    }

    /// @notice Claims ownership of the store passed in to the constructor.
    ///         `transferStoreOwnership` must have previously been called when
    ///         transferring from another DarknodePaymentStore.
    function claimStoreOwnership() external {
        store.claimOwnership();
    }

    /// @notice Claims the darknode reward for all registered tokens into
    ///         darknodeBalances in the DarknodePaymentStore.
    ///         Rewards can only be claimed once per cycle.
    ///
    /// @param _darknode The address to the darknode to claim rewards for
    function _claimDarknodeReward(address _darknode) private {
        require(!rewardClaimed[_darknode][previousCycle], "DarknodePayment: reward already claimed");
        rewardClaimed[_darknode][previousCycle] = true;
        uint arrayLength = registeredTokens.length;
        for (uint i = 0; i < arrayLength; i++) {
            address token = registeredTokens[i];

            // Only increment balance if shares were allocated last cycle
            if (previousCycleRewardShare[token] > 0) {
                unclaimedRewards[token] = unclaimedRewards[token].sub(previousCycleRewardShare[token]);
                store.incrementDarknodeBalance(_darknode, token, previousCycleRewardShare[token]);
            }
        }
    }

    /// @notice Snapshots the current balance of the tokens, for all registered
    ///         tokens.
    ///
    /// @param _token The address the token to snapshot.
    function _snapshotBalance(address _token) private {
        uint256 shareCount = darknodeRegistry.numDarknodesPreviousEpoch();
        if (shareCount == 0) {
            unclaimedRewards[_token] = 0;
            previousCycleRewardShare[_token] = 0;
        } else {
            // Lock up the current balance for darknode reward allocation
            uint256 total = store.availableBalance(_token);
            unclaimedRewards[_token] = total.div(100).mul(currentCyclePayoutPercent);
            previousCycleRewardShare[_token] = unclaimedRewards[_token].div(shareCount);
        }
    }

    /// @notice Deregisters a token, removing it from the list of
    ///         registeredTokens.
    ///
    /// @param _token The address of the token to deregister.
    function _deregisterToken(address _token) private {
        address lastToken = registeredTokens[registeredTokens.length.sub(1)];
        uint256 deletedTokenIndex = registeredTokenIndex[_token].sub(1);
        // Move the last token to _token's position and update it's index
        registeredTokens[deletedTokenIndex] = lastToken;
        registeredTokenIndex[lastToken] = registeredTokenIndex[_token];
        // Decreasing the length will clean up the storage for us
        // So we don't need to manually delete the element
        registeredTokens.length = registeredTokens.length.sub(1);
        registeredTokenIndex[_token] = 0;

        emit LogTokenDeregistered(_token);
    }

    /// @notice Updates the list of registeredTokens adding tokens that are to be registered.
    ///         The list of tokens that are pending registration are emptied afterwards.
    function _updateTokenList() private {
        // Register tokens
        uint arrayLength = pendingTokens.length;
        for (uint i = 0; i < arrayLength; i++) {
            address token = pendingTokens[i];
            registeredTokens.push(token);
            registeredTokenIndex[token] = registeredTokens.length;
            emit LogTokenRegistered(token);
        }
        pendingTokens.length = 0;
    }

}
