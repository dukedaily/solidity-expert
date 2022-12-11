/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 * Code yanked from https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
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

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    uint8 public decimals;

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract DAIHardFactory {
    using SafeMath for uint;

    event NewTrade(uint id, address tradeAddress, bool indexed initiatorIsCustodian);

    ERC20Interface public daiContract;
    address public founderFeeAddress;

    constructor(ERC20Interface _daiContract, address _founderFeeAddress)
    public {
        daiContract = _daiContract;
        founderFeeAddress = _founderFeeAddress;
    }

    struct CreationInfo {
        address address_;
        uint blocknum;
    }

    CreationInfo[] public createdTrades;

    function getFounderFee(uint tradeAmount)
    public
    pure
    returns (uint founderFee) {
        return tradeAmount / 200;
    }

    /*
    The Solidity compiler can't handle much stack depth,
    so we have to pack some args together in annoying ways...
    Hence 'uintArgs' and 'addressArgs'.

    Here are the layouts for createOpenTrade:

    uintArgs:
    0 - tradeAmount
    1 - beneficiaryDeposit
    2 - abortPunishment
    3 - pokeReward
    4 - autorecallInterval
    5 - autoabortInterval
    6 - autoreleaseInterval
    7 - devFee

    addressArgs:
    0 - initiator
    1 - devFeeAddress
    */

    function createOpenTrade(address[2] calldata addressArgs,
                             bool initiatorIsCustodian,
                             uint[8] calldata uintArgs,
                             string calldata terms,
                             string calldata _commPubkey
                             )
    external
    returns (DAIHardTrade) {
        uint initialTransfer;
        uint[8] memory newUintArgs; // Note that this structure is not the same as the above comment describes. See below in DAIHardTrade.open.

        if (initiatorIsCustodian) {
            initialTransfer = uintArgs[0].add(uintArgs[3]).add(getFounderFee(uintArgs[0])).add(uintArgs[7]);
            // tradeAmount + pokeReward + getFounderFee(tradeAmount) + devFee

            newUintArgs = [uintArgs[1], uintArgs[2], uintArgs[3], uintArgs[4], uintArgs[5], uintArgs[6], getFounderFee(uintArgs[0]), uintArgs[7]];
            // see uintArgs comment above DAIHardTrade.beginInOpenPhase
        }
        else {
            initialTransfer = uintArgs[1].add(uintArgs[3]).add(getFounderFee(uintArgs[0])).add(uintArgs[7]);
            // beneficiaryDeposit + pokeReward + getFounderFee(tradeAmount) + devFee

            newUintArgs = [uintArgs[0], uintArgs[2], uintArgs[3], uintArgs[4], uintArgs[5], uintArgs[6], getFounderFee(uintArgs[0]), uintArgs[7]];
            // see uintArgs comment above DAIHardTrade.beginInOpenPhase
        }

        // Create the new trade and add its creationInfo to createdTrades, and emit an event.
        // This provides a DAIHard interface two options to find all created trades:
        // scan for NewTrade events or read the createdTrades array.
        DAIHardTrade newTrade = new DAIHardTrade(daiContract, founderFeeAddress, addressArgs[1]);
        createdTrades.push(CreationInfo(address(newTrade), block.number));
        emit NewTrade(createdTrades.length - 1, address(newTrade), initiatorIsCustodian);

        // transfer DAI to the trade and open it
        require(daiContract.transferFrom(msg.sender, address(newTrade), initialTransfer),
                "Token transfer failed. Did you call approve() on the DAI contract?"
                );
        newTrade.beginInOpenPhase(addressArgs[0], initiatorIsCustodian, newUintArgs, terms, _commPubkey);

        return newTrade;
    }

    /*
    Array layouts for createCommittedTrade:

    uintArgs:
    0 - tradeAmount
    1 - beneficiaryDeposit
    2 - abortPunishment
    3 - pokeReward
    4 - autoabortInterval
    5 - autoreleaseInterval
    6 - devFee

    addressArgs:
    0 - custodian
    1 - beneficiary
    2 - devFeeAddress
    */

    function createCommittedTrade(address[3] calldata addressArgs,
                                  bool initiatorIsCustodian,
                                  uint[7] calldata uintArgs,
                                  string calldata _terms,
                                  string calldata _initiatorCommPubkey,
                                  string calldata _responderCommPubkey
                                  )
    external
    returns (DAIHardTrade) {
        uint initialTransfer = uintArgs[0].add(uintArgs[1]).add(uintArgs[3]).add(getFounderFee(uintArgs[0]).add(uintArgs[6]));
        // initialTransfer = tradeAmount + beneficiaryDeposit + pokeReward + getFounderFee(tradeAmount) + devFee

        uint[7] memory newUintArgs = [uintArgs[1], uintArgs[2], uintArgs[3], uintArgs[4], uintArgs[5], getFounderFee(uintArgs[0]), uintArgs[6]];
        // see uintArgs comment above DAIHardTrade.beginInCommittedPhase

        DAIHardTrade newTrade = new DAIHardTrade(daiContract, founderFeeAddress, addressArgs[2]);
        createdTrades.push(CreationInfo(address(newTrade), block.number));
        emit NewTrade(createdTrades.length - 1, address(newTrade), initiatorIsCustodian);

        require(daiContract.transferFrom(msg.sender, address(newTrade), initialTransfer),
                                         "Token transfer failed. Did you call approve() on the DAI contract?"
                                         );
        newTrade.beginInCommittedPhase(addressArgs[0],
                                       addressArgs[1],
                                       initiatorIsCustodian,
                                       newUintArgs,
                                       _terms,
                                       _initiatorCommPubkey,
                                       _responderCommPubkey
                                       );

        return newTrade;
    }

    function numTrades()
    external
    view
    returns (uint num) {
        return createdTrades.length;
    }
}

contract DAIHardTrade {
    using SafeMath for uint;

    enum Phase {Creating, Open, Committed, Judgment, Closed}
    Phase public phase;

    modifier inPhase(Phase p) {
        require(phase == p, "inPhase check failed.");
        _;
    }

    enum ClosedReason {NotClosed, Recalled, Aborted, Released, Burned}
    ClosedReason public closedReason;

    uint[5] public phaseStartTimestamps;
    uint[5] public phaseStartBlocknums;

    function changePhase(Phase p)
    internal {
        phase = p;
        phaseStartTimestamps[uint(p)] = block.timestamp;
        phaseStartBlocknums[uint(p)] = block.number;
    }


    address public initiator;
    address public responder;

    // The contract only has two parties, but depending on how it's opened,
    // the initiator for example might be either the custodian OR the beneficiary,
    // so we need four 'role' variables to capture each possible combination.

    bool public initiatorIsCustodian;
    address public custodian;
    address public beneficiary;

    modifier onlyInitiator() {
        require(msg.sender == initiator, "msg.sender is not Initiator.");
        _;
    }
    modifier onlyResponder() {
        require(msg.sender == responder, "msg.sender is not Responder.");
        _;
    }
    modifier onlyCustodian() {
        require (msg.sender == custodian, "msg.sender is not Custodian.");
        _;
    }
    modifier onlyBeneficiary() {
        require (msg.sender == beneficiary, "msg.sender is not Beneficiary.");
        _;
    }
    modifier onlyContractParty() { // Must be one of the two parties involved in the contract
        // Note this still covers the case in which responder still is 0x0, as msg.sender can never be 0x0,
        // in which case this will revert if msg.sender != initiator.
        require(msg.sender == initiator || msg.sender == responder, "msg.sender is not a party in this contract.");
        _;
    }

    ERC20Interface public daiContract;
    address public founderFeeAddress;
    address public devFeeAddress;

    bool public pokeRewardGranted;

    constructor(ERC20Interface _daiContract, address _founderFeeAddress, address _devFeeAddress)
    public {
        // If gas was not an issue we would leave the next three lines in for explicit clarity,
        // but technically they are a waste of gas, because we're simply setting them to the null values
        // (which happens automatically anyway when the contract is instantiated)

        // changePhase(Phase.Creating);
        // closedReason = ClosedReason.NotClosed;
        // pokeRewardGranted = false;

        daiContract = _daiContract;
        founderFeeAddress = _founderFeeAddress;
        devFeeAddress = _devFeeAddress;
    }

    uint public tradeAmount;
    uint public beneficiaryDeposit;
    uint public abortPunishment;

    uint public autorecallInterval;
    uint public autoabortInterval;
    uint public autoreleaseInterval;

    uint public pokeReward;
    uint public founderFee;
    uint public devFee;

    /* ---------------------- CREATING PHASE -----------------------

    The only reason for this phase is so the Factory can have somewhere
    to send the DAI before the Trade is truly initiated in the Opened phase.
    This way the trade can take into account its balance
    when setting its initial Open-phase state.

    The Factory creates the DAIHardTrade and moves it past this state in a single call,
    so any DAIHardTrade made by the factory should never be "seen" in this state
    (the DH interface ignores trades not created by the Factory contract).

    ------------------------------------------------------------ */

    event Initiated(string terms, string commPubkey);

    /*
    uintArgs:
    0 - responderDeposit
    1 - abortPunishment
    2 - pokeReward
    3 - autorecallInterval
    4 - autoabortInterval
    5 - autoreleaseInterval
    6 - founderFee
    7 - devFee
    */

    function beginInOpenPhase(address _initiator,
                              bool _initiatorIsCustodian,
                              uint[8] memory uintArgs,
                              string memory terms,
                              string memory commPubkey
                              )
    public
    inPhase(Phase.Creating)
    /* any msg.sender */ {
        uint responderDeposit = uintArgs[0];
        abortPunishment = uintArgs[1];
        pokeReward = uintArgs[2];

        autorecallInterval = uintArgs[3];
        autoabortInterval = uintArgs[4];
        autoreleaseInterval = uintArgs[5];

        founderFee = uintArgs[6];
        devFee = uintArgs[7];

        initiator = _initiator;
        initiatorIsCustodian = _initiatorIsCustodian;
        if (initiatorIsCustodian) {
            custodian = initiator;
            tradeAmount = getBalance().sub(pokeReward.add(founderFee).add(devFee));
            beneficiaryDeposit = responderDeposit;
        }
        else {
            beneficiary = initiator;
            tradeAmount = responderDeposit;
            beneficiaryDeposit = getBalance().sub(pokeReward.add(founderFee).add(devFee));
        }

        require(beneficiaryDeposit <= tradeAmount, "A beneficiaryDeposit greater than tradeAmount is not allowed.");
        require(abortPunishment <= beneficiaryDeposit, "An abortPunishment greater than beneficiaryDeposit is not allowed.");

        changePhase(Phase.Open);
        emit Initiated(terms, commPubkey);
    }

    /*
    uintArgs:
    0 - beneficiaryDeposit
    1 - abortPunishment
    2 - pokeReward
    3 - autoabortInterval
    4 - autoreleaseInterval
    5 - founderFee
    6 - devFee
    */

    function beginInCommittedPhase(address _custodian,
                                   address _beneficiary,
                                   bool _initiatorIsCustodian,
                                   uint[7] memory uintArgs,
                                   string memory terms,
                                   string memory initiatorCommPubkey,
                                   string memory responderCommPubkey
                                   )
    public
    inPhase(Phase.Creating)
    /* any msg.sender */{
        beneficiaryDeposit = uintArgs[0];
        abortPunishment = uintArgs[1];
        pokeReward = uintArgs[2];

        autoabortInterval = uintArgs[3];
        autoreleaseInterval = uintArgs[4];

        founderFee = uintArgs[5];
        devFee = uintArgs[6];

        custodian = _custodian;
        beneficiary = _beneficiary;
        initiatorIsCustodian = _initiatorIsCustodian;

        if (initiatorIsCustodian) {
            initiator = custodian;
            responder = beneficiary;
        }
        else {
            initiator = beneficiary;
            responder = custodian;
        }

        tradeAmount = getBalance().sub(beneficiaryDeposit.add(pokeReward).add(founderFee).add(devFee));

        require(beneficiaryDeposit <= tradeAmount, "A beneficiaryDeposit greater than tradeAmount is not allowed.");
        require(abortPunishment <= beneficiaryDeposit, "An abortPunishment greater than beneficiaryDeposit is not allowed.");

        changePhase(Phase.Committed);

        emit Initiated(terms, initiatorCommPubkey);
        emit Committed(responder, responderCommPubkey);
    }

    /* ---------------------- OPEN PHASE --------------------------

    In the Open phase, the Initiator (who may be the Custodian or the Beneficiary)
    waits for a Responder (who will claim the remaining role).
    We move to the Commited phase once someone becomes the Responder by executing commit(),
    which requires a successful withdraw of tokens from msg.sender of getResponderDeposit
    (either tradeAmount or beneficiaryDeposit, depending on the role of the responder).

    At any time in this phase, the Initiator can cancel the whole thing by calling recall().
    This returns the trade's entire balance including fees to the Initiator.

    After autorecallInterval has passed, the only state change allowed is to recall,
    which at that point can be triggered by anyone via poke().

    ------------------------------------------------------------ */

    event Recalled();
    event Committed(address responder, string commPubkey);

    function recall()
    external
    inPhase(Phase.Open)
    onlyInitiator() {
       internalRecall();
    }

    function internalRecall()
    internal {
        changePhase(Phase.Closed);
        closedReason = ClosedReason.Recalled;

        emit Recalled();

        require(daiContract.transfer(initiator, getBalance()), "Recall of DAI to initiator failed!");
        // Note that this will also return the founderFee and devFee to the intiator,
        // as well as the pokeReward if it hasn't yet been sent.
    }

    function autorecallAvailable()
    public
    view
    inPhase(Phase.Open)
    returns(bool available) {
        return (block.timestamp >= phaseStartTimestamps[uint(Phase.Open)].add(autorecallInterval));
    }

    function commit(address _responder, string calldata commPubkey)
    external
    inPhase(Phase.Open)
    /* any msg.sender */ {
        require(!autorecallAvailable(), "autorecallInterval has passed; this offer has expired.");

        responder = _responder;

        if (initiatorIsCustodian) {
            beneficiary = responder;
        }
        else {
            custodian = responder;
        }

        changePhase(Phase.Committed);
        emit Committed(responder, commPubkey);

        require(daiContract.transferFrom(msg.sender, address(this), getResponderDeposit()),
                                         "Can't transfer the required deposit from the DAI contract. Did you call approve first?"
                                         );
    }

    /* ---------------------- COMMITTED PHASE ---------------------

    In the Committed phase, the Beneficiary is expected to deposit fiat for the DAI,
    then call claim().

    Otherwise, the Beneficiary can call abort(), which cancels the contract,
    incurs a small penalty on both parties, and returns the remainder to each party.

    After autoabortInterval has passed, the only state change allowed is to abort,
    which can be triggered by anyone via poke().

    ------------------------------------------------------------ */

    event Claimed();
    event Aborted();

    function abort()
    external
    inPhase(Phase.Committed)
    onlyBeneficiary() {
        internalAbort();
    }

    function internalAbort()
    internal {
        changePhase(Phase.Closed);
        closedReason = ClosedReason.Aborted;

        emit Aborted();

        // Punish both parties equally by burning abortPunishment.
        // Instead of burning abortPunishment twice, just burn it all in one call (saves gas).
        require(daiContract.transfer(address(0x0), abortPunishment*2), "Token burn failed!");
        // Security note: The above line risks overflow, but only if abortPunishment >= (maxUint/2).
        // This should never happen, as abortPunishment <= beneficiaryDeposit <= tradeAmount (as required in both beginIn*Phase functions),
        // which is ultimately limited by the amount of DAI the user deposited (which must be far less than maxUint/2).
        // See the note below about avoiding assert() or require() to test this.

        // Send back deposits minus burned amounts.
        require(daiContract.transfer(beneficiary, beneficiaryDeposit.sub(abortPunishment)), "Token transfer to Beneficiary failed!");
        require(daiContract.transfer(custodian, tradeAmount.sub(abortPunishment)), "Token transfer to Custodian failed!");

        // Refund to initiator should include founderFee and devFee
        uint sendBackToInitiator = founderFee.add(devFee);
        // If there was a pokeReward left, it should also be sent back to the initiator
        if (!pokeRewardGranted) {
            sendBackToInitiator = sendBackToInitiator.add(pokeReward);
        }

        require(daiContract.transfer(initiator, sendBackToInitiator), "Token refund of founderFee+devFee+pokeReward to Initiator failed!");
    }

    function autoabortAvailable()
    public
    view
    inPhase(Phase.Committed)
    returns(bool passed) {
        return (block.timestamp >= phaseStartTimestamps[uint(Phase.Committed)].add(autoabortInterval));
    }

    function claim()
    external
    inPhase(Phase.Committed)
    onlyBeneficiary() {
        require(!autoabortAvailable(), "The deposit deadline has passed!");

        changePhase(Phase.Judgment);
        emit Claimed();
    }

    /* ---------------------- CLAIMED PHASE -----------------------

    In the Judgment phase, the Custodian can call release() or burn(),
    and is expected to call burn() only if the Beneficiary did meet the terms
    described in the 'terms' value logged with the Initiated event.

    After autoreleaseInterval has passed, the only state change allowed is to release,
    which can be triggered by anyone via poke().

    In the case of a burn, all fees are burned as well.

    ------------------------------------------------------------ */

    event Released();
    event Burned();

    function release()
    external
    inPhase(Phase.Judgment)
    onlyCustodian() {
        internalRelease();
    }

    function internalRelease()
    internal {
        changePhase(Phase.Closed);
        closedReason = ClosedReason.Released;

        emit Released();

        //If the pokeReward has not been sent, refund it to the initiator
        if (!pokeRewardGranted) {
            require(daiContract.transfer(initiator, pokeReward), "Refund of pokeReward to Initiator failed!");
        }

        // Upon successful resolution of trade, the founderFee is sent to the founders of DAIHard,
        // and the devFee is sent to wherever the original Factory creation call specified.
        require(daiContract.transfer(founderFeeAddress, founderFee), "Token transfer to founderFeeAddress failed!");
        require(daiContract.transfer(devFeeAddress, devFee), "Token transfer to devFeeAddress failed!");

        //Release the remaining balance to the beneficiary.
        require(daiContract.transfer(beneficiary, getBalance()), "Final release transfer to beneficiary failed!");
    }

    function autoreleaseAvailable()
    public
    view
    inPhase(Phase.Judgment)
    returns(bool available) {
        return (block.timestamp >= phaseStartTimestamps[uint(Phase.Judgment)].add(autoreleaseInterval));
    }

    function burn()
    external
    inPhase(Phase.Judgment)
    onlyCustodian() {
        require(!autoreleaseAvailable(), "autorelease has passed; you can no longer call burn.");

        internalBurn();
    }

    function internalBurn()
    internal {
        changePhase(Phase.Closed);
        closedReason = ClosedReason.Burned;

        emit Burned();

        require(daiContract.transfer(address(0x0), getBalance()), "Final DAI burn failed!");
        // Note that this also burns founderFee and devFee.
    }

    /* ---------------------- ANY-PHASE METHODS ----------------------- */

    /*
    If the contract is due for some auto___ phase transition,
    anyone can call the poke() function to trigger this transition,
    and the caller will be rewarded with pokeReward.
    */

    event Poke();

    function pokeNeeded()
    public
    view
    /* any phase */
    /* any msg.sender */
    returns (bool needed) {
        return (  (phase == Phase.Open      && autorecallAvailable() )
               || (phase == Phase.Committed && autoabortAvailable()  )
               || (phase == Phase.Judgment  && autoreleaseAvailable())
               );
    }

    function grantPokeRewardToSender()
    internal {
        require(!pokeRewardGranted, "The poke reward has already been sent!"); // Extra protection against re-entrancy
        pokeRewardGranted = true;
        daiContract.transfer(msg.sender, pokeReward);
    }

    function poke()
    external
    /* any phase */
    /* any msg.sender */
    returns (bool moved) {
        if (phase == Phase.Open && autorecallAvailable()) {
            grantPokeRewardToSender();
            emit Poke();

            internalRecall();
            return true;
        }
        else if (phase == Phase.Committed && autoabortAvailable()) {
            grantPokeRewardToSender();
            emit Poke();

            internalAbort();
            return true;
        }
        else if (phase == Phase.Judgment && autoreleaseAvailable()) {
            grantPokeRewardToSender();
            emit Poke();

            internalRelease();
            return true;
        }
        else return false;
    }

    /*
    StatementLogs allow a starting point for any necessary communication,
    and can be used anytime (even in the Closed phase).
    */

    event InitiatorStatementLog(string statement);
    event ResponderStatementLog(string statement);

    function initiatorStatement(string memory statement)
    public
    /* any phase */
    onlyInitiator() {
        emit InitiatorStatementLog(statement);
    }

    function responderStatement(string memory statement)
    public
    /* any phase */
    onlyResponder() {
        emit ResponderStatementLog(statement);
    }

    /* ---------------------- ANY-PHASE GETTERS ----------------------- */

    function getResponderDeposit()
    public
    view
    /* any phase */
    /* any msg.sender */
    returns(uint responderDeposit) {
        if (initiatorIsCustodian) {
            return beneficiaryDeposit;
        }
        else {
            return tradeAmount;
        }
    }

    function getState()
    external
    view
    /* any phase */
    /* any msg.sender */
    returns(uint balance, Phase phase, uint phaseStartTimestamp, address responder, ClosedReason closedReason) {
        return (getBalance(), this.phase(), phaseStartTimestamps[uint(this.phase())], this.responder(), this.closedReason());
    }

    function getBalance()
    public
    view
    /* any phase */
    /* any msg.sender */
    returns(uint) {
        return daiContract.balanceOf(address(this));
    }

    function getParameters()
    external
    view
    /* any phase */
    /* any msg.sender */
    returns (address initiator,
             bool initiatorIsCustodian,
             uint tradeAmount,
             uint beneficiaryDeposit,
             uint abortPunishment,
             uint autorecallInterval,
             uint autoabortInterval,
             uint autoreleaseInterval,
             uint pokeReward
             )
    {
        return (this.initiator(),
                this.initiatorIsCustodian(),
                this.tradeAmount(),
                this.beneficiaryDeposit(),
                this.abortPunishment(),
                this.autorecallInterval(),
                this.autoabortInterval(),
                this.autoreleaseInterval(),
                this.pokeReward()
                );
    }

    function getPhaseStartInfo()
    external
    view
    /* any phase */
    /* any msg.sender */
    returns (uint, uint, uint, uint, uint, uint, uint, uint, uint, uint)
    {
        return (phaseStartBlocknums[0],
                phaseStartBlocknums[1],
                phaseStartBlocknums[2],
                phaseStartBlocknums[3],
                phaseStartBlocknums[4],
                phaseStartTimestamps[0],
                phaseStartTimestamps[1],
                phaseStartTimestamps[2],
                phaseStartTimestamps[3],
                phaseStartTimestamps[4]
                );
    }
}
