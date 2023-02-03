pragma experimental ABIEncoderV2;



contract IExchange {

    struct FillResults {
        uint256 makerAssetFilledAmount;  // Total amount of makerAsset(s) filled.
        uint256 takerAssetFilledAmount;  // Total amount of takerAsset(s) filled.
        uint256 makerFeePaid;            // Total amount of ZRX paid by maker(s) to feeRecipient(s).
        uint256 takerFeePaid;            // Total amount of ZRX paid by taker to feeRecipients(s).
    }

    struct OrderInfo {
        uint8 orderStatus;                    // Status that describes order's validity and fillability.
        bytes32 orderHash;                    // EIP712 hash of the order (see LibOrder.getOrderHash).
        uint256 orderTakerAssetFilledAmount;  // Amount of order that has already been filled.
    }

    // solhint-disable max-line-length
    struct Order {
        address makerAddress;           // Address that created the order.
        address takerAddress;           // Address that is allowed to fill the order. If set to 0, any address is allowed to fill the order.
        address feeRecipientAddress;    // Address that will recieve fees when order is filled.
        address senderAddress;          // Address that is allowed to call Exchange contract methods that affect this order. If set to 0, any address is allowed to call these methods.
        uint256 makerAssetAmount;       // Amount of makerAsset being offered by maker. Must be greater than 0.
        uint256 takerAssetAmount;       // Amount of takerAsset being bid on by maker. Must be greater than 0.
        uint256 makerFee;               // Amount of ZRX paid to feeRecipient by maker when order is filled. If set to 0, no transfer of ZRX from maker to feeRecipient will be attempted.
        uint256 takerFee;               // Amount of ZRX paid to feeRecipient by taker when order is filled. If set to 0, no transfer of ZRX from taker to feeRecipient will be attempted.
        uint256 expirationTimeSeconds;  // Timestamp in seconds at which order expires.
        uint256 salt;                   // Arbitrary number to facilitate uniqueness of the order's hash.
        bytes makerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The last byte references the id of this proxy.
        bytes takerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The last byte references the id of this proxy.
    }
    // solhint-enable max-line-length

    /// @dev Gets information about an order: status, hash, and amount filled.
    /// @param order Order to gather information on.
    /// @return OrderInfo Information about the order and its state.
    ///         See LibOrder.OrderInfo for a complete description.
    function getOrderInfo(Order memory order) public view returns (OrderInfo memory orderInfo);

    /// @dev Fills the input order.
    /// @param order Order struct containing order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signature Proof that order has been created by maker.
    /// @return Amounts filled and fees paid by maker and taker.
    function fillOrder(Order memory order, uint256 takerAssetFillAmount, bytes memory signature) public returns (FillResults memory fillResults);

    /// @dev Fills an order with specified parameters and ECDSA signature.
    ///      Returns false if the transaction would otherwise revert.
    /// @param order Order struct containing order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signature Proof that order has been created by maker.
    /// @return Amounts filled and fees paid by maker and taker.
    function fillOrderNoThrow(Order memory order, uint256 takerAssetFillAmount, bytes memory signature) public returns (FillResults memory fillResults);
}

/**
 * @title Helps contracts guard agains rentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>
 * @notice If you mark a function `nonReentrant`, you should also mark it `external`.
 */
contract ReentrancyGuard {
    /**
     * @dev We use a single lock for the whole contract.
     */
    bool private rentrancyLock = false;

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * @notice If you mark a function `nonReentrant`, you should also mark it `external`. Calling one nonReentrant function from another is not supported. Instead, you can implement a `private` function doing the actual work, and a `external` wrapper marked as `nonReentrant`.
     */
    modifier nonReentrant() {
        require(!rentrancyLock);
        rentrancyLock = true;
        _;
        rentrancyLock = false;
    }
}



contract IWallet {

    /// @dev Verifies that a signature is valid.
    /// @param hash Message hash that is signed.
    /// @param signature Proof of signing.
    /// @return Validity of order signature.
    function isValidSignature(
        bytes32 hash,
        bytes calldata signature
    )
        external
        view
        returns (bool isValid);
}

/**
 * @title SafeMathUint256
 * @dev Uint256 math operations with safety checks that throw on error
 */
library SafeMathUint256 {
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a <= b) {
            return a;
        } else {
            return b;
        }
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a >= b) {
            return a;
        } else {
            return b;
        }
    }

    function getUint256Min() internal pure returns (uint256) {
        return 0;
    }

    function getUint256Max() internal pure returns (uint256) {
        // 2 ** 256 - 1
        return 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    }

    function isMultipleOf(uint256 a, uint256 b) internal pure returns (bool) {
        return a % b == 0;
    }

    // Float [fixed point] Operations
    function fxpMul(uint256 a, uint256 b, uint256 base) internal pure returns (uint256) {
        return div(mul(a, b), base);
    }

    function fxpDiv(uint256 a, uint256 b, uint256 base) internal pure returns (uint256) {
        return div(mul(a, base), b);
    }
}


contract IERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address owner) public view returns (uint256);
    function transfer(address to, uint256 amount) public returns (bool);
    function transferFrom(address from, address to, uint256 amount) public returns (bool);
    function approve(address spender, uint256 amount) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);

    // solhint-disable-next-line no-simple-event-func-name
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ZeroXExchange is IExchange, ReentrancyGuard {
    using SafeMathUint256 for uint256;

    // EIP191 header for EIP712 prefix
    string constant internal EIP191_HEADER = "\x19\x01";

    // EIP712 Domain Name value
    string constant internal EIP712_DOMAIN_NAME = "0x Protocol";

    // EIP712 Domain Version value
    string constant internal EIP712_DOMAIN_VERSION = "2";

    // Hash of the EIP712 Domain Separator Schema
    bytes32 constant internal EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH = keccak256(
        abi.encodePacked(
        "EIP712Domain(",
        "string name,",
        "string version,",
        "address verifyingContract",
        ")"
    ));

    bytes32 constant internal EIP712_ORDER_SCHEMA_HASH = keccak256(
        abi.encodePacked(
        "Order(",
        "address makerAddress,",
        "address takerAddress,",
        "address feeRecipientAddress,",
        "address senderAddress,",
        "uint256 makerAssetAmount,",
        "uint256 takerAssetAmount,",
        "uint256 makerFee,",
        "uint256 takerFee,",
        "uint256 expirationTimeSeconds,",
        "uint256 salt,",
        "bytes makerAssetData,",
        "bytes takerAssetData",
        ")"
    ));

    bytes32 constant internal EIP712_ZEROEX_TRANSACTION_SCHEMA_HASH = 0x213c6f636f3ea94e701c0adf9b2624aa45a6c694f9a292c094f9a81c24b5df4c;

    // Hash of the EIP712 Domain Separator data
    // solhint-disable-next-line var-name-mixedcase
    bytes32 public EIP712_DOMAIN_HASH;

    bytes4 constant ERC20_PROXY_ID = 0xf47261b0;

    mapping (bytes32 => bool) public transactions;
    address public currentContextAddress;

    enum SignatureType {
        Illegal,         // 0x00, default value
        Invalid,         // 0x01
        EIP712,          // 0x02
        EthSign,         // 0x03
        Wallet,          // 0x04
        Validator,       // 0x05
        PreSigned,       // 0x06
        NSignatureTypes  // 0x07, number of signature types. Always leave at end.
    }

    // A valid order remains fillable until it is expired, fully filled, or cancelled.
    // An order's state is unaffected by external factors, like account balances.
    enum OrderStatus {
        INVALID,                     // Default value
        INVALID_MAKER_ASSET_AMOUNT,  // Order does not have a valid maker asset amount
        INVALID_TAKER_ASSET_AMOUNT,  // Order does not have a valid taker asset amount
        FILLABLE,                    // Order is fillable
        EXPIRED,                     // Order has already expired
        FULLY_FILLED,                // Order is fully filled
        CANCELLED                    // Order has been cancelled
    }

    // Mapping of orderHash => amount of takerAsset already bought by maker
    mapping (bytes32 => uint256) public filled;

    // Mapping of orderHash => cancelled
    mapping (bytes32 => bool) public cancelled;

    mapping (bytes32 => mapping (address => bool)) public preSigned;

    // Mapping of makerAddress => senderAddress => lowest salt an order can have in order to be fillable
    // Orders with specified senderAddress and with a salt less than their epoch are considered cancelled
    mapping (address => mapping (address => uint256)) public orderEpoch;

    constructor ()
        public
    {
        EIP712_DOMAIN_HASH = keccak256(
            abi.encodePacked(
            EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH,
            keccak256(bytes(EIP712_DOMAIN_NAME)),
            keccak256(bytes(EIP712_DOMAIN_VERSION)),
            uint256(address(this))
        ));
    }

    /// @dev Adds properties of both FillResults instances.
    ///      Modifies the first FillResults instance specified.
    /// @param totalFillResults Fill results instance that will be added onto.
    /// @param singleFillResults Fill results instance that will be added to totalFillResults.
    function addFillResults(FillResults memory totalFillResults, FillResults memory singleFillResults)
        internal
        pure
    {
        totalFillResults.makerAssetFilledAmount = totalFillResults.makerAssetFilledAmount.add(singleFillResults.makerAssetFilledAmount);
        totalFillResults.takerAssetFilledAmount = totalFillResults.takerAssetFilledAmount.add(singleFillResults.takerAssetFilledAmount);
        totalFillResults.makerFeePaid = totalFillResults.makerFeePaid.add(singleFillResults.makerFeePaid);
        totalFillResults.takerFeePaid = totalFillResults.takerFeePaid.add(singleFillResults.takerFeePaid);
    }

    /// @dev Fills the input order.
    ///      Returns false if the transaction would otherwise revert.
    /// @param order Order struct containing order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signature Proof that order has been created by maker.
    /// @return Amounts filled and fees paid by maker and taker.
    function fillOrderNoThrow(
        Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        returns (FillResults memory fillResults)
    {
        // ABI encode calldata for `fillOrder`
        bytes memory fillOrderCalldata = abiEncodeFillOrder(
            order,
            takerAssetFillAmount,
            signature
        );

        // Delegate to `fillOrder` and handle any exceptions gracefully
        assembly {
            let success := delegatecall(
                gas,                                // forward all gas
                address,                            // call address of this contract
                add(fillOrderCalldata, 32),         // pointer to start of input (skip array length in first 32 bytes)
                mload(fillOrderCalldata),           // length of input
                fillOrderCalldata,                  // write output over input
                128                                 // output size is 128 bytes
            )
            if success {
                mstore(fillResults, mload(fillOrderCalldata))
                mstore(add(fillResults, 32), mload(add(fillOrderCalldata, 32)))
                mstore(add(fillResults, 64), mload(add(fillOrderCalldata, 64)))
                mstore(add(fillResults, 96), mload(add(fillOrderCalldata, 96)))
            }
        }
        // fillResults values will be 0 by default if call was unsuccessful
        return fillResults;
    }

    /// @dev ABI encodes calldata for `fillOrder`.
    /// @param order Order struct containing order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signature Proof that order has been created by maker.
    /// @return ABI encoded calldata for `fillOrder`.
    function abiEncodeFillOrder(
        Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        internal
        pure
        returns (bytes memory fillOrderCalldata)
    {
        // We need to call MExchangeCore.fillOrder using a delegatecall in
        // assembly so that we can intercept a call that throws. For this, we
        // need the input encoded in memory in the Ethereum ABIv2 format [1].

        // | Area     | Offset | Length  | Contents                                    |
        // | -------- |--------|---------|-------------------------------------------- |
        // | Header   | 0x00   | 4       | function selector                           |
        // | Params   |        | 3 * 32  | function parameters:                        |
        // |          | 0x00   |         |   1. offset to order (*)                    |
        // |          | 0x20   |         |   2. takerAssetFillAmount                   |
        // |          | 0x40   |         |   3. offset to signature (*)                |
        // | Data     |        | 12 * 32 | order:                                      |
        // |          | 0x000  |         |   1.  senderAddress                         |
        // |          | 0x020  |         |   2.  makerAddress                          |
        // |          | 0x040  |         |   3.  takerAddress                          |
        // |          | 0x060  |         |   4.  feeRecipientAddress                   |
        // |          | 0x080  |         |   5.  makerAssetAmount                      |
        // |          | 0x0A0  |         |   6.  takerAssetAmount                      |
        // |          | 0x0C0  |         |   7.  makerFeeAmount                        |
        // |          | 0x0E0  |         |   8.  takerFeeAmount                        |
        // |          | 0x100  |         |   9.  expirationTimeSeconds                 |
        // |          | 0x120  |         |   10. salt                                  |
        // |          | 0x140  |         |   11. Offset to makerAssetData (*)          |
        // |          | 0x160  |         |   12. Offset to takerAssetData (*)          |
        // |          | 0x180  | 32      | makerAssetData Length                       |
        // |          | 0x1A0  | **      | makerAssetData Contents                     |
        // |          | 0x1C0  | 32      | takerAssetData Length                       |
        // |          | 0x1E0  | **      | takerAssetData Contents                     |
        // |          | 0x200  | 32      | signature Length                            |
        // |          | 0x220  | **      | signature Contents                          |

        // * Offsets are calculated from the beginning of the current area: Header, Params, Data:
        //     An offset stored in the Params area is calculated from the beginning of the Params section.
        //     An offset stored in the Data area is calculated from the beginning of the Data section.

        // ** The length of dynamic array contents are stored in the field immediately preceeding the contents.

        // [1]: https://solidity.readthedocs.io/en/develop/abi-spec.html

        assembly {

            // Areas below may use the following variables:
            //   1. <area>Start   -- Start of this area in memory
            //   2. <area>End     -- End of this area in memory. This value may
            //                       be precomputed (before writing contents),
            //                       or it may be computed as contents are written.
            //   3. <area>Offset  -- Current offset into area. If an area's End
            //                       is precomputed, this variable tracks the
            //                       offsets of contents as they are written.

            /////// Setup Header Area ///////
            // Load free memory pointer
            fillOrderCalldata := mload(0x40)
            // bytes4(keccak256("fillOrder((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes),uint256,bytes)"))
            // = 0xb4be83d5
            // Leave 0x20 bytes to store the length
            mstore(add(fillOrderCalldata, 0x20), 0xb4be83d500000000000000000000000000000000000000000000000000000000)
            let headerAreaEnd := add(fillOrderCalldata, 0x24)

            /////// Setup Params Area ///////
            // This area is preallocated and written to later.
            // This is because we need to fill in offsets that have not yet been calculated.
            let paramsAreaStart := headerAreaEnd
            let paramsAreaEnd := add(paramsAreaStart, 0x60)
            let paramsAreaOffset := paramsAreaStart

            /////// Setup Data Area ///////
            let dataAreaStart := paramsAreaEnd
            let dataAreaEnd := dataAreaStart

            // Offset from the source data we're reading from
            let sourceOffset := order
            // arrayLenBytes and arrayLenWords track the length of a dynamically-allocated bytes array.
            let arrayLenBytes := 0
            let arrayLenWords := 0

            /////// Write order Struct ///////
            // Write memory location of Order, relative to the start of the
            // parameter list, then increment the paramsAreaOffset respectively.
            mstore(paramsAreaOffset, sub(dataAreaEnd, paramsAreaStart))
            paramsAreaOffset := add(paramsAreaOffset, 0x20)

            // Write values for each field in the order
            // It would be nice to use a loop, but we save on gas by writing
            // the stores sequentially.
            mstore(dataAreaEnd, mload(sourceOffset))                            // makerAddress
            mstore(add(dataAreaEnd, 0x20), mload(add(sourceOffset, 0x20)))      // takerAddress
            mstore(add(dataAreaEnd, 0x40), mload(add(sourceOffset, 0x40)))      // feeRecipientAddress
            mstore(add(dataAreaEnd, 0x60), mload(add(sourceOffset, 0x60)))      // senderAddress
            mstore(add(dataAreaEnd, 0x80), mload(add(sourceOffset, 0x80)))      // makerAssetAmount
            mstore(add(dataAreaEnd, 0xA0), mload(add(sourceOffset, 0xA0)))      // takerAssetAmount
            mstore(add(dataAreaEnd, 0xC0), mload(add(sourceOffset, 0xC0)))      // makerFeeAmount
            mstore(add(dataAreaEnd, 0xE0), mload(add(sourceOffset, 0xE0)))      // takerFeeAmount
            mstore(add(dataAreaEnd, 0x100), mload(add(sourceOffset, 0x100)))    // expirationTimeSeconds
            mstore(add(dataAreaEnd, 0x120), mload(add(sourceOffset, 0x120)))    // salt
            mstore(add(dataAreaEnd, 0x140), mload(add(sourceOffset, 0x140)))    // Offset to makerAssetData
            mstore(add(dataAreaEnd, 0x160), mload(add(sourceOffset, 0x160)))    // Offset to takerAssetData
            dataAreaEnd := add(dataAreaEnd, 0x180)
            sourceOffset := add(sourceOffset, 0x180)

            // Write offset to <order.makerAssetData>
            mstore(add(dataAreaStart, mul(10, 0x20)), sub(dataAreaEnd, dataAreaStart))

            // Calculate length of <order.makerAssetData>
            sourceOffset := mload(add(order, 0x140)) // makerAssetData
            arrayLenBytes := mload(sourceOffset)
            sourceOffset := add(sourceOffset, 0x20)
            arrayLenWords := div(add(arrayLenBytes, 0x1F), 0x20)

            // Write length of <order.makerAssetData>
            mstore(dataAreaEnd, arrayLenBytes)
            dataAreaEnd := add(dataAreaEnd, 0x20)

            // Write contents of <order.makerAssetData>
            for {let i := 0} lt(i, arrayLenWords) {i := add(i, 1)} {
                mstore(dataAreaEnd, mload(sourceOffset))
                dataAreaEnd := add(dataAreaEnd, 0x20)
                sourceOffset := add(sourceOffset, 0x20)
            }

            // Write offset to <order.takerAssetData>
            mstore(add(dataAreaStart, mul(11, 0x20)), sub(dataAreaEnd, dataAreaStart))

            // Calculate length of <order.takerAssetData>
            sourceOffset := mload(add(order, 0x160)) // takerAssetData
            arrayLenBytes := mload(sourceOffset)
            sourceOffset := add(sourceOffset, 0x20)
            arrayLenWords := div(add(arrayLenBytes, 0x1F), 0x20)

            // Write length of <order.takerAssetData>
            mstore(dataAreaEnd, arrayLenBytes)
            dataAreaEnd := add(dataAreaEnd, 0x20)

            // Write contents of  <order.takerAssetData>
            for {let i := 0} lt(i, arrayLenWords) {i := add(i, 1)} {
                mstore(dataAreaEnd, mload(sourceOffset))
                dataAreaEnd := add(dataAreaEnd, 0x20)
                sourceOffset := add(sourceOffset, 0x20)
            }

            /////// Write takerAssetFillAmount ///////
            mstore(paramsAreaOffset, takerAssetFillAmount)
            paramsAreaOffset := add(paramsAreaOffset, 0x20)

            /////// Write signature ///////
            // Write offset to paramsArea
            mstore(paramsAreaOffset, sub(dataAreaEnd, paramsAreaStart))

            // Calculate length of signature
            sourceOffset := signature
            arrayLenBytes := mload(sourceOffset)
            sourceOffset := add(sourceOffset, 0x20)
            arrayLenWords := div(add(arrayLenBytes, 0x1F), 0x20)

            // Write length of signature
            mstore(dataAreaEnd, arrayLenBytes)
            dataAreaEnd := add(dataAreaEnd, 0x20)

            // Write contents of signature
            for {let i := 0} lt(i, arrayLenWords) {i := add(i, 1)} {
                mstore(dataAreaEnd, mload(sourceOffset))
                dataAreaEnd := add(dataAreaEnd, 0x20)
                sourceOffset := add(sourceOffset, 0x20)
            }

            // Set length of calldata
            mstore(fillOrderCalldata, sub(dataAreaEnd, add(fillOrderCalldata, 0x20)))

            // Increment free memory pointer
            mstore(0x40, dataAreaEnd)
        }

        return fillOrderCalldata;
    }

    /// @dev Fills the input order.
    /// @param order Order struct containing order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signature Proof that order has been created by maker.
    /// @return Amounts filled and fees paid by maker and taker.
    function fillOrder(
        Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        nonReentrant
        returns (FillResults memory fillResults)
    {
        fillResults = fillOrderInternal(
            order,
            takerAssetFillAmount,
            signature
        );
        return fillResults;
    }

    /// @dev Executes an exchange method call in the context of signer.
    /// @param salt Arbitrary number to ensure uniqueness of transaction hash.
    /// @param signerAddress Address of transaction signer.
    /// @param data AbiV2 encoded calldata.
    /// @param signature Proof of signer transaction by signer.
    function executeTransaction(
        uint256 salt,
        address signerAddress,
        bytes memory data,
        bytes memory signature
    )
        internal
    {
        // Prevent reentrancy
        require(
            currentContextAddress == address(0),
            "REENTRANCY_ILLEGAL"
        );

        bytes32 hashedTransaction = hashZeroExTransaction(salt, signerAddress, data);
        bytes32 transactionHash = hashEIP712Message(hashedTransaction);

        // Validate transaction has not been executed
        require(!transactions[transactionHash], "INVALID_TX_HASH");

        // Transaction always valid if signer is sender of transaction
        if (signerAddress != msg.sender) {
            // Validate signature
            require(
                isValidSignature(
                    transactionHash,
                    signerAddress,
                    signature
                ),
                "INVALID_TX_SIGNATURE"
            );

            // Set the current transaction signer
            currentContextAddress = signerAddress;
        }

        // Execute transaction
        transactions[transactionHash] = true;
        (bool success,) = address(this).delegatecall(data);
        require(
            success,
            "FAILED_EXECUTION"
        );

        // Reset current transaction signer if it was previously updated
        if (signerAddress != msg.sender) {
            currentContextAddress = address(0);
        }
    }

    /// @dev Updates state with results of a fill order.
    /// @param orderTakerAssetFilledAmount Amount of order already filled.
    function updateFilledState(
        Order memory,
        address,
        bytes32 orderHash,
        uint256 orderTakerAssetFilledAmount,
        FillResults memory fillResults
    )
        internal
    {
        // Update state
        filled[orderHash] = orderTakerAssetFilledAmount.add(fillResults.takerAssetFilledAmount);
    }

    /// @dev Fills the input order.
    /// @param order Order struct containing order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signature Proof that order has been created by maker.
    /// @return Amounts filled and fees paid by maker and taker.
    function fillOrderInternal(
        Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        internal
        returns (FillResults memory fillResults)
    {
        // Fetch order info
        OrderInfo memory orderInfo = getOrderInfo(order);

        // Fetch taker address
        address takerAddress = getCurrentContextAddress();

        // Assert that the order is fillable by taker
        assertFillableOrder(
            order,
            orderInfo,
            takerAddress,
            signature
        );

        // Get amount of takerAsset to fill
        uint256 remainingTakerAssetAmount = order.takerAssetAmount.sub(orderInfo.orderTakerAssetFilledAmount);
        uint256 takerAssetFilledAmount = takerAssetFillAmount.min(remainingTakerAssetAmount);

        // Validate context
        assertValidFill(
            order,
            orderInfo,
            takerAssetFillAmount,
            takerAssetFilledAmount,
            fillResults.makerAssetFilledAmount
        );

        // Compute proportional fill amounts
        fillResults = calculateFillResults(order, takerAssetFilledAmount);

        // Update exchange internal state
        updateFilledState(
            order,
            takerAddress,
            orderInfo.orderHash,
            orderInfo.orderTakerAssetFilledAmount,
            fillResults
        );

        // Settle order
        settleOrder(
            order,
            takerAddress,
            fillResults
        );

        return fillResults;
    }

    /// @dev Validates context for fillOrder. Succeeds or throws.
    /// @param order to be filled.
    /// @param orderInfo OrderStatus, orderHash, and amount already filled of order.
    /// @param takerAssetFillAmount Desired amount of order to fill by taker.
    /// @param takerAssetFilledAmount Amount of takerAsset that will be filled.
    /// @param makerAssetFilledAmount Amount of makerAsset that will be transfered.
    function assertValidFill(
        Order memory order,
        OrderInfo memory orderInfo,
        uint256 takerAssetFillAmount,  // TODO: use FillResults
        uint256 takerAssetFilledAmount,
        uint256 makerAssetFilledAmount
    )
        internal
        pure
    {
        // Revert if fill amount is invalid
        // TODO: reconsider necessity for v2.1
        require(
            takerAssetFillAmount != 0,
            "INVALID_TAKER_AMOUNT"
        );

        // Make sure taker does not pay more than desired amount
        // NOTE: This assertion should never fail, it is here
        //       as an extra defence against potential bugs.
        require(
            takerAssetFilledAmount <= takerAssetFillAmount,
            "TAKER_OVERPAY"
        );

        // Make sure order is not overfilled
        // NOTE: This assertion should never fail, it is here
        //       as an extra defence against potential bugs.
        require(
            orderInfo.orderTakerAssetFilledAmount.add(takerAssetFilledAmount) <= order.takerAssetAmount,
            "ORDER_OVERFILL"
        );

        // Make sure order is filled at acceptable price.
        // The order has an implied price from the makers perspective:
        //    order price = order.makerAssetAmount / order.takerAssetAmount
        // i.e. the number of makerAsset maker is paying per takerAsset. The
        // maker is guaranteed to get this price or a better (lower) one. The
        // actual price maker is getting in this fill is:
        //    fill price = makerAssetFilledAmount / takerAssetFilledAmount
        // We need `fill price <= order price` for the fill to be fair to maker.
        // This amounts to:
        //     makerAssetFilledAmount        order.makerAssetAmount
        //    ------------------------  <=  -----------------------
        //     takerAssetFilledAmount        order.takerAssetAmount
        // or, equivalently:
        //     makerAssetFilledAmount * order.takerAssetAmount <=
        //     order.makerAssetAmount * takerAssetFilledAmount
        // NOTE: This assertion should never fail, it is here
        //       as an extra defence against potential bugs.
        require(
            makerAssetFilledAmount.mul(order.takerAssetAmount)
            <=
            order.makerAssetAmount.mul(takerAssetFilledAmount),
            "INVALID_FILL_PRICE"
        );
    }

    /// @dev Calculates amounts filled and fees paid by maker and taker.
    /// @param order to be filled.
    /// @param takerAssetFilledAmount Amount of takerAsset that will be filled.
    /// @return fillResults Amounts filled and fees paid by maker and taker.
    function calculateFillResults(
        Order memory order,
        uint256 takerAssetFilledAmount
    )
        internal
        pure
        returns (FillResults memory fillResults)
    {
        // Compute proportional transfer amounts
        fillResults.takerAssetFilledAmount = takerAssetFilledAmount;
        fillResults.makerAssetFilledAmount = safeGetPartialAmountFloor(
            takerAssetFilledAmount,
            order.takerAssetAmount,
            order.makerAssetAmount
        );
        fillResults.makerFeePaid = safeGetPartialAmountFloor(
            fillResults.makerAssetFilledAmount,
            order.makerAssetAmount,
            order.makerFee
        );
        fillResults.takerFeePaid = safeGetPartialAmountFloor(
            takerAssetFilledAmount,
            order.takerAssetAmount,
            order.takerFee
        );

        return fillResults;
    }

    /// @dev Settles an order by transferring assets between counterparties.
    /// @param order Order struct containing order specifications.
    /// @param takerAddress Address selling takerAsset and buying makerAsset.
    /// @param fillResults Amounts to be filled and fees paid by maker and taker.
    function settleOrder(
        Order memory order,
        address takerAddress,
        FillResults memory fillResults
    )
        private
    {
        dispatchTransferFrom(
            order.makerAssetData,
            order.makerAddress,
            takerAddress,
            fillResults.makerAssetFilledAmount
        );
        dispatchTransferFrom(
            order.takerAssetData,
            takerAddress,
            order.makerAddress,
            fillResults.takerAssetFilledAmount
        );
    }

    /// @dev Calculates EIP712 hash of the Transaction.
    /// @param salt Arbitrary number to ensure uniqueness of transaction hash.
    /// @param signerAddress Address of transaction signer.
    /// @param data AbiV2 encoded calldata.
    /// @return EIP712 hash of the Transaction.
    function hashZeroExTransaction(
        uint256 salt,
        address signerAddress,
        bytes memory data
    )
        internal
        pure
        returns (bytes32 result)
    {
        bytes32 schemaHash = EIP712_ZEROEX_TRANSACTION_SCHEMA_HASH;
        bytes32 dataHash = keccak256(data);

        // Assembly for more efficiently computing:
        // keccak256(abi.encodePacked(
        //     EIP712_ZEROEX_TRANSACTION_SCHEMA_HASH,
        //     salt,
        //     bytes32(signerAddress),
        //     keccak256(data)
        // ));

        assembly {
            // Load free memory pointer
            let memPtr := mload(64)

            mstore(memPtr, schemaHash)                                                               // hash of schema
            mstore(add(memPtr, 32), salt)                                                            // salt
            mstore(add(memPtr, 64), and(signerAddress, 0xffffffffffffffffffffffffffffffffffffffff))  // signerAddress
            mstore(add(memPtr, 96), dataHash)                                                        // hash of data

            // Compute hash
            result := keccak256(memPtr, 128)
        }
        return result;
    }

    /// @dev Gets information about an order: status, hash, and amount filled.
    /// @param order Order to gather information on.
    /// @return OrderInfo Information about the order and its state.
    ///         See LibOrder.OrderInfo for a complete description.
    function getOrderInfo(Order memory order)
        public
        view
        returns (OrderInfo memory orderInfo)
    {
        // Compute the order hash
        orderInfo.orderHash = getOrderHash(order);

        // Fetch filled amount
        orderInfo.orderTakerAssetFilledAmount = filled[orderInfo.orderHash];

        // If order.makerAssetAmount is zero, we also reject the order.
        // While the Exchange contract handles them correctly, they create
        // edge cases in the supporting infrastructure because they have
        // an 'infinite' price when computed by a simple division.
        if (order.makerAssetAmount == 0) {
            orderInfo.orderStatus = uint8(OrderStatus.INVALID_MAKER_ASSET_AMOUNT);
            return orderInfo;
        }

        // If order.takerAssetAmount is zero, then the order will always
        // be considered filled because 0 == takerAssetAmount == orderTakerAssetFilledAmount
        // Instead of distinguishing between unfilled and filled zero taker
        // amount orders, we choose not to support them.
        if (order.takerAssetAmount == 0) {
            orderInfo.orderStatus = uint8(OrderStatus.INVALID_TAKER_ASSET_AMOUNT);
            return orderInfo;
        }

        // Validate order availability
        if (orderInfo.orderTakerAssetFilledAmount >= order.takerAssetAmount) {
            orderInfo.orderStatus = uint8(OrderStatus.FULLY_FILLED);
            return orderInfo;
        }

        // Validate order expiration
        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp >= order.expirationTimeSeconds) {
            orderInfo.orderStatus = uint8(OrderStatus.EXPIRED);
            return orderInfo;
        }

        // Check if order has been cancelled
        if (cancelled[orderInfo.orderHash]) {
            orderInfo.orderStatus = uint8(OrderStatus.CANCELLED);
            return orderInfo;
        }
        if (orderEpoch[order.makerAddress][order.senderAddress] > order.salt) {
            orderInfo.orderStatus = uint8(OrderStatus.CANCELLED);
            return orderInfo;
        }

        // All other statuses are ruled out: order is Fillable
        orderInfo.orderStatus = uint8(OrderStatus.FILLABLE);
        return orderInfo;
    }

    /// @dev Calculates Keccak-256 hash of the order.
    /// @param order The order structure.
    /// @return Keccak-256 EIP712 hash of the order.
    function getOrderHash(Order memory order)
        internal
        view
        returns (bytes32 orderHash)
    {
        orderHash = hashEIP712Message(hashOrder(order));
        return orderHash;
    }

    /// @dev Calculates EIP712 hash of the order.
    /// @param order The order structure.
    /// @return EIP712 hash of the order.
    function hashOrder(Order memory order)
        internal
        pure
        returns (bytes32 result)
    {
        bytes32 schemaHash = EIP712_ORDER_SCHEMA_HASH;
        bytes32 makerAssetDataHash = keccak256(order.makerAssetData);
        bytes32 takerAssetDataHash = keccak256(order.takerAssetData);

        // Assembly for more efficiently computing:
        // keccak256(abi.encodePacked(
        //     EIP712_ORDER_SCHEMA_HASH,
        //     bytes32(order.makerAddress),
        //     bytes32(order.takerAddress),
        //     bytes32(order.feeRecipientAddress),
        //     bytes32(order.senderAddress),
        //     order.makerAssetAmount,
        //     order.takerAssetAmount,
        //     order.makerFee,
        //     order.takerFee,
        //     order.expirationTimeSeconds,
        //     order.salt,
        //     keccak256(order.makerAssetData),
        //     keccak256(order.takerAssetData)
        // ));

        assembly {
            // Calculate memory addresses that will be swapped out before hashing
            let pos1 := sub(order, 32)
            let pos2 := add(order, 320)
            let pos3 := add(order, 352)

            // Backup
            let temp1 := mload(pos1)
            let temp2 := mload(pos2)
            let temp3 := mload(pos3)

            // Hash in place
            mstore(pos1, schemaHash)
            mstore(pos2, makerAssetDataHash)
            mstore(pos3, takerAssetDataHash)
            result := keccak256(pos1, 416)

            // Restore
            mstore(pos1, temp1)
            mstore(pos2, temp2)
            mstore(pos3, temp3)
        }
        return result;
    }

    /// @dev Calculates EIP712 encoding for a hash struct in this EIP712 Domain.
    /// @param hashStruct The EIP712 hash struct.
    /// @return EIP712 hash applied to this EIP712 Domain.
    function hashEIP712Message(bytes32 hashStruct)
        internal
        view
        returns (bytes32 result)
    {
        bytes32 eip712DomainHash = EIP712_DOMAIN_HASH;

        // Assembly for more efficient computing:
        // keccak256(abi.encodePacked(
        //     EIP191_HEADER,
        //     EIP712_DOMAIN_HASH,
        //     hashStruct
        // ));

        assembly {
            // Load free memory pointer
            let memPtr := mload(64)

            mstore(memPtr, 0x1901000000000000000000000000000000000000000000000000000000000000)  // EIP191 header
            mstore(add(memPtr, 2), eip712DomainHash)                                            // EIP712 domain hash
            mstore(add(memPtr, 34), hashStruct)                                                 // Hash of struct

            // Compute hash
            result := keccak256(memPtr, 66)
        }
        return result;
    }

    /// @dev The current function will be called in the context of this address (either 0x transaction signer or `msg.sender`).
    ///      If calling a fill function, this address will represent the taker.
    ///      If calling a cancel function, this address will represent the maker.
    /// @return Signer of 0x transaction if entry point is `executeTransaction`.
    ///         `msg.sender` if entry point is any other function.
    function getCurrentContextAddress()
        internal
        view
        returns (address)
    {
        address currentContextAddress_ = currentContextAddress;
        address contextAddress = currentContextAddress_ == address(0) ? msg.sender : currentContextAddress_;
        return contextAddress;
    }

    /// @dev Validates context for fillOrder. Succeeds or throws.
    /// @param order to be filled.
    /// @param orderInfo OrderStatus, orderHash, and amount already filled of order.
    /// @param takerAddress Address of order taker.
    /// @param signature Proof that the orders was created by its maker.
    function assertFillableOrder(
        Order memory order,
        OrderInfo memory orderInfo,
        address takerAddress,
        bytes memory signature
    )
        internal
        view
    {
        // An order can only be filled if its status is FILLABLE.
        require(
            orderInfo.orderStatus == uint8(OrderStatus.FILLABLE),
            "ORDER_UNFILLABLE"
        );

        // Validate sender is allowed to fill this order
        if (order.senderAddress != address(0)) {
            require(
                order.senderAddress == msg.sender,
                "INVALID_SENDER"
            );
        }

        // Validate taker is allowed to fill this order
        if (order.takerAddress != address(0)) {
            require(
                order.takerAddress == takerAddress,
                "INVALID_TAKER"
            );
        }

        // Validate Maker signature (check only if first time seen)
        if (orderInfo.orderTakerAssetFilledAmount == 0) {
            require(
                isValidSignature(
                    orderInfo.orderHash,
                    order.makerAddress,
                    signature
                ),
                "INVALID_ORDER_SIGNATURE"
            );
        }
    }

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    ///      Reverts if rounding error is >= 0.1%
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target rounded down.
    function safeGetPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        require(
            !isRoundingErrorFloor(
                numerator,
                denominator,
                target
            ),
            "ROUNDING_ERROR"
        );

        partialAmount =
            numerator.mul(target).div(denominator);
        return partialAmount;
    }

    /// @dev Checks if rounding error >= 0.1% when rounding down.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to multiply with numerator/denominator.
    /// @return Rounding error is present.
    function isRoundingErrorFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bool isError)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        // The absolute rounding error is the difference between the rounded
        // value and the ideal value. The relative rounding error is the
        // absolute rounding error divided by the absolute value of the
        // ideal value. This is undefined when the ideal value is zero.
        //
        // The ideal value is `numerator * target / denominator`.
        // Let's call `numerator * target % denominator` the remainder.
        // The absolute error is `remainder / denominator`.
        //
        // When the ideal value is zero, we require the absolute error to
        // be zero. Fortunately, this is always the case. The ideal value is
        // zero iff `numerator == 0` and/or `target == 0`. In this case the
        // remainder and absolute error are also zero.
        if (target == 0 || numerator == 0) {
            return false;
        }

        // Otherwise, we want the relative rounding error to be strictly
        // less than 0.1%.
        // The relative error is `remainder / (numerator * target)`.
        // We want the relative error less than 1 / 1000:
        //        remainder / (numerator * denominator)  <  1 / 1000
        // or equivalently:
        //        1000 * remainder  <  numerator * target
        // so we have a rounding error iff:
        //        1000 * remainder  >=  numerator * target
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        isError = remainder.mul(1000) >= numerator.mul(target);
        return isError;
    }

    /// @dev Forwards arguments to assetProxy and calls `transferFrom`. Either succeeds or throws.
    /// @param assetData Byte array encoded for the asset.
    /// @param from Address to transfer token from.
    /// @param to Address to transfer token to.
    /// @param amount Amount of token to transfer.
    function dispatchTransferFrom(
        bytes memory assetData,
        address from,
        address to,
        uint256 amount
    )
        internal
    {
        // Do nothing if no amount should be transferred.
        if (amount > 0 && from != to) {
            // Ensure assetData length is valid
            require(
                assetData.length > 3,
                "LENGTH_GREATER_THAN_3_REQUIRED"
            );

            address assetProxy = address(this);

            // We construct calldata for the `assetProxy.transferFrom` ABI.
            // The layout of this calldata is in the table below.
            //
            // | Area     | Offset | Length  | Contents                                    |
            // | -------- |--------|---------|-------------------------------------------- |
            // | Header   | 0      | 4       | function selector                           |
            // | Params   |        | 4 * 32  | function parameters:                        |
            // |          | 4      |         |   1. offset to assetData (*)                |
            // |          | 36     |         |   2. from                                   |
            // |          | 68     |         |   3. to                                     |
            // |          | 100    |         |   4. amount                                 |
            // | Data     |        |         | assetData:                                  |
            // |          | 132    | 32      | assetData Length                            |
            // |          | 164    | **      | assetData Contents                          |

            assembly {
                /////// Setup State ///////
                // `cdStart` is the start of the calldata for `assetProxy.transferFrom` (equal to free memory ptr).
                let cdStart := mload(64)
                // `dataAreaLength` is the total number of words needed to store `assetData`
                //  As-per the ABI spec, this value is padded up to the nearest multiple of 32,
                //  and includes 32-bytes for length.
                let dataAreaLength := and(add(mload(assetData), 63), 0xFFFFFFFFFFFE0)
                // `cdEnd` is the end of the calldata for `assetProxy.transferFrom`.
                let cdEnd := add(cdStart, add(132, dataAreaLength))


                /////// Setup Header Area ///////
                // This area holds the 4-byte `transferFromSelector`.
                // bytes4(keccak256("transferFrom(bytes,address,address,uint256)")) = 0xa85e59e4
                mstore(cdStart, 0xa85e59e400000000000000000000000000000000000000000000000000000000)

                /////// Setup Params Area ///////
                // Each parameter is padded to 32-bytes. The entire Params Area is 128 bytes.
                // Notes:
                //   1. The offset to `assetData` is the length of the Params Area (128 bytes).
                //   2. A 20-byte mask is applied to addresses to zero-out the unused bytes.
                mstore(add(cdStart, 4), 128)
                mstore(add(cdStart, 36), and(from, 0xffffffffffffffffffffffffffffffffffffffff))
                mstore(add(cdStart, 68), and(to, 0xffffffffffffffffffffffffffffffffffffffff))
                mstore(add(cdStart, 100), amount)

                /////// Setup Data Area ///////
                // This area holds `assetData`.
                let dataArea := add(cdStart, 132)
                // solhint-disable-next-line no-empty-blocks
                for {} lt(dataArea, cdEnd) {} {
                    mstore(dataArea, mload(assetData))
                    dataArea := add(dataArea, 32)
                    assetData := add(assetData, 32)
                }

                /////// Call `assetProxy.transferFrom` using the constructed calldata ///////
                let success := call(
                    gas,                    // forward all gas
                    assetProxy,             // call address of asset proxy
                    0,                      // don't send any ETH
                    cdStart,                // pointer to start of input
                    sub(cdEnd, cdStart),    // length of input
                    cdStart,                // write output over input
                    512                     // reserve 512 bytes for output
                )
                if iszero(success) {
                    revert(cdStart, returndatasize())
                }
            }
        }
    }

    /// @dev Verifies that a hash has been signed by the given signer.
    /// @param hash Any 32 byte hash.
    /// @param signerAddress Address that should have signed the given hash.
    /// @param signature Proof that the hash has been signed by signer.
    /// @return True if the address recovered from the provided signature matches the input signer address.
    function isValidSignature(
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        public
        view
        returns (bool isValid)
    {
        require(
            signature.length > 0,
            "LENGTH_GREATER_THAN_0_REQUIRED"
        );

        // Pop last byte off of signature byte array.
        uint8 signatureTypeRaw = uint8(popLastByte(signature));

        // Ensure signature is supported
        require(
            signatureTypeRaw < uint8(SignatureType.NSignatureTypes),
            "SIGNATURE_UNSUPPORTED"
        );

        SignatureType signatureType = SignatureType(signatureTypeRaw);

        // Variables are not scoped in Solidity.
        uint8 v;
        bytes32 r;
        bytes32 s;
        address recovered;

        // Always illegal signature.
        // This is always an implicit option since a signer can create a
        // signature array with invalid type or length. We may as well make
        // it an explicit option. This aids testing and analysis. It is
        // also the initialization value for the enum type.
        if (signatureType == SignatureType.Illegal) {
            revert("SIGNATURE_ILLEGAL");

        // Always invalid signature.
        // Like Illegal, this is always implicitly available and therefore
        // offered explicitly. It can be implicitly created by providing
        // a correctly formatted but incorrect signature.
        } else if (signatureType == SignatureType.Invalid) {
            require(
                signature.length == 0,
                "LENGTH_0_REQUIRED"
            );
            isValid = false;
            return isValid;

        // Signature using EIP712
        } else if (signatureType == SignatureType.EIP712) {
            require(
                signature.length == 65,
                "LENGTH_65_REQUIRED"
            );
            v = uint8(signature[0]);
            r = readBytes32(signature, 1);
            s = readBytes32(signature, 33);
            recovered = ecrecover(
                hash,
                v,
                r,
                s
            );
            isValid = signerAddress == recovered;
            return isValid;

        // Signed using web3.eth_sign
        } else if (signatureType == SignatureType.EthSign) {
            require(
                signature.length == 65,
                "LENGTH_65_REQUIRED"
            );
            v = uint8(signature[0]);
            r = readBytes32(signature, 1);
            s = readBytes32(signature, 33);
            recovered = ecrecover(
                keccak256(
                    abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)),
                v,
                r,
                s
            );
            isValid = signerAddress == recovered;
            return isValid;

        // Signature verified by wallet contract.
        // If used with an order, the maker of the order is the wallet contract.
        } else if (signatureType == SignatureType.Wallet) {
            isValid = isValidWalletSignature(
                hash,
                signerAddress,
                signature
            );
            return isValid;
        // Signer signed hash previously using the preSign function.
        } else if (signatureType == SignatureType.PreSigned) {
            isValid = preSigned[hash][signerAddress];
            return isValid;
        }

        // Anything else is illegal (We do not return false because
        // the signature may actually be valid, just not in a format
        // that we currently support. In this case returning false
        // may lead the caller to incorrectly believe that the
        // signature was invalid.)
        revert("SIGNATURE_UNSUPPORTED");
    }

    /// @dev Pops the last byte off of a byte array by modifying its length.
    /// @param b Byte array that will be modified.
    /// @return The byte that was popped off.
    function popLastByte(bytes memory b)
        internal
        pure
        returns (bytes1 result)
    {
        require(
            b.length > 0,
            "GREATER_THAN_ZERO_LENGTH_REQUIRED"
        );

        // Store last byte.
        result = b[b.length - 1];

        assembly {
            // Decrement length of byte array.
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    /// @dev Reads a bytes32 value from a position in a byte array.
    /// @param b Byte array containing a bytes32 value.
    /// @param index Index in byte array of bytes32 value.
    /// @return bytes32 value from byte array.
    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {
        require(
            b.length >= index + 32,
            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    /// @dev Verifies signature using logic defined by Wallet contract.
    /// @param hash Any 32 byte hash.
    /// @param walletAddress Address that should have signed the given hash
    ///                      and defines its own signature verification method.
    /// @param signature Proof that the hash has been signed by signer.
    /// @return True if signature is valid for given wallet..
    function isValidWalletSignature(
        bytes32 hash,
        address walletAddress,
        bytes memory signature
    )
        internal
        view
        returns (bool isValid)
    {
        bytes memory callData = abi.encodeWithSelector(
            IWallet(walletAddress).isValidSignature.selector,
            hash,
            signature
        );
        assembly {
            let cdStart := add(callData, 32)
            let success := staticcall(
                gas,              // forward all gas
                walletAddress,    // address of Wallet contract
                cdStart,          // pointer to start of input
                mload(callData),  // length of input
                cdStart,          // write output over input
                32                // output size is 32 bytes
            )

            switch success
            case 0 {
                // Revert with `Error("WALLET_ERROR")`
                mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)
                mstore(64, 0x0000000c57414c4c45545f4552524f5200000000000000000000000000000000)
                mstore(96, 0)
                revert(0, 100)
            }
            case 1 {
                // Signature is valid if call did not revert and returned true
                isValid := mload(cdStart)
            }
        }
        return isValid;
    }

    /// @dev Transfers assets. Either succeeds or throws.
    /// @param assetData Encoded byte array.
    /// @param from Address to transfer asset from.
    /// @param to Address to transfer asset to.
    /// @param amount Amount of asset to transfer.
    function transferFrom(
        bytes calldata assetData,
        address from,
        address to,
        uint256 amount
    )
        external
    {
        require(msg.sender == address(this));
        transferFromInternal(
            assetData,
            from,
            to,
            amount
        );
    }

    /// @dev Internal version of `transferFrom`.
    /// @param assetData Encoded byte array.
    /// @param from Address to transfer asset from.
    /// @param to Address to transfer asset to.
    /// @param amount Amount of asset to transfer.
    function transferFromInternal(
        bytes memory assetData,
        address from,
        address to,
        uint256 amount
    )
        internal
    {
        // Decode asset data.
        (
            bytes4 proxyId,
            address token
        ) = decodeERC20AssetData(assetData);

        require(
            proxyId == ERC20_PROXY_ID,
            "WRONG_PROXY_ID"
        );

        // Transfer tokens.
        bool success = IERC20(token).transferFrom(from, to, amount);
        require(
            success,
            "TRANSFER FAILED"
        );
    }

    /// @dev Decode ERC-20 asset data from the format described in the AssetProxy contract specification.
    /// @param assetData AssetProxy-compliant asset data describing an ERC-20 asset.
    /// @return The ERC-20 AssetProxy identifier, and the address of the ERC-20
    /// contract hosting this asset.
    function decodeERC20AssetData(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId,
            address tokenAddress
        )
    {
        assetProxyId = readBytes4(assetData, 0);

        require(
            assetProxyId == ERC20_PROXY_ID,
            "WRONG_PROXY_ID"
        );

        tokenAddress = readAddress(assetData, 16);
        return (assetProxyId, tokenAddress);
    }

    /// @dev Reads an unpadded bytes4 value from a position in a byte array.
    /// @param b Byte array containing a bytes4 value.
    /// @param index Index in byte array of bytes4 value.
    /// @return bytes4 value from byte array.
    function readBytes4(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes4 result)
    {
        require(
            b.length >= index + 4,
            "GREATER_OR_EQUAL_TO_4_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 32 byte length field
        index += 32;

        // Read the bytes4 from array memory
        assembly {
            result := mload(add(b, index))
            // Solidity does not require us to clean the trailing bytes.
            // We do it anyway
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }

    /// @dev Reads an address from a position in a byte array.
    /// @param b Byte array containing an address.
    /// @param index Index in byte array of address.
    /// @return address from byte array.
    function readAddress(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (address result)
    {
        require(
            b.length >= index + 20,  // 20 is length of address
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Read address from array memory
        assembly {
            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 20-byte mask to obtain address
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }
}
