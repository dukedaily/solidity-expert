



// Copyright (C) 2015 Forecast Foundation OU, full GPL notice in LICENSE

// Bid / Ask actions: puts orders on the book
// price is denominated by the specific market's numTicks
// amount is the number of attoshares the order is for (either to buy or to sell).
// price is the exact price you want to buy/sell at [which may not be the cost, for example to short a yesNo market it'll cost numTicks-price, to go long it'll cost price]






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




interface IStandardToken {
    function noHooksTransfer(address recipient, uint256 amount) external returns (bool);
}


contract ITyped {
    function getTypeName() public view returns (bytes32);
}


contract IReputationToken is IERC20 {
    function migrateOutByPayout(uint256[] memory _payoutNumerators, uint256 _attotokens) public returns (bool);
    function migrateIn(address _reporter, uint256 _attotokens) public returns (bool);
    function trustedReportingParticipantTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function trustedMarketTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function trustedUniverseTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function trustedDisputeWindowTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function getUniverse() public view returns (IUniverse);
    function getTotalMigrated() public view returns (uint256);
    function getTotalTheoreticalSupply() public view returns (uint256);
    function mintForReportingParticipant(uint256 _amountMigrated) public returns (bool);
}


contract IV2ReputationToken is IReputationToken, IStandardToken {
    function burnForMarket(uint256 _amountToBurn) public returns (bool);
    function mintForUniverse(uint256 _amountToMint, address _target) public returns (bool);
}






contract IOwnable {
    function getOwner() public view returns (address);
    function transferOwnership(address _newOwner) public returns (bool);
}




contract ICash is IERC20 {
    function joinMint(address usr, uint wad) public returns (bool);
    function joinBurn(address usr, uint wad) public returns (bool);
}




contract IShareToken is ITyped, IERC20 {
    function initialize(IAugur _augur, IMarket _market, uint256 _outcome, address _erc1820RegistryAddress) external;
    function createShares(address _owner, uint256 _amount) external returns (bool);
    function destroyShares(address, uint256 balance) external returns (bool);
    function getMarket() external view returns (IMarket);
    function getOutcome() external view returns (uint256);
    function trustedOrderTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function trustedFillOrderTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function trustedCancelOrderTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
}



contract IReportingParticipant {
    function getStake() public view returns (uint256);
    function getPayoutDistributionHash() public view returns (bytes32);
    function liquidateLosing() public;
    function redeem(address _redeemer) public returns (bool);
    function isDisavowed() public view returns (bool);
    function getPayoutNumerator(uint256 _outcome) public view returns (uint256);
    function getPayoutNumerators() public view returns (uint256[] memory);
    function getMarket() public view returns (IMarket);
    function getSize() public view returns (uint256);
}



contract IInitialReporter is IReportingParticipant {
    function initialize(IAugur _augur, IMarket _market, address _designatedReporter) public;
    function report(address _reporter, bytes32 _payoutDistributionHash, uint256[] memory _payoutNumerators, uint256 _initialReportStake) public;
    function designatedReporterShowed() public view returns (bool);
    function designatedReporterWasCorrect() public view returns (bool);
    function getDesignatedReporter() public view returns (address);
    function getReportTimestamp() public view returns (uint256);
    function migrateToNewUniverse(address _designatedReporter) public;
    function returnRepFromDisavow() public;
}


contract IMarket is IOwnable {
    enum MarketType {
        YES_NO,
        CATEGORICAL,
        SCALAR
    }

    function initialize(IAugur _augur, IUniverse _universe, uint256 _endTime, uint256 _feePerCashInAttoCash, uint256 _affiliateFeeDivisor, address _designatedReporterAddress, address _creator, uint256 _numOutcomes, uint256 _numTicks) public;
    function derivePayoutDistributionHash(uint256[] memory _payoutNumerators) public view returns (bytes32);
    function getUniverse() public view returns (IUniverse);
    function getDisputeWindow() public view returns (IDisputeWindow);
    function getNumberOfOutcomes() public view returns (uint256);
    function getNumTicks() public view returns (uint256);
    function getShareToken(uint256 _outcome)  public view returns (IShareToken);
    function getMarketCreatorSettlementFeeDivisor() public view returns (uint256);
    function getForkingMarket() public view returns (IMarket _market);
    function getEndTime() public view returns (uint256);
    function getWinningPayoutDistributionHash() public view returns (bytes32);
    function getWinningPayoutNumerator(uint256 _outcome) public view returns (uint256);
    function getWinningReportingParticipant() public view returns (IReportingParticipant);
    function getReputationToken() public view returns (IV2ReputationToken);
    function getFinalizationTime() public view returns (uint256);
    function getInitialReporter() public view returns (IInitialReporter);
    function getDesignatedReportingEndTime() public view returns (uint256);
    function getValidityBondAttoCash() public view returns (uint256);
    function deriveMarketCreatorFeeAmount(uint256 _amount) public view returns (uint256);
    function recordMarketCreatorFees(uint256 _marketCreatorFees, address _affiliateAddress) public returns (bool);
    function isContainerForShareToken(IShareToken _shadyTarget) public view returns (bool);
    function isContainerForReportingParticipant(IReportingParticipant _reportingParticipant) public view returns (bool);
    function isInvalid() public view returns (bool);
    function finalize() public returns (bool);
    function designatedReporterWasCorrect() public view returns (bool);
    function designatedReporterShowed() public view returns (bool);
    function isFinalized() public view returns (bool);
    function assertBalances() public view returns (bool);
}


contract IDisputeWindow is ITyped, IERC20 {
    uint256 public invalidMarketsTotal;
    uint256 public validityBondTotal;

    uint256 public incorrectDesignatedReportTotal;
    uint256 public initialReportBondTotal;

    uint256 public designatedReportNoShowsTotal;
    uint256 public designatedReporterNoShowBondTotal;

    function initialize(IAugur _augur, IUniverse _universe, uint256 _disputeWindowId, uint256 _duration, uint256 _startTime, address _erc1820RegistryAddress) public;
    function trustedBuy(address _buyer, uint256 _attotokens) public returns (bool);
    function getUniverse() public view returns (IUniverse);
    function getReputationToken() public view returns (IReputationToken);
    function getStartTime() public view returns (uint256);
    function getEndTime() public view returns (uint256);
    function getWindowId() public view returns (uint256);
    function isActive() public view returns (bool);
    function isOver() public view returns (bool);
    function onMarketFinalized() public;
    function redeem(address _account) public returns (bool);
}


contract IUniverse {
    mapping(address => uint256) public marketBalance;

    function fork() public returns (bool);
    function updateForkValues() public returns (bool);
    function getParentUniverse() public view returns (IUniverse);
    function createChildUniverse(uint256[] memory _parentPayoutNumerators) public returns (IUniverse);
    function getChildUniverse(bytes32 _parentPayoutDistributionHash) public view returns (IUniverse);
    function getReputationToken() public view returns (IV2ReputationToken);
    function getForkingMarket() public view returns (IMarket);
    function getForkEndTime() public view returns (uint256);
    function getForkReputationGoal() public view returns (uint256);
    function getParentPayoutDistributionHash() public view returns (bytes32);
    function getDisputeRoundDurationInSeconds(bool _initial) public view returns (uint256);
    function getOrCreateDisputeWindowByTimestamp(uint256 _timestamp, bool _initial) public returns (IDisputeWindow);
    function getOrCreateCurrentDisputeWindow(bool _initial) public returns (IDisputeWindow);
    function getOrCreateNextDisputeWindow(bool _initial) public returns (IDisputeWindow);
    function getOrCreatePreviousDisputeWindow(bool _initial) public returns (IDisputeWindow);
    function getOpenInterestInAttoCash() public view returns (uint256);
    function getRepMarketCapInAttoCash() public view returns (uint256);
    function getTargetRepMarketCapInAttoCash() public view returns (uint256);
    function getOrCacheValidityBond() public returns (uint256);
    function getOrCacheDesignatedReportStake() public returns (uint256);
    function getOrCacheDesignatedReportNoShowBond() public returns (uint256);
    function getOrCacheMarketRepBond() public returns (uint256);
    function getOrCacheReportingFeeDivisor() public returns (uint256);
    function getDisputeThresholdForFork() public view returns (uint256);
    function getDisputeThresholdForDisputePacing() public view returns (uint256);
    function getInitialReportMinValue() public view returns (uint256);
    function getPayoutNumerators() public view returns (uint256[] memory);
    function getReportingFeeDivisor() public view returns (uint256);
    function getPayoutNumerator(uint256 _outcome) public view returns (uint256);
    function getWinningChildPayoutNumerator(uint256 _outcome) public view returns (uint256);
    function isOpenInterestCash(address) public view returns (bool);
    function isForkingMarket() public view returns (bool);
    function getCurrentDisputeWindow(bool _initial) public view returns (IDisputeWindow);
    function isParentOf(IUniverse _shadyChild) public view returns (bool);
    function updateTentativeWinningChildUniverse(bytes32 _parentPayoutDistributionHash) public returns (bool);
    function isContainerForDisputeWindow(IDisputeWindow _shadyTarget) public view returns (bool);
    function isContainerForMarket(IMarket _shadyTarget) public view returns (bool);
    function isContainerForReportingParticipant(IReportingParticipant _reportingParticipant) public view returns (bool);
    function isContainerForShareToken(IShareToken _shadyTarget) public view returns (bool);
    function migrateMarketOut(IUniverse _destinationUniverse) public returns (bool);
    function migrateMarketIn(IMarket _market, uint256 _cashBalance, uint256 _marketOI) public returns (bool);
    function decrementOpenInterest(uint256 _amount) public returns (bool);
    function decrementOpenInterestFromMarket(IMarket _market) public returns (bool);
    function incrementOpenInterest(uint256 _amount) public returns (bool);
    function getWinningChildUniverse() public view returns (IUniverse);
    function isForking() public view returns (bool);
    function assertMarketBalance() public view returns (bool);
    function deposit(address _sender, uint256 _amount, address _market) public returns (bool);
    function withdraw(address _recipient, uint256 _amount, address _market) public returns (bool);
}


contract IAugur {
    function createChildUniverse(bytes32 _parentPayoutDistributionHash, uint256[] memory _parentPayoutNumerators) public returns (IUniverse);
    function isKnownUniverse(IUniverse _universe) public view returns (bool);
    function trustedTransfer(IERC20 _token, address _from, address _to, uint256 _amount) public returns (bool);
    function isTrustedSender(address _address) public returns (bool);
    function logCategoricalMarketCreated(uint256 _endTime, string memory _extraInfo, IMarket _market, address _marketCreator, address _designatedReporter, uint256 _feePerCashInAttoCash, bytes32[] memory _outcomes) public returns (bool);
    function logYesNoMarketCreated(uint256 _endTime, string memory _extraInfo, IMarket _market, address _marketCreator, address _designatedReporter, uint256 _feePerCashInAttoCash) public returns (bool);
    function logScalarMarketCreated(uint256 _endTime, string memory _extraInfo, IMarket _market, address _marketCreator, address _designatedReporter, uint256 _feePerCashInAttoCash, int256[] memory _prices, uint256 _numTicks)  public returns (bool);
    function logInitialReportSubmitted(IUniverse _universe, address _reporter, address _market, uint256 _amountStaked, bool _isDesignatedReporter, uint256[] memory _payoutNumerators, string memory _description, uint256 _nextWindowStartTime, uint256 _nextWindowEndTime) public returns (bool);
    function disputeCrowdsourcerCreated(IUniverse _universe, address _market, address _disputeCrowdsourcer, uint256[] memory _payoutNumerators, uint256 _size, uint256 _disputeRound) public returns (bool);
    function logDisputeCrowdsourcerContribution(IUniverse _universe, address _reporter, address _market, address _disputeCrowdsourcer, uint256 _amountStaked, string memory description, uint256[] memory _payoutNumerators, uint256 _currentStake, uint256 _stakeRemaining, uint256 _disputeRound) public returns (bool);
    function logDisputeCrowdsourcerCompleted(IUniverse _universe, address _market, address _disputeCrowdsourcer, uint256[] memory _payoutNumerators, uint256 _nextWindowStartTime, uint256 _nextWindowEndTime, bool _pacingOn, uint256 _totalRepStakedInPayout, uint256 _totalRepStakedInMarket, uint256 _disputeRound) public returns (bool);
    function logInitialReporterRedeemed(IUniverse _universe, address _reporter, address _market, uint256 _amountRedeemed, uint256 _repReceived, uint256[] memory _payoutNumerators) public returns (bool);
    function logDisputeCrowdsourcerRedeemed(IUniverse _universe, address _reporter, address _market, uint256 _amountRedeemed, uint256 _repReceived, uint256[] memory _payoutNumerators) public returns (bool);
    function logMarketFinalized(IUniverse _universe, uint256[] memory _winningPayoutNumerators) public returns (bool);
    function logMarketMigrated(IMarket _market, IUniverse _originalUniverse) public returns (bool);
    function logReportingParticipantDisavowed(IUniverse _universe, IMarket _market) public returns (bool);
    function logMarketParticipantsDisavowed(IUniverse _universe) public returns (bool);
    function logOrderCanceled(IUniverse _universe, IMarket _market, address _creator, uint256 _tokenRefund, uint256 _sharesRefund, bytes32 _orderId) public returns (bool);
    function logOrderCreated(IUniverse _universe, bytes32 _orderId, bytes32 _tradeGroupId) public returns (bool);
    function logOrderFilled(IUniverse _universe, address _creator, address _filler, uint256 _price, uint256 _fees, uint256 _amountFilled, bytes32 _orderId, bytes32 _tradeGroupId) public returns (bool);
    function logZeroXOrderFilled(IUniverse _universe, IMarket _market, bytes32 _tradeGroupId, Order.Types _orderType, address[] memory _addressData, uint256[] memory _uint256Data) public returns (bool);
    function logCompleteSetsPurchased(IUniverse _universe, IMarket _market, address _account, uint256 _numCompleteSets) public returns (bool);
    function logCompleteSetsSold(IUniverse _universe, IMarket _market, address _account, uint256 _numCompleteSets, uint256 _fees) public returns (bool);
    function logMarketOIChanged(IUniverse _universe, IMarket _market) public returns (bool);
    function logTradingProceedsClaimed(IUniverse _universe, address _shareToken, address _sender, address _market, uint256 _outcome, uint256 _numShares, uint256 _numPayoutTokens, uint256 _finalTokenBalance, uint256 _fees) public returns (bool);
    function logUniverseForked(IMarket _forkingMarket) public returns (bool);
    function logShareTokensTransferred(IUniverse _universe, address _from, address _to, uint256 _value, uint256 _fromBalance, uint256 _toBalance, uint256 _outcome) public returns (bool);
    function logReputationTokensTransferred(IUniverse _universe, address _from, address _to, uint256 _value, uint256 _fromBalance, uint256 _toBalance) public returns (bool);
    function logReputationTokensBurned(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance) public returns (bool);
    function logReputationTokensMinted(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance) public returns (bool);
    function logShareTokensBurned(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance, uint256 _outcome) public returns (bool);
    function logShareTokensMinted(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance, uint256 _outcome) public returns (bool);
    function logDisputeCrowdsourcerTokensTransferred(IUniverse _universe, address _from, address _to, uint256 _value, uint256 _fromBalance, uint256 _toBalance) public returns (bool);
    function logDisputeCrowdsourcerTokensBurned(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance) public returns (bool);
    function logDisputeCrowdsourcerTokensMinted(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance) public returns (bool);
    function logDisputeWindowCreated(IDisputeWindow _disputeWindow, uint256 _id, bool _initial) public returns (bool);
    function logParticipationTokensRedeemed(IUniverse universe, address _sender, uint256 _attoParticipationTokens, uint256 _feePayoutShare) public returns (bool);
    function logTimestampSet(uint256 _newTimestamp) public returns (bool);
    function logInitialReporterTransferred(IUniverse _universe, IMarket _market, address _from, address _to) public returns (bool);
    function logMarketTransferred(IUniverse _universe, address _from, address _to) public returns (bool);
    function logParticipationTokensTransferred(IUniverse _universe, address _from, address _to, uint256 _value, uint256 _fromBalance, uint256 _toBalance) public returns (bool);
    function logParticipationTokensBurned(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance) public returns (bool);
    function logParticipationTokensMinted(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance) public returns (bool);
    function logMarketVolumeChanged(IUniverse _universe, address _market, uint256 _volume, uint256[] memory _outcomeVolumes) public returns (bool);
    function logProfitLossChanged(IMarket _market, address _account, uint256 _outcome, int256 _netPosition, uint256 _avgPrice, int256 _realizedProfit, int256 _frozenFunds, int256 _realizedCost) public returns (bool);
    function isKnownFeeSender(address _feeSender) public view returns (bool);
    function isKnownShareToken(IShareToken _token) public view returns (bool);
    function lookup(bytes32 _key) public view returns (address);
    function getTimestamp() public view returns (uint256);
    function getMaximumMarketEndDate() public returns (uint256);
    function isKnownMarket(IMarket _market) public view returns (bool);
    function derivePayoutDistributionHash(uint256[] memory _payoutNumerators, uint256 _numTicks, uint256 numOutcomes) public view returns (bytes32);
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


// CONSIDER: Is `price` the most appropriate name for the value being used? It does correspond 1:1 with the attoCASH per share, but the range might be considered unusual?
library Order {
    using SafeMathUint256 for uint256;

    enum Types {
        Bid, Ask
    }

    enum TradeDirections {
        Long, Short
    }

    struct Data {
        // Contracts
        IOrders orders;
        IMarket market;
        IAugur augur;
        IERC20 kycToken;
        ICash cash;

        // Order
        bytes32 id;
        address creator;
        uint256 outcome;
        Order.Types orderType;
        uint256 amount;
        uint256 price;
        uint256 sharesEscrowed;
        uint256 moneyEscrowed;
        bytes32 betterOrderId;
        bytes32 worseOrderId;
    }

    // No validation is needed here as it is simply a library function for organizing data
    function create(IAugur _augur, address _creator, uint256 _outcome, Order.Types _type, uint256 _attoshares, uint256 _price, IMarket _market, bytes32 _betterOrderId, bytes32 _worseOrderId, IERC20 _kycToken) internal view returns (Data memory) {
        require(_outcome < _market.getNumberOfOutcomes(), "Order.create: Outcome is not within market range");
        require(_price != 0, "Order.create: Price may not be 0");
        require(_price < _market.getNumTicks(), "Order.create: Price is outside of market range");
        require(_attoshares > 0, "Order.create: Cannot use amount of 0");
        require(_creator != address(0), "Order.create: Creator is 0x0");

        IOrders _orders = IOrders(_augur.lookup("Orders"));

        return Data({
            orders: _orders,
            market: _market,
            augur: _augur,
            kycToken: _kycToken,
            cash: ICash(_augur.lookup("Cash")),
            id: 0,
            creator: _creator,
            outcome: _outcome,
            orderType: _type,
            amount: _attoshares,
            price: _price,
            sharesEscrowed: 0,
            moneyEscrowed: 0,
            betterOrderId: _betterOrderId,
            worseOrderId: _worseOrderId
        });
    }

    //
    // "public" functions
    //

    function getOrderId(Order.Data memory _orderData) internal view returns (bytes32) {
        if (_orderData.id == bytes32(0)) {
            bytes32 _orderId = _orderData.orders.getOrderId(_orderData.orderType, _orderData.market, _orderData.amount, _orderData.price, _orderData.creator, block.number, _orderData.outcome, _orderData.moneyEscrowed, _orderData.sharesEscrowed, _orderData.kycToken);
            require(_orderData.orders.getAmount(_orderId) == 0, "Order.getOrderId: New order had amount. This should not be possible");
            _orderData.id = _orderId;
        }
        return _orderData.id;
    }

    function getOrderTradingTypeFromMakerDirection(Order.TradeDirections _creatorDirection) internal pure returns (Order.Types) {
        return (_creatorDirection == Order.TradeDirections.Long) ? Order.Types.Bid : Order.Types.Ask;
    }

    function getOrderTradingTypeFromFillerDirection(Order.TradeDirections _fillerDirection) internal pure returns (Order.Types) {
        return (_fillerDirection == Order.TradeDirections.Long) ? Order.Types.Ask : Order.Types.Bid;
    }

    function escrowFunds(Order.Data memory _orderData) internal returns (bool) {
        if (_orderData.orderType == Order.Types.Ask) {
            return escrowFundsForAsk(_orderData);
        } else if (_orderData.orderType == Order.Types.Bid) {
            return escrowFundsForBid(_orderData);
        }
    }

    function saveOrder(Order.Data memory _orderData, bytes32 _tradeGroupId) internal returns (bytes32) {
        return _orderData.orders.saveOrder(_orderData.orderType, _orderData.market, _orderData.amount, _orderData.price, _orderData.creator, _orderData.outcome, _orderData.moneyEscrowed, _orderData.sharesEscrowed, _orderData.betterOrderId, _orderData.worseOrderId, _tradeGroupId, _orderData.kycToken);
    }

    //
    // Private functions
    //

    function escrowFundsForBid(Order.Data memory _orderData) private returns (bool) {
        require(_orderData.moneyEscrowed == 0, "Order.escrowFundsForBid: New order had money escrowed. This should not be possible");
        require(_orderData.sharesEscrowed == 0, "Order.escrowFundsForBid: New order had shares escrowed. This should not be possible");
        uint256 _attosharesToCover = _orderData.amount;
        uint256 _numberOfOutcomes = _orderData.market.getNumberOfOutcomes();

        // Figure out how many almost-complete-sets (just missing `outcome` share) the creator has
        uint256 _attosharesHeld = 2**254;
        for (uint256 _i = 0; _i < _numberOfOutcomes; _i++) {
            if (_i != _orderData.outcome) {
                uint256 _creatorShareTokenBalance = _orderData.market.getShareToken(_i).balanceOf(_orderData.creator);
                _attosharesHeld = SafeMathUint256.min(_creatorShareTokenBalance, _attosharesHeld);
            }
        }

        // Take shares into escrow if they have any almost-complete-sets
        if (_attosharesHeld > 0) {
            _orderData.sharesEscrowed = SafeMathUint256.min(_attosharesHeld, _attosharesToCover);
            _attosharesToCover -= _orderData.sharesEscrowed;
            for (uint256 _i = 0; _i < _numberOfOutcomes; _i++) {
                if (_i != _orderData.outcome) {
                    _orderData.market.getShareToken(_i).trustedOrderTransfer(_orderData.creator, address(_orderData.market), _orderData.sharesEscrowed);
                }
            }
        }

        // If not able to cover entire order with shares alone, then cover remaining with tokens
        if (_attosharesToCover > 0) {
            _orderData.moneyEscrowed = _attosharesToCover.mul(_orderData.price);
            _orderData.market.getUniverse().deposit(_orderData.creator, _orderData.moneyEscrowed, address(_orderData.market));
        }

        return true;
    }

    function escrowFundsForAsk(Order.Data memory _orderData) private returns (bool) {
        require(_orderData.moneyEscrowed == 0, "Order.escrowFundsForAsk: New order had money escrowed. This should not be possible");
        require(_orderData.sharesEscrowed == 0, "Order.escrowFundsForAsk: New order had shares escrowed. This should not be possible");
        IShareToken _shareToken = _orderData.market.getShareToken(_orderData.outcome);
        uint256 _attosharesToCover = _orderData.amount;

        // Figure out how many shares of the outcome the creator has
        uint256 _attosharesHeld = _shareToken.balanceOf(_orderData.creator);

        // Take shares in escrow if user has shares
        if (_attosharesHeld > 0) {
            _orderData.sharesEscrowed = SafeMathUint256.min(_attosharesHeld, _attosharesToCover);
            _attosharesToCover -= _orderData.sharesEscrowed;
            _shareToken.trustedOrderTransfer(_orderData.creator, address(_orderData.market), _orderData.sharesEscrowed);
        }

        // If not able to cover entire order with shares alone, then cover remaining with tokens
        if (_attosharesToCover > 0) {
            _orderData.moneyEscrowed = _orderData.market.getNumTicks().sub(_orderData.price).mul(_attosharesToCover);
            _orderData.market.getUniverse().deposit(_orderData.creator, _orderData.moneyEscrowed, address(_orderData.market));
        }

        return true;
    }
}


contract IOrders {
    function saveOrder(Order.Types _type, IMarket _market, uint256 _amount, uint256 _price, address _sender, uint256 _outcome, uint256 _moneyEscrowed, uint256 _sharesEscrowed, bytes32 _betterOrderId, bytes32 _worseOrderId, bytes32 _tradeGroupId, IERC20 _kycToken) external returns (bytes32 _orderId);
    function removeOrder(bytes32 _orderId) external returns (bool);
    function getMarket(bytes32 _orderId) public view returns (IMarket);
    function getOrderType(bytes32 _orderId) public view returns (Order.Types);
    function getOutcome(bytes32 _orderId) public view returns (uint256);
    function getAmount(bytes32 _orderId) public view returns (uint256);
    function getPrice(bytes32 _orderId) public view returns (uint256);
    function getOrderCreator(bytes32 _orderId) public view returns (address);
    function getOrderSharesEscrowed(bytes32 _orderId) public view returns (uint256);
    function getOrderMoneyEscrowed(bytes32 _orderId) public view returns (uint256);
    function getOrderDataForLogs(bytes32 _orderId) public view returns (Order.Types, address[] memory _addressData, uint256[] memory _uint256Data);
    function getBetterOrderId(bytes32 _orderId) public view returns (bytes32);
    function getWorseOrderId(bytes32 _orderId) public view returns (bytes32);
    function getKYCToken(bytes32 _orderId) public view returns (IERC20);
    function getBestOrderId(Order.Types _type, IMarket _market, uint256 _outcome, IERC20 _kycToken) public view returns (bytes32);
    function getWorstOrderId(Order.Types _type, IMarket _market, uint256 _outcome, IERC20 _kycToken) public view returns (bytes32);
    function getLastOutcomePrice(IMarket _market, uint256 _outcome) public view returns (uint256);
    function getOrderId(Order.Types _type, IMarket _market, uint256 _amount, uint256 _price, address _sender, uint256 _blockNumber, uint256 _outcome, uint256 _moneyEscrowed, uint256 _sharesEscrowed, IERC20 _kycToken) public pure returns (bytes32);
    function getTotalEscrowed(IMarket _market) public view returns (uint256);
    function isBetterPrice(Order.Types _type, uint256 _price, bytes32 _orderId) public view returns (bool);
    function isWorsePrice(Order.Types _type, uint256 _price, bytes32 _orderId) public view returns (bool);
    function assertIsNotBetterPrice(Order.Types _type, uint256 _price, bytes32 _betterOrderId) public view returns (bool);
    function assertIsNotWorsePrice(Order.Types _type, uint256 _price, bytes32 _worseOrderId) public returns (bool);
    function recordFillOrder(bytes32 _orderId, uint256 _sharesFilled, uint256 _tokensFilled, uint256 _fill) external returns (bool);
    function setPrice(IMarket _market, uint256 _outcome, uint256 _price) external returns (bool);
}


/**
 * @title SafeMathInt256
 * @dev Int256 math operations with safety checks that throw on error
 */
library SafeMathInt256 {
    // Signed ints with n bits can range from -2**(n-1) to (2**(n-1) - 1)
    int256 private constant INT256_MIN = -2**(255);
    int256 private constant INT256_MAX = (2**(255) - 1);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        // No need to check for dividing by 0 -- Solidity automatically throws on division by 0
        int256 c = a / b;
        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        require(((a >= 0) && (b >= a - INT256_MAX)) || ((a < 0) && (b <= a - INT256_MIN)));
        return a - b;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        require(((a >= 0) && (b <= INT256_MAX - a)) || ((a < 0) && (b >= INT256_MIN - a)));
        return a + b;
    }

    function min(int256 a, int256 b) internal pure returns (int256) {
        if (a <= b) {
            return a;
        } else {
            return b;
        }
    }

    function max(int256 a, int256 b) internal pure returns (int256) {
        if (a >= b) {
            return a;
        } else {
            return b;
        }
    }

    function abs(int256 a) internal pure returns (int256) {
        if (a < 0) {
            return -a;
        }
        return a;
    }

    function getInt256Min() internal pure returns (int256) {
        return INT256_MIN;
    }

    function getInt256Max() internal pure returns (int256) {
        return INT256_MAX;
    }

    // Float [fixed point] Operations
    function fxpMul(int256 a, int256 b, int256 base) internal pure returns (int256) {
        return div(mul(a, b), base);
    }

    function fxpDiv(int256 a, int256 b, int256 base) internal pure returns (int256) {
        return div(mul(a, base), b);
    }
}


contract Initializable {
    bool private initialized = false;

    modifier beforeInitialized {
        require(!initialized);
        _;
    }

    function endInitialization() internal beforeInitialized {
        initialized = true;
    }

    function getInitialized() public view returns (bool) {
        return initialized;
    }
}




contract IProfitLoss {
    function initialize(IAugur _augur) public;
    function recordFrozenFundChange(IMarket _market, address _account, uint256 _outcome, int256 _frozenFundDelta) public returns (bool);
    function adjustTraderProfitForFees(IMarket _market, address _trader, uint256 _outcome, uint256 _fees) public returns (bool);
    function recordTrade(IMarket _market, address _longAddress, address _shortAddress, uint256 _outcome, int256 _amount, int256 _price, uint256 _numLongTokens, uint256 _numShortTokens, uint256 _numLongShares, uint256 _numShortShares) public returns (bool);
    function recordClaim(IMarket _market, address _account, uint256[] memory _outcomeFees) public returns (bool);
    function recordExternalTransfer(address _source, address _destination, uint256 _value) public returns (bool);
}


/**
 * @title Orders
 * @notice Storage of all data associated with orders
 */
contract Orders is IOrders, Initializable {
    using Order for Order.Data;
    using SafeMathUint256 for uint256;

    struct MarketOrders {
        uint256 totalEscrowed;
        mapping(uint256 => uint256) prices;
    }

    mapping(bytes32 => Order.Data) private orders;
    mapping(address => MarketOrders) private marketOrderData;
    mapping(bytes32 => bytes32) private bestOrder;
    mapping(bytes32 => bytes32) private worstOrder;

    IAugur public augur;
    ICash public cash;
    address public trade;
    address public fillOrder;
    address public cancelOrder;
    address public createOrder;
    IProfitLoss public profitLoss;

    function initialize(IAugur _augur) public beforeInitialized {
        endInitialization();
        augur = _augur;
        createOrder = augur.lookup("CreateOrder");
        fillOrder = augur.lookup("FillOrder");
        cancelOrder = augur.lookup("CancelOrder");
        trade = augur.lookup("Trade");
        cash = ICash(augur.lookup("Cash"));
        profitLoss = IProfitLoss(augur.lookup("ProfitLoss"));
    }

    /**
     * @param _orderId The id of the order
     * @return The market associated with the order id
     */
    function getMarket(bytes32 _orderId) public view returns (IMarket) {
        return orders[_orderId].market;
    }

    /**
     * @param _orderId The id of the order
     * @return The order type (BID==0,ASK==1) associated with the order
     */
    function getOrderType(bytes32 _orderId) public view returns (Order.Types) {
        return orders[_orderId].orderType;
    }

    /**
     * @param _orderId The id of the order
     * @return The outcome associated with the order
     */
    function getOutcome(bytes32 _orderId) public view returns (uint256) {
        return orders[_orderId].outcome;
    }

    /**
     * @param _orderId The id of the order
     * @return The KYC token associated with the order
     */
    function getKYCToken(bytes32 _orderId) public view returns (IERC20) {
        return orders[_orderId].kycToken;
    }

    /**
     * @param _orderId The id of the order
     * @return The remaining amount of the order
     */
    function getAmount(bytes32 _orderId) public view returns (uint256) {
        return orders[_orderId].amount;
    }

    /**
     * @param _orderId The id of the order
     * @return The price of the order
     */
    function getPrice(bytes32 _orderId) public view returns (uint256) {
        return orders[_orderId].price;
    }

    /**
     * @param _orderId The id of the order
     * @return The creator of the order
     */
    function getOrderCreator(bytes32 _orderId) public view returns (address) {
        return orders[_orderId].creator;
    }

    /**
     * @param _orderId The id of the order
     * @return The remaining shares escrowed in the order
     */
    function getOrderSharesEscrowed(bytes32 _orderId) public view returns (uint256) {
        return orders[_orderId].sharesEscrowed;
    }

    /**
     * @param _orderId The id of the order
     * @return The remaining Cash tokens escrowed in the order
     */
    function getOrderMoneyEscrowed(bytes32 _orderId) public view returns (uint256) {
        return orders[_orderId].moneyEscrowed;
    }

    function getOrderDataForLogs(bytes32 _orderId) public view returns (Order.Types _type, address[] memory _addressData, uint256[] memory _uint256Data) {
        Order.Data storage _order = orders[_orderId];
        _addressData = new address[](3);
        _uint256Data = new uint256[](10);
        _addressData[0] = address(_order.kycToken);
        _addressData[1] = _order.creator;
        _uint256Data[0] = _order.price;
        _uint256Data[1] = _order.amount;
        _uint256Data[2] = _order.outcome;
        _uint256Data[8] = _order.sharesEscrowed;
        _uint256Data[9] = _order.moneyEscrowed;
        return (_order.orderType, _addressData, _uint256Data);
    }

    /**
     * @param _market The address of the market
     * @return The amount of Cash escrowed for all orders for the specified market
     */
    function getTotalEscrowed(IMarket _market) public view returns (uint256) {
        return marketOrderData[address(_market)].totalEscrowed;
    }

    /**
     * @param _market The address of the market
     * @param _outcome The outcome number
     * @return The price for the last completed trade for the specified market and outcome
     */
    function getLastOutcomePrice(IMarket _market, uint256 _outcome) public view returns (uint256) {
        return marketOrderData[address(_market)].prices[_outcome];
    }

    /**
     * @param _orderId The id of the order
     * @return The id (if there is one) of the next order better than the provided one
     */
    function getBetterOrderId(bytes32 _orderId) public view returns (bytes32) {
        return orders[_orderId].betterOrderId;
    }

    /**
     * @param _orderId The id of the order
     * @return The id (if there is one) of the next order worse than the provided one
     */
    function getWorseOrderId(bytes32 _orderId) public view returns (bytes32) {
        return orders[_orderId].worseOrderId;
    }

    /**
     * @param _type The type of order. Either BID==0, or ASK==1
     * @param _market The market of the order
     * @param _outcome The outcome of the order
     * @param _kycToken The KYC token of the order
     * @return The id (if there is one) of the best order that satisfies the given parameters
     */
    function getBestOrderId(Order.Types _type, IMarket _market, uint256 _outcome, IERC20 _kycToken) public view returns (bytes32) {
        return bestOrder[getBestOrderWorstOrderHash(_market, _outcome, _type, _kycToken)];
    }

    /**
     * @param _type The type of order. Either BID==0, or ASK==1
     * @param _market The market of the order
     * @param _outcome The outcome of the order
     * @param _kycToken The KYC token of the order
     * @return The id (if there is one) of the worst order that satisfies the given parameters
     */
    function getWorstOrderId(Order.Types _type, IMarket _market, uint256 _outcome, IERC20 _kycToken) public view returns (bytes32) {
        return worstOrder[getBestOrderWorstOrderHash(_market, _outcome, _type, _kycToken)];
    }

    /**
     * @param _type The type of order. Either BID==0, or ASK==1
     * @param _market The market of the order
     * @param _amount The amount of the order
     * @param _price The price of the order
     * @param _sender The creator of the order
     * @param _blockNumber The blockNumber which the order was created in
     * @param _outcome The outcome of the order
     * @param _moneyEscrowed The amount of Cash tokens escrowed in the order
     * @param _sharesEscrowed The outcome Share tokens escrowed in the order
     * @param _kycToken The KYC token of the order
     * @return The order id that satisfies the given parameters
     */
    function getOrderId(Order.Types _type, IMarket _market, uint256 _amount, uint256 _price, address _sender, uint256 _blockNumber, uint256 _outcome, uint256 _moneyEscrowed, uint256 _sharesEscrowed, IERC20 _kycToken) public pure returns (bytes32) {
        return sha256(abi.encodePacked(_type, _market, _amount, _price, _sender, _blockNumber, _outcome, _moneyEscrowed, _sharesEscrowed, _kycToken));
    }

    function isBetterPrice(Order.Types _type, uint256 _price, bytes32 _orderId) public view returns (bool) {
        if (_type == Order.Types.Bid) {
            return (_price > orders[_orderId].price);
        } else if (_type == Order.Types.Ask) {
            return (_price < orders[_orderId].price);
        }
    }

    function isWorsePrice(Order.Types _type, uint256 _price, bytes32 _orderId) public view returns (bool) {
        if (_type == Order.Types.Bid) {
            return (_price <= orders[_orderId].price);
        } else {
            return (_price >= orders[_orderId].price);
        }
    }

    function assertIsNotBetterPrice(Order.Types _type, uint256 _price, bytes32 _betterOrderId) public view returns (bool) {
        require(!isBetterPrice(_type, _price, _betterOrderId), "Orders.assertIsNotBetterPrice: Is better price");
        return true;
    }

    function assertIsNotWorsePrice(Order.Types _type, uint256 _price, bytes32 _worseOrderId) public returns (bool) {
        require(!isWorsePrice(_type, _price, _worseOrderId), "Orders.assertIsNotWorsePrice: Is worse price");
        return true;
    }

    function insertOrderIntoList(Order.Data storage _order, bytes32 _betterOrderId, bytes32 _worseOrderId) private returns (bool) {
        bytes32 _bestOrderId = bestOrder[getBestOrderWorstOrderHash(_order.market, _order.outcome, _order.orderType, _order.kycToken)];
        bytes32 _worstOrderId = worstOrder[getBestOrderWorstOrderHash(_order.market, _order.outcome, _order.orderType, _order.kycToken)];
        (_betterOrderId, _worseOrderId) = findBoundingOrders(_order.orderType, _order.price, _bestOrderId, _worstOrderId, _betterOrderId, _worseOrderId);
        if (_order.orderType == Order.Types.Bid) {
            _bestOrderId = updateBestBidOrder(_order.id, _order.market, _order.price, _order.outcome, _order.kycToken);
            _worstOrderId = updateWorstBidOrder(_order.id, _order.market, _order.price, _order.outcome, _order.kycToken);
        } else {
            _bestOrderId = updateBestAskOrder(_order.id, _order.market, _order.price, _order.outcome, _order.kycToken);
            _worstOrderId = updateWorstAskOrder(_order.id, _order.market, _order.price, _order.outcome, _order.kycToken);
        }
        if (_bestOrderId == _order.id) {
            _betterOrderId = bytes32(0);
        }
        if (_worstOrderId == _order.id) {
            _worseOrderId = bytes32(0);
        }
        if (_betterOrderId != bytes32(0)) {
            orders[_betterOrderId].worseOrderId = _order.id;
            _order.betterOrderId = _betterOrderId;
        }
        if (_worseOrderId != bytes32(0)) {
            orders[_worseOrderId].betterOrderId = _order.id;
            _order.worseOrderId = _worseOrderId;
        }
        return true;
    }

    function saveOrder(Order.Types _type, IMarket _market, uint256 _amount, uint256 _price, address _sender, uint256 _outcome, uint256 _moneyEscrowed, uint256 _sharesEscrowed, bytes32 _betterOrderId, bytes32 _worseOrderId, bytes32 _tradeGroupId, IERC20 _kycToken) external returns (bytes32 _orderId) {
        require(msg.sender == createOrder || msg.sender == address(this));
        require(_outcome < _market.getNumberOfOutcomes(), "Orders.saveOrder: Outcome not in market range");
        _orderId = getOrderId(_type, _market, _amount, _price, _sender, block.number, _outcome, _moneyEscrowed, _sharesEscrowed, _kycToken);
        Order.Data storage _order = orders[_orderId];
        _order.orders = this;
        _order.market = _market;
        _order.id = _orderId;
        _order.orderType = _type;
        _order.outcome = _outcome;
        _order.price = _price;
        _order.amount = _amount;
        _order.creator = _sender;
        _order.kycToken = _kycToken;
        _order.moneyEscrowed = _moneyEscrowed;
        marketOrderData[address(_market)].totalEscrowed += _moneyEscrowed;
        _order.sharesEscrowed = _sharesEscrowed;
        insertOrderIntoList(_order, _betterOrderId, _worseOrderId);
        augur.logOrderCreated(_order.market.getUniverse(), _orderId, _tradeGroupId);
        return _orderId;
    }

    function removeOrder(bytes32 _orderId) external returns (bool) {
        require(msg.sender == cancelOrder || msg.sender == address(this));
        removeOrderFromList(_orderId);
        Order.Data storage _order = orders[_orderId];
        marketOrderData[address(_order.market)].totalEscrowed -= _order.moneyEscrowed;
        delete orders[_orderId];
        return true;
    }

    function recordFillOrder(bytes32 _orderId, uint256 _sharesFilled, uint256 _tokensFilled, uint256 _fill) external returns (bool) {
        require(msg.sender == fillOrder || msg.sender == address(this));
        Order.Data storage _order = orders[_orderId];
        require(_order.outcome < _order.market.getNumberOfOutcomes(), "Orders.recordFillOrder: Outcome is not in market range");
        require(_orderId != bytes32(0), "Orders.recordFillOrder: orderId is 0x0");
        require(_sharesFilled <= _order.sharesEscrowed, "Orders.recordFillOrder: shares filled higher than order amount");
        require(_tokensFilled <= _order.moneyEscrowed, "Orders.recordFillOrder: tokens filled higher than order amount");
        require(_order.price <= _order.market.getNumTicks(), "Orders.recordFillOrder: Price outside of market range");
        require(_fill <= _order.amount, "Orders.recordFillOrder: Fill higher than order amount");
        _order.amount -= _fill;
        _order.moneyEscrowed -= _tokensFilled;
        marketOrderData[address(_order.market)].totalEscrowed -= _tokensFilled;
        _order.sharesEscrowed -= _sharesFilled;
        if (_order.amount == 0) {
            require(_order.moneyEscrowed == 0, "Orders.recordFillOrder: Money left in filled order");
            require(_order.sharesEscrowed == 0, "Orders.recordFillOrder: Shares left in filled order");
            removeOrderFromList(_orderId);
            _order.price = 0;
            _order.creator = address(0);
            _order.betterOrderId = bytes32(0);
            _order.worseOrderId = bytes32(0);
        }
        return true;
    }

    function setPrice(IMarket _market, uint256 _outcome, uint256 _price) external returns (bool) {
        require(msg.sender == trade);
        marketOrderData[address(_market)].prices[_outcome] = _price;
        return true;
    }

    function removeOrderFromList(bytes32 _orderId) private returns (bool) {
        Order.Types _type = orders[_orderId].orderType;
        IMarket _market = orders[_orderId].market;
        uint256 _outcome = orders[_orderId].outcome;
        IERC20 _kycToken = orders[_orderId].kycToken;
        bytes32 _betterOrderId = orders[_orderId].betterOrderId;
        bytes32 _worseOrderId = orders[_orderId].worseOrderId;
        if (bestOrder[getBestOrderWorstOrderHash(_market, _outcome, _type, _kycToken)] == _orderId) {
            bestOrder[getBestOrderWorstOrderHash(_market, _outcome, _type, _kycToken)] = _worseOrderId;
        }
        if (worstOrder[getBestOrderWorstOrderHash(_market, _outcome, _type, _kycToken)] == _orderId) {
            worstOrder[getBestOrderWorstOrderHash(_market, _outcome, _type, _kycToken)] = _betterOrderId;
        }
        if (_betterOrderId != bytes32(0)) {
            orders[_betterOrderId].worseOrderId = _worseOrderId;
        }
        if (_worseOrderId != bytes32(0)) {
            orders[_worseOrderId].betterOrderId = _betterOrderId;
        }
        orders[_orderId].betterOrderId = bytes32(0);
        orders[_orderId].worseOrderId = bytes32(0);
        return true;
    }

    /**
     * @dev If best bid is not set or price higher than best bid price, this order is the new best bid.
     */
    function updateBestBidOrder(bytes32 _orderId, IMarket _market, uint256 _price, uint256 _outcome, IERC20 _kycToken) private returns (bytes32) {
        bytes32 _bestBidOrderId = bestOrder[getBestOrderWorstOrderHash(_market, _outcome, Order.Types.Bid, _kycToken)];
        if (_bestBidOrderId == bytes32(0) || _price > orders[_bestBidOrderId].price) {
            bestOrder[getBestOrderWorstOrderHash(_market, _outcome, Order.Types.Bid, _kycToken)] = _orderId;
        }
        return bestOrder[getBestOrderWorstOrderHash(_market, _outcome, Order.Types.Bid, _kycToken)];
    }

    /**
     * @dev If worst bid is not set or price lower than worst bid price, this order is the new worst bid.
     */
    function updateWorstBidOrder(bytes32 _orderId, IMarket _market, uint256 _price, uint256 _outcome, IERC20 _kycToken) private returns (bytes32) {
        bytes32 _worstBidOrderId = worstOrder[getBestOrderWorstOrderHash(_market, _outcome, Order.Types.Bid, _kycToken)];
        if (_worstBidOrderId == bytes32(0) || _price <= orders[_worstBidOrderId].price) {
            worstOrder[getBestOrderWorstOrderHash(_market, _outcome, Order.Types.Bid, _kycToken)] = _orderId;
        }
        return worstOrder[getBestOrderWorstOrderHash(_market, _outcome, Order.Types.Bid, _kycToken)];
    }

    /**
     * @dev If best ask is not set or price lower than best ask price, this order is the new best ask.
     */
    function updateBestAskOrder(bytes32 _orderId, IMarket _market, uint256 _price, uint256 _outcome, IERC20 _kycToken) private returns (bytes32) {
        bytes32 _bestAskOrderId = bestOrder[getBestOrderWorstOrderHash(_market, _outcome, Order.Types.Ask, _kycToken)];
        if (_bestAskOrderId == bytes32(0) || _price < orders[_bestAskOrderId].price) {
            bestOrder[getBestOrderWorstOrderHash(_market, _outcome, Order.Types.Ask, _kycToken)] = _orderId;
        }
        return bestOrder[getBestOrderWorstOrderHash(_market, _outcome, Order.Types.Ask, _kycToken)];
    }

    /**
     * @dev If worst ask is not set or price higher than worst ask price, this order is the new worst ask.
     */
    function updateWorstAskOrder(bytes32 _orderId, IMarket _market, uint256 _price, uint256 _outcome, IERC20 _kycToken) private returns (bytes32) {
        bytes32 _worstAskOrderId = worstOrder[getBestOrderWorstOrderHash(_market, _outcome, Order.Types.Ask, _kycToken)];
        if (_worstAskOrderId == bytes32(0) || _price >= orders[_worstAskOrderId].price) {
            worstOrder[getBestOrderWorstOrderHash(_market, _outcome, Order.Types.Ask, _kycToken)] = _orderId;
        }
        return worstOrder[getBestOrderWorstOrderHash(_market, _outcome, Order.Types.Ask, _kycToken)];
    }

    function getBestOrderWorstOrderHash(IMarket _market, uint256 _outcome, Order.Types _type, IERC20 _kycToken) private pure returns (bytes32) {
        return sha256(abi.encodePacked(_market, _outcome, _type, _kycToken));
    }

    function ascendOrderList(Order.Types _type, uint256 _price, bytes32 _lowestOrderId) public view returns (bytes32 _betterOrderId, bytes32 _worseOrderId) {
        _worseOrderId = _lowestOrderId;
        bool _isWorstPrice;
        if (_type == Order.Types.Bid) {
            _isWorstPrice = _price <= getPrice(_worseOrderId);
        } else if (_type == Order.Types.Ask) {
            _isWorstPrice = _price >= getPrice(_worseOrderId);
        }
        if (_isWorstPrice) {
            return (_worseOrderId, getWorseOrderId(_worseOrderId));
        }
        bool _isBetterPrice = isBetterPrice(_type, _price, _worseOrderId);
        while (_isBetterPrice && getBetterOrderId(_worseOrderId) != 0 && _price != getPrice(getBetterOrderId(_worseOrderId))) {
            _betterOrderId = getBetterOrderId(_worseOrderId);
            _isBetterPrice = isBetterPrice(_type, _price, _betterOrderId);
            if (_isBetterPrice) {
                _worseOrderId = getBetterOrderId(_worseOrderId);
            }
        }
        _betterOrderId = getBetterOrderId(_worseOrderId);
        return (_betterOrderId, _worseOrderId);
    }

    function descendOrderList(Order.Types _type, uint256 _price, bytes32 _highestOrderId) public view returns (bytes32 _betterOrderId, bytes32 _worseOrderId) {
        _betterOrderId = _highestOrderId;
        bool _isBestPrice;
        if (_type == Order.Types.Bid) {
            _isBestPrice = _price > getPrice(_betterOrderId);
        } else if (_type == Order.Types.Ask) {
            _isBestPrice = _price < getPrice(_betterOrderId);
        }
        if (_isBestPrice) {
            return (0, _betterOrderId);
        }
        bool _isWorsePrice = isWorsePrice(_type, _price, _betterOrderId);
        while (_isWorsePrice && getWorseOrderId(_betterOrderId) != 0) {
            _worseOrderId = getWorseOrderId(_betterOrderId);
            _isWorsePrice = isWorsePrice(_type, _price, _worseOrderId);
            if (_isWorsePrice || _price == getPrice(getWorseOrderId(_betterOrderId))) {
                _betterOrderId = getWorseOrderId(_betterOrderId);
            }
        }
        _worseOrderId = getWorseOrderId(_betterOrderId);
        return (_betterOrderId, _worseOrderId);
    }

    function findBoundingOrders(Order.Types _type, uint256 _price, bytes32 _bestOrderId, bytes32 _worstOrderId, bytes32 _betterOrderId, bytes32 _worseOrderId) public returns (bytes32 betterOrderId, bytes32 worseOrderId) {
        if (_bestOrderId == _worstOrderId) {
            if (_bestOrderId == bytes32(0)) {
                return (bytes32(0), bytes32(0));
            } else if (isBetterPrice(_type, _price, _bestOrderId)) {
                return (bytes32(0), _bestOrderId);
            } else {
                return (_bestOrderId, bytes32(0));
            }
        }
        if (_betterOrderId != bytes32(0)) {
            if (getPrice(_betterOrderId) == 0) {
                _betterOrderId = bytes32(0);
            } else {
                assertIsNotBetterPrice(_type, _price, _betterOrderId);
            }
        }
        if (_worseOrderId != bytes32(0)) {
            if (getPrice(_worseOrderId) == 0) {
                _worseOrderId = bytes32(0);
            } else {
                assertIsNotWorsePrice(_type, _price, _worseOrderId);
            }
        }
        if (_betterOrderId == bytes32(0) && _worseOrderId == bytes32(0)) {
            return (descendOrderList(_type, _price, _bestOrderId));
        } else if (_betterOrderId == bytes32(0)) {
            return (ascendOrderList(_type, _price, _worseOrderId));
        } else if (_worseOrderId == bytes32(0)) {
            return (descendOrderList(_type, _price, _betterOrderId));
        }
        if (getWorseOrderId(_betterOrderId) != _worseOrderId) {
            return (descendOrderList(_type, _price, _betterOrderId));
        } else if (getBetterOrderId(_worseOrderId) != _betterOrderId) {
            // Coverage: This condition is likely unreachable or at least seems to be. Rather than remove it I'm keeping it for now just to be paranoid
            return (ascendOrderList(_type, _price, _worseOrderId));
        }
        return (_betterOrderId, _worseOrderId);
    }
}
