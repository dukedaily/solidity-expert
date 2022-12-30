




contract IOwnable {
    function getOwner() public view returns (address);
    function transferOwnership(address _newOwner) public returns (bool);
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


contract ICash is IERC20 {
    function joinMint(address usr, uint wad) public returns (bool);
    function joinBurn(address usr, uint wad) public returns (bool);
}




contract ITyped {
    function getTypeName() public view returns (bytes32);
}





interface IStandardToken {
    function noHooksTransfer(address recipient, uint256 amount) external returns (bool);
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
// Copyright (C) 2015 Forecast Foundation OU, full GPL notice in LICENSE

// Bid / Ask actions: puts orders on the book
// price is denominated by the specific market's numTicks
// amount is the number of attoshares the order is for (either to buy or to sell).
// price is the exact price you want to buy/sell at [which may not be the cost, for example to short a yesNo market it'll cost numTicks-price, to go long it'll cost price]





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




/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable is IOwnable {
    address internal owner;

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

    function getOwner() public view returns (address) {
        return owner;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner) public onlyOwner returns (bool) {
        if (_newOwner != address(0)) {
            onTransferOwnership(owner, _newOwner);
            owner = _newOwner;
        }
        return true;
    }

    // Subclasses of this token may want to send additional logs through the centralized Augur log emitter contract
    function onTransferOwnership(address, address) internal;
}



contract IMap {
    function initialize(address _owner) public;
    function add(bytes32 _key, address _value) public returns (bool);
    function remove(bytes32 _key) public returns (bool);
    function get(bytes32 _key) public view returns (address);
    function getAsAddressOrZero(bytes32 _key) public view returns (address);
    function contains(bytes32 _key) public view returns (bool);
    function getCount() public view returns (uint256);
}


// Provides a mapping that has a count and more control over the behavior of Key errors. Additionally allows for a clean way to clear an existing map by simply creating a new one on owning contracts.
contract Map is Ownable, Initializable, IMap {
    mapping(bytes32 => address) private items;
    uint256 private count;

    function initialize(address _owner) public beforeInitialized {
        endInitialization();
        owner = _owner;
    }

    function add(bytes32 _key, address _value) public onlyOwner returns (bool) {
        require(_value != address(0));
        if (contains(_key)) {
            return false;
        }
        items[_key] = _value;
        count += 1;
        return true;
    }

    function remove(bytes32 _key) public onlyOwner returns (bool) {
        if (!contains(_key)) {
            return false;
        }
        delete items[_key];
        count -= 1;
        return true;
    }

    function get(bytes32 _key) public view returns (address) {
        address _value = items[_key];
        require(_value != address(0));
        return _value;
    }

    function getAsAddressOrZero(bytes32 _key) public view returns (address) {
        return items[_key];
    }

    function contains(bytes32 _key) public view returns (bool) {
        return items[_key] != address(0);
    }

    function getCount() public view returns (uint256) {
        return count;
    }

    function onTransferOwnership(address, address) internal {
    }
}



contract IDisputeCrowdsourcer is IReportingParticipant, IERC20 {
    function initialize(IAugur _augur, IMarket market, uint256 _size, bytes32 _payoutDistributionHash, uint256[] memory _payoutNumerators, address _erc1820RegistryAddress) public;
    function contribute(address _participant, uint256 _amount, bool _overload) public returns (uint256);
    function setSize(uint256 _size) public;
    function getRemainingToFill() public view returns (uint256);
    function correctSize() public returns (bool);
}



contract IDisputeCrowdsourcerFactory {
    function createDisputeCrowdsourcer(IAugur _augur, uint256 _size, bytes32 _payoutDistributionHash, uint256[] memory _payoutNumerators) public returns (IDisputeCrowdsourcer);
}



// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1167.md

/* Template Code for the create clone method:
  function createClone(address target) internal returns (address result) {
    bytes20 targetBytes = bytes20(target)${bytes == 20 ? "" : "<<" + ((20 - bytes) * 8)};
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x${code.substring(0, 2*(cloner.labels.address + 1)).padEnd(64, '0')})
      mstore(add(clone, 0x${(cloner.labels.address + 1).toString(16)}), targetBytes)
      mstore(add(clone, 0x${(cloner.labels.address + bytes + 1).toString(16)}), 0x${code.substring(2*(cloner.labels.address + bytes + 1), 2*(cloner.labels.address+bytes+1) + 30).padEnd(64, '0')})
      result := create(0, clone, 0x${(code.length / 2).toString(16)})
    }
  }
*/


contract CloneFactory {
    function createClone(address target) internal returns (address result) {
        // convert address to bytes20 for assembly use
        bytes20 targetBytes = bytes20(target);
        assembly {
            // allocate clone memory
            let clone := mload(0x40)
            // store initial portion of the delegation contract code in bytes form
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            // store the provided address
            mstore(add(clone, 0x14), targetBytes)
            // store the remaining delegation contract code
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            // create the actual delegate contract reference and return its address
            result := create(0, clone, 0x37)
        }
    }
}


/**
 * @title Share Token Factory
 * @notice A Factory contract to create Share Token contracts
 * @dev Should not be used directly. Only intended to be used by Market contracts.
 */
contract ShareTokenFactory is CloneFactory {
    function createShareToken(IAugur _augur, uint256 _outcome) public returns (IShareToken) {
        IMarket _market = IMarket(msg.sender);
        IShareToken _shareToken = IShareToken(createClone(_augur.lookup("ShareToken")));
        _shareToken.initialize(_augur, _market, _outcome, _augur.lookup("ERC1820Registry"));
        return _shareToken;
    }
}



/**
 * @title Initial Reporter Factory
 * @notice A Factory contract to create Initial Reporter delegate contracts
 * @dev Should not be used directly. Only intended to be used by Market contracts
 */
contract InitialReporterFactory is CloneFactory {
    function createInitialReporter(IAugur _augur, address _designatedReporter) public returns (IInitialReporter) {
        IMarket _market = IMarket(msg.sender);
        IInitialReporter _initialReporter = IInitialReporter(createClone(_augur.lookup("InitialReporter")));
        _initialReporter.initialize(_augur, _market, _designatedReporter);
        return _initialReporter;
    }
}



/**
 * @title Map Factory
 * @notice A Factory contract to create Map delegate contracts
 */
contract MapFactory is CloneFactory {
    function createMap(IAugur _augur, address _owner) public returns (IMap) {
        IMap _map = IMap(createClone(_augur.lookup("Map")));
        _map.initialize(_owner);
        return _map;
    }
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


library Reporting {
    uint256 private constant DESIGNATED_REPORTING_DURATION_SECONDS = 1 days;
    uint256 private constant DISPUTE_ROUND_DURATION_SECONDS = 7 days;
    uint256 private constant INITIAL_DISPUTE_ROUND_DURATION_SECONDS = 1 days;
    uint256 private constant DISPUTE_WINDOW_BUFFER_SECONDS = 1 hours;
    uint256 private constant FORK_DURATION_SECONDS = 60 days;

    uint256 private constant BASE_MARKET_DURATION_MAXIMUM = 30 days; // A market of 30 day length can always be created
    uint256 private constant UPGRADE_CADENCE = 365 days;
    uint256 private constant INITIAL_UPGRADE_TIMESTAMP = 1626307484; // July 15th 2021

    uint256 private constant INITIAL_REP_SUPPLY = 11 * 10 ** 6 * 10 ** 18; // 11 Million REP

    uint256 private constant DEFAULT_VALIDITY_BOND = 10 ether; // 10 Cash (Dai)
    uint256 private constant VALIDITY_BOND_FLOOR = 10 ether; // 10 Cash (Dai)
    uint256 private constant DEFAULT_REPORTING_FEE_DIVISOR = 100; // 1% fees
    uint256 private constant MAXIMUM_REPORTING_FEE_DIVISOR = 10000; // Minimum .01% fees
    uint256 private constant MINIMUM_REPORTING_FEE_DIVISOR = 3; // Maximum 33.3~% fees. Note than anything less than a value of 2 here will likely result in bugs such as divide by 0 cases.

    uint256 private constant TARGET_INVALID_MARKETS_DIVISOR = 100; // 1% of markets are expected to be invalid
    uint256 private constant TARGET_INCORRECT_DESIGNATED_REPORT_MARKETS_DIVISOR = 100; // 1% of markets are expected to have an incorrect designate report
    uint256 private constant TARGET_DESIGNATED_REPORT_NO_SHOWS_DIVISOR = 20; // 5% of markets are expected to have a no show
    uint256 private constant TARGET_REP_MARKET_CAP_MULTIPLIER = 5; // We multiply and divide by constants since we may want to multiply by a fractional amount

    uint256 private constant FORK_THRESHOLD_DIVISOR = 40; // 2.5% of the total REP supply being filled in a single dispute bond will trigger a fork
    uint256 private constant MAXIMUM_DISPUTE_ROUNDS = 20; // We ensure that after 20 rounds of disputes a fork will occur
    uint256 private constant MINIMUM_SLOW_ROUNDS = 8; // We ensure that at least 8 dispute rounds take DISPUTE_ROUND_DURATION_SECONDS+ seconds to complete until the next round begins

    function getDesignatedReportingDurationSeconds() internal pure returns (uint256) { return DESIGNATED_REPORTING_DURATION_SECONDS; }
    function getInitialDisputeRoundDurationSeconds() internal pure returns (uint256) { return INITIAL_DISPUTE_ROUND_DURATION_SECONDS; }
    function getDisputeWindowBufferSeconds() internal pure returns (uint256) { return DISPUTE_WINDOW_BUFFER_SECONDS; }
    function getDisputeRoundDurationSeconds() internal pure returns (uint256) { return DISPUTE_ROUND_DURATION_SECONDS; }
    function getForkDurationSeconds() internal pure returns (uint256) { return FORK_DURATION_SECONDS; }
    function getBaseMarketDurationMaximum() internal pure returns (uint256) { return BASE_MARKET_DURATION_MAXIMUM; }
    function getUpgradeCadence() internal pure returns (uint256) { return UPGRADE_CADENCE; }
    function getInitialUpgradeTimestamp() internal pure returns (uint256) { return INITIAL_UPGRADE_TIMESTAMP; }
    function getDefaultValidityBond() internal pure returns (uint256) { return DEFAULT_VALIDITY_BOND; }
    function getValidityBondFloor() internal pure returns (uint256) { return VALIDITY_BOND_FLOOR; }
    function getTargetInvalidMarketsDivisor() internal pure returns (uint256) { return TARGET_INVALID_MARKETS_DIVISOR; }
    function getTargetIncorrectDesignatedReportMarketsDivisor() internal pure returns (uint256) { return TARGET_INCORRECT_DESIGNATED_REPORT_MARKETS_DIVISOR; }
    function getTargetDesignatedReportNoShowsDivisor() internal pure returns (uint256) { return TARGET_DESIGNATED_REPORT_NO_SHOWS_DIVISOR; }
    function getTargetRepMarketCapMultiplier() internal pure returns (uint256) { return TARGET_REP_MARKET_CAP_MULTIPLIER; }
    function getMaximumReportingFeeDivisor() internal pure returns (uint256) { return MAXIMUM_REPORTING_FEE_DIVISOR; }
    function getMinimumReportingFeeDivisor() internal pure returns (uint256) { return MINIMUM_REPORTING_FEE_DIVISOR; }
    function getDefaultReportingFeeDivisor() internal pure returns (uint256) { return DEFAULT_REPORTING_FEE_DIVISOR; }
    function getInitialREPSupply() internal pure returns (uint256) { return INITIAL_REP_SUPPLY; }
    function getForkThresholdDivisor() internal pure returns (uint256) { return FORK_THRESHOLD_DIVISOR; }
    function getMaximumDisputeRounds() internal pure returns (uint256) { return MAXIMUM_DISPUTE_ROUNDS; }
    function getMinimumSlowRounds() internal pure returns (uint256) { return MINIMUM_SLOW_ROUNDS; }
}


/**
 * @title Market
 * @notice The contract which encapsulates event data and payout resolution for the event
 */
contract Market is Initializable, Ownable, IMarket {
    using SafeMathUint256 for uint256;
    using SafeMathInt256 for int256;

    // Constants
    uint256 private constant MAX_APPROVAL_AMOUNT = 2 ** 256 - 1;
    address private constant NULL_ADDRESS = address(0);

    // Contract Refs
    IUniverse private universe;
    IDisputeWindow private disputeWindow;
    ICash private cash;
    IAugur public augur;
    MapFactory public mapFactory;

    // Attributes
    uint256 private numTicks;
    uint256 private feeDivisor;
    uint256 public affiliateFeeDivisor;
    uint256 private endTime;
    uint256 private numOutcomes;
    bytes32 private winningPayoutDistributionHash;
    uint256 public validityBondAttoCash;
    uint256 private finalizationTime;
    uint256 public repBond;
    bool private disputePacingOn;
    address public repBondOwner;
    uint256 public marketCreatorFeesAttoCash;
    uint256 public totalAffiliateFeesAttoCash;
    IDisputeCrowdsourcer public preemptiveDisputeCrowdsourcer;

    // Collections
    IReportingParticipant[] public participants;
    IMap public crowdsourcers;
    IShareToken[] private shareTokens;
    mapping (address => uint256) public affiliateFeesAttoCash;

    function initialize(IAugur _augur, IUniverse _universe, uint256 _endTime, uint256 _feePerCashInAttoCash, uint256 _affiliateFeeDivisor, address _designatedReporterAddress, address _creator, uint256 _numOutcomes, uint256 _numTicks) public beforeInitialized {
        endInitialization();
        augur = _augur;
        require(msg.sender == augur.lookup("MarketFactory"));
        _numOutcomes += 1; // The INVALID outcome is always first
        universe = _universe;
        cash = ICash(augur.lookup("Cash"));
        owner = _creator;
        repBondOwner = owner;
        cash.approve(address(augur), MAX_APPROVAL_AMOUNT);
        assessFees();
        endTime = _endTime;
        numOutcomes = _numOutcomes;
        numTicks = _numTicks;
        feeDivisor = _feePerCashInAttoCash == 0 ? 0 : 1 ether / _feePerCashInAttoCash;
        affiliateFeeDivisor = _affiliateFeeDivisor;
        InitialReporterFactory _initialReporterFactory = InitialReporterFactory(augur.lookup("InitialReporterFactory"));
        participants.push(_initialReporterFactory.createInitialReporter(augur, _designatedReporterAddress));
        mapFactory = MapFactory(augur.lookup("MapFactory"));
        clearCrowdsourcers();
        for (uint256 _outcome = 0; _outcome < numOutcomes; _outcome++) {
            shareTokens.push(createShareToken(_outcome));
        }
        approveSpenders();
    }

    function assessFees() private {
        repBond = universe.getOrCacheMarketRepBond();
        require(getReputationToken().balanceOf(address(this)) >= repBond);
        validityBondAttoCash = cash.balanceOf(address(this));
        require(validityBondAttoCash >= universe.getOrCacheValidityBond());
        universe.deposit(address(this), validityBondAttoCash, address(this));
    }

    /**
     * @notice Increase the validity bond by sending more Cash to this contract
     * @param _attoCash the amount of Cash to send and increase the validity bond by
     * @return Bool True
     */
    function increaseValidityBond(uint256 _attoCash) public returns (bool) {
        require(!isFinalized());
        cash.transferFrom(msg.sender, address(this), _attoCash);
        universe.deposit(address(this), _attoCash, address(this));
        validityBondAttoCash = validityBondAttoCash.add(_attoCash);
        return true;
    }

    function createShareToken(uint256 _outcome) private returns (IShareToken) {
        return ShareTokenFactory(augur.lookup("ShareTokenFactory")).createShareToken(augur, _outcome);
    }

    function approveSpenders() public returns (bool) {
        bytes32[5] memory _names = [bytes32("CancelOrder"), bytes32("CompleteSets"), bytes32("FillOrder"), bytes32("ClaimTradingProceeds"), bytes32("Orders")];
        for (uint256 i = 0; i < _names.length; i++) {
            require(cash.approve(augur.lookup(_names[i]), MAX_APPROVAL_AMOUNT));
        }
        for (uint256 j = 0; j < numOutcomes; j++) {
            require(shareTokens[j].approve(augur.lookup("FillOrder"), MAX_APPROVAL_AMOUNT));
        }
        return true;
    }

    /**
     * @notice Do the initial report for the market.
     * @param _payoutNumerators An array indicating the payout for each market outcome
     * @param _description Any additional information or justification for this report
     * @param _additionalStake Additional optional REP to stake in anticipation of a dispute. This REP will be held in a bond that only activates if the report is disputed
     * @return Bool True
     */
    function doInitialReport(uint256[] memory _payoutNumerators, string memory _description, uint256 _additionalStake) public returns (bool) {
        doInitialReportInternal(msg.sender, _payoutNumerators, _description);
        if (_additionalStake > 0) {
            contributeToTentativeInternal(msg.sender, _payoutNumerators, _additionalStake, _description);
        }
        return true;
    }

    function doInitialReportInternal(address _reporter, uint256[] memory _payoutNumerators, string memory _description) private {
        require(!universe.isForking());
        IInitialReporter _initialReporter = getInitialReporter();
        uint256 _timestamp = augur.getTimestamp();
        require(_timestamp > endTime, "Market.doInitialReportInternal: Market has not reached Reporting phase");
        uint256 _initialReportStake = distributeInitialReportingRep(_reporter, _initialReporter);
        // The derive call will validate that an Invalid report is entirely paid out on the Invalid outcome
        bytes32 _payoutDistributionHash = derivePayoutDistributionHash(_payoutNumerators);
        disputeWindow = universe.getOrCreateNextDisputeWindow(true);
        _initialReporter.report(_reporter, _payoutDistributionHash, _payoutNumerators, _initialReportStake);
        augur.logInitialReportSubmitted(universe, _reporter, address(this), _initialReportStake, _initialReporter.designatedReporterShowed(), _payoutNumerators, _description, disputeWindow.getStartTime(), disputeWindow.getEndTime());
    }

    function distributeInitialReportingRep(address _reporter, IInitialReporter _initialReporter) private returns (uint256) {
        IV2ReputationToken _reputationToken = getReputationToken();
        uint256 _initialReportStake = repBond;
        repBond = 0;
        // If the designated reporter showed up and is not also the rep bond owner return the rep bond to the bond owner. Otherwise it will be used as stake in the first report.
        if (_reporter == _initialReporter.getDesignatedReporter() && _reporter != repBondOwner) {
            require(_reputationToken.noHooksTransfer(repBondOwner, _initialReportStake));
            _reputationToken.trustedMarketTransfer(_reporter, address(_initialReporter), _initialReportStake);
        } else {
            require(_reputationToken.noHooksTransfer(address(_initialReporter), _initialReportStake));
        }
        return _initialReportStake;
    }

    /**
     * @notice Contribute REP to the tentative winning outcome in anticipation of a dispute
     * @dev This will escrow REP in a bond which will be active immediately if the tentative outcome is successfully disputed.
     * @param _payoutNumerators An array indicating the payout for each market outcome
     * @param _amount The amount of REP to contribute
     * @param _description Any additional information or justification for this dispute
     * @return Bool True
     */
    function contributeToTentative(uint256[] memory _payoutNumerators, uint256 _amount, string memory _description) public returns (bool) {
        contributeToTentativeInternal(msg.sender, _payoutNumerators, _amount, _description);
        return true;
    }

    function contributeToTentativeInternal(address _sender, uint256[] memory _payoutNumerators, uint256 _amount, string memory _description) private {
        require(!disputePacingOn);
        // The derive call will validate that an Invalid report is entirely paid out on the Invalid outcome
        bytes32 _payoutDistributionHash = derivePayoutDistributionHash(_payoutNumerators);
        require(_payoutDistributionHash == getWinningReportingParticipant().getPayoutDistributionHash());
        internalContribute(_sender, _payoutDistributionHash, _payoutNumerators, _amount, true, _description);
    }

    /**
     * @notice Contribute REP to a payout other than the tenative winning outcome in order to dispute it
     * @param _payoutNumerators An array indicating the payout for each market outcome
     * @param _amount The amount of REP to contribute
     * @param _description Any additional information or justification for this dispute
     * @return Bool True
     */
    function contribute(uint256[] memory _payoutNumerators, uint256 _amount, string memory _description) public returns (bool) {
        // The derive call will validate that an Invalid report is entirely paid out on the Invalid outcome
        bytes32 _payoutDistributionHash = derivePayoutDistributionHash(_payoutNumerators);
        require(_payoutDistributionHash != getWinningReportingParticipant().getPayoutDistributionHash());
        internalContribute(msg.sender, _payoutDistributionHash, _payoutNumerators, _amount, false, _description);
        return true;
    }

    function internalContribute(address _contributor, bytes32 _payoutDistributionHash, uint256[] memory _payoutNumerators, uint256 _amount, bool _overload, string memory _description) internal {
        if (disputePacingOn) {
            require(disputeWindow.isActive());
        } else {
            require(!disputeWindow.isOver());
        }
        // This will require that the universe is not forking
        universe.updateForkValues();
        IDisputeCrowdsourcer _crowdsourcer = getOrCreateDisputeCrowdsourcer(_payoutDistributionHash, _payoutNumerators, _overload);
        uint256 _actualAmount = _crowdsourcer.contribute(_contributor, _amount, _overload);
        uint256 _amountRemainingToFill = _overload ? 0 : _crowdsourcer.getRemainingToFill();
        augur.logDisputeCrowdsourcerContribution(universe, _contributor, address(this), address(_crowdsourcer), _actualAmount, _description, _payoutNumerators, _crowdsourcer.getStake(), _amountRemainingToFill, getNumParticipants());
        if (!_overload) {
            if (_amountRemainingToFill == 0) {
                finishedCrowdsourcingDisputeBond(_crowdsourcer);
            } else {
                require(_amountRemainingToFill >= getInitialReporter().getSize(), "Market.internalContribute: Must totally fill bond or leave initial report amount");
            }
        }
    }

    function finishedCrowdsourcingDisputeBond(IDisputeCrowdsourcer _crowdsourcer) private {
        correctLastParticipantSize();
        participants.push(_crowdsourcer);
        clearCrowdsourcers(); // disavow other crowdsourcers
        uint256 _crowdsourcerSize = IDisputeCrowdsourcer(_crowdsourcer).getSize();
        if (_crowdsourcerSize >= universe.getDisputeThresholdForFork()) {
            universe.fork();
        } else {
            if (_crowdsourcerSize >= universe.getDisputeThresholdForDisputePacing()) {
                disputePacingOn = true;
            }
            disputeWindow = universe.getOrCreateNextDisputeWindow(false);
        }
        augur.logDisputeCrowdsourcerCompleted(
            universe,
            address(this),
            address(_crowdsourcer),
            _crowdsourcer.getPayoutNumerators(),
            disputeWindow.getStartTime(),
            disputeWindow.getEndTime(),
            disputePacingOn,
            getStakeInOutcome(_crowdsourcer.getPayoutDistributionHash()),
            getParticipantStake(),
            participants.length);
        if (preemptiveDisputeCrowdsourcer != IDisputeCrowdsourcer(0)) {
            IDisputeCrowdsourcer _newCrowdsourcer = preemptiveDisputeCrowdsourcer;
            preemptiveDisputeCrowdsourcer = IDisputeCrowdsourcer(0);
            bytes32 _payoutDistributionHash = _newCrowdsourcer.getPayoutDistributionHash();
            // The size of any dispute bond should be (2 * ALL STAKE) - (3 * STAKE IN OUTCOME)
            uint256 _correctSize = getParticipantStake().mul(2).sub(getStakeInOutcome(_payoutDistributionHash).mul(3));
            _newCrowdsourcer.setSize(_correctSize);
            if (_newCrowdsourcer.getStake() >= _correctSize) {
                finishedCrowdsourcingDisputeBond(_newCrowdsourcer);
            } else {
                crowdsourcers.add(_payoutDistributionHash, address(_newCrowdsourcer));
            }
        }
    }

    function correctLastParticipantSize() private {
        // A dispute has occured if there is more than one completed reporting participant
        if (participants.length > 1) {
            IDisputeCrowdsourcer(address(getWinningReportingParticipant())).correctSize();
        }
    }

    /**
     * @notice Finalize a market
     * @return Bool True
     */
    function finalize() public returns (bool) {
        require(!isFinalized());
        uint256[] memory _winningPayoutNumerators;
        if (isForkingMarket()) {
            IUniverse _winningUniverse = universe.getWinningChildUniverse();
            winningPayoutDistributionHash = _winningUniverse.getParentPayoutDistributionHash();
            _winningPayoutNumerators = _winningUniverse.getPayoutNumerators();
        } else {
            require(disputeWindow.isOver());
            require(!universe.isForking());
            IReportingParticipant _reportingParticipant = getWinningReportingParticipant();
            winningPayoutDistributionHash = _reportingParticipant.getPayoutDistributionHash();
            _winningPayoutNumerators = _reportingParticipant.getPayoutNumerators();
            // Make sure the dispute window for which we record finalization is the standard cadence window and not an initial dispute window
            disputeWindow = universe.getOrCreatePreviousDisputeWindow(false);
            disputeWindow.onMarketFinalized();
            universe.decrementOpenInterestFromMarket(this);
            redistributeLosingReputation();
        }
        finalizationTime = augur.getTimestamp();
        distributeValidityBondAndMarketCreatorFees();
        augur.logMarketFinalized(universe, _winningPayoutNumerators);
        return true;
    }

    function redistributeLosingReputation() private {
        // If no disputes occurred early exit
        if (participants.length == 1) {
            return;
        }

        IReportingParticipant _reportingParticipant;

        // Initial pass is to liquidate losers so we have sufficient REP to pay the winners. Participants is implicitly bounded by the floor of the initial report REP cost to be no more than 21
        for (uint256 i = 0; i < participants.length; i++) {
            _reportingParticipant = participants[i];
            if (_reportingParticipant.getPayoutDistributionHash() != winningPayoutDistributionHash) {
                _reportingParticipant.liquidateLosing();
            }
        }

        IV2ReputationToken _reputationToken = getReputationToken();
        // We burn 20% of the REP to prevent griefing attacks which rely on getting back lost REP
        _reputationToken.burnForMarket(_reputationToken.balanceOf(address(this)) / 5);

        // Now redistribute REP. Participants is implicitly bounded by the floor of the initial report REP cost to be no more than 21.
        for (uint256 j = 0; j < participants.length; j++) {
            _reportingParticipant = participants[j];
            if (_reportingParticipant.getPayoutDistributionHash() == winningPayoutDistributionHash) {
                // The last participant's owed REP will not actually be 40% ROI in the event it was created through pre-emptive contributions. We just give them all the remaining non burn REP
                uint256 amountToTransfer = j == participants.length - 1 ? _reputationToken.balanceOf(address(this)) : _reportingParticipant.getSize().mul(2) / 5;
                require(_reputationToken.noHooksTransfer(address(_reportingParticipant), amountToTransfer));
            }
        }
    }

    /**
     * @return The amount any settlement proceeds are divided by in order to calculate the market creator fee portion
     */
    function getMarketCreatorSettlementFeeDivisor() public view returns (uint256) {
        return feeDivisor;
    }

    /**
     * @param _amount The total settlement proceeds of a trade or claim
     * @return The amount of fees the market creator will receive
     */
    function deriveMarketCreatorFeeAmount(uint256 _amount) public view returns (uint256) {
        return feeDivisor == 0 ? 0 : _amount / feeDivisor;
    }

    function recordMarketCreatorFees(uint256 _marketCreatorFees, address _affiliateAddress) public returns (bool) {
        require(augur.isKnownFeeSender(msg.sender));
        if (_affiliateAddress != NULL_ADDRESS && affiliateFeeDivisor != 0) {
            uint256 _affiliateFees = _marketCreatorFees / affiliateFeeDivisor;
            affiliateFeesAttoCash[_affiliateAddress] += _affiliateFees;
            _marketCreatorFees = _marketCreatorFees.sub(_affiliateFees);
            totalAffiliateFeesAttoCash = totalAffiliateFeesAttoCash.add(_affiliateFees);
        }
        marketCreatorFeesAttoCash = marketCreatorFeesAttoCash.add(_marketCreatorFees);
        if (isFinalized()) {
            distributeMarketCreatorAndAffiliateFees(_affiliateAddress);
        }
    }

    function distributeValidityBondAndMarketCreatorFees() private {
        // If the market resolved to invalid the bond gets sent to the dispute window. Otherwise it gets returned to the market creator.
        marketCreatorFeesAttoCash = validityBondAttoCash.add(marketCreatorFeesAttoCash);
        distributeMarketCreatorAndAffiliateFees(NULL_ADDRESS);
    }

    function distributeMarketCreatorAndAffiliateFees(address _affiliateAddress) private {
        uint256 _marketCreatorFeesAttoCash = marketCreatorFeesAttoCash;
        marketCreatorFeesAttoCash = 0;
        if (!isInvalid()) {
            universe.withdraw(owner, _marketCreatorFeesAttoCash, address(this));
            if (_affiliateAddress != NULL_ADDRESS) {
                withdrawAffiliateFees(_affiliateAddress);
            }
        } else {
            universe.withdraw(address(universe.getOrCreateNextDisputeWindow(false)), _marketCreatorFeesAttoCash.add(totalAffiliateFeesAttoCash), address(this));
            totalAffiliateFeesAttoCash = 0;
        }
    }

    /**
     * @notice Redeems any owed affiliate fees for a particular address
     * @dev Will fail if the market is Invalid
     * @param _affiliate The address that is owed affiliate fees
     * @return Bool True
     */
    function withdrawAffiliateFees(address _affiliate) public returns (bool) {
        require(!isInvalid());
        uint256 _affiliateBalance = affiliateFeesAttoCash[_affiliate];
        if (_affiliateBalance == 0) {
            return true;
        }
        affiliateFeesAttoCash[_affiliate] = 0;
        universe.withdraw(_affiliate, _affiliateBalance, address(this));
        return true;
    }

    function getOrCreateDisputeCrowdsourcer(bytes32 _payoutDistributionHash, uint256[] memory _payoutNumerators, bool _overload) private returns (IDisputeCrowdsourcer) {
        IDisputeCrowdsourcer _crowdsourcer = _overload ? preemptiveDisputeCrowdsourcer : IDisputeCrowdsourcer(crowdsourcers.getAsAddressOrZero(_payoutDistributionHash));
        if (_crowdsourcer == IDisputeCrowdsourcer(0)) {
            IDisputeCrowdsourcerFactory _disputeCrowdsourcerFactory = IDisputeCrowdsourcerFactory(augur.lookup("DisputeCrowdsourcerFactory"));
            uint256 _participantStake = getParticipantStake();
            if (_overload) {
                // The stake of a dispute bond is (2 * ALL STAKE) - (3 * STAKE IN OUTCOME)
                _participantStake = _participantStake.add(_participantStake.mul(2).sub(getHighestNonTentativeParticipantStake().mul(3)));
            }
            uint256 _size = _participantStake.mul(2).sub(getStakeInOutcome(_payoutDistributionHash).mul(3));
            _crowdsourcer = _disputeCrowdsourcerFactory.createDisputeCrowdsourcer(augur, _size, _payoutDistributionHash, _payoutNumerators);
            if (!_overload) {
                crowdsourcers.add(_payoutDistributionHash, address(_crowdsourcer));
            } else {
                preemptiveDisputeCrowdsourcer = _crowdsourcer;
            }
            augur.disputeCrowdsourcerCreated(universe, address(this), address(_crowdsourcer), _payoutNumerators, _size, getNumParticipants());
        }
        return _crowdsourcer;
    }

    /**
     * @notice Migrates the market through a fork into the winning Universe
     * @dev This will extract a new REP no show bond from whoever calls this and if the market is in the reporting phase will require a report be made as well
     * @param _payoutNumerators An array indicating the payout for each market outcome
     * @param _description Any additional information or justification for this report
     * @return Bool True
     */
    function migrateThroughOneFork(uint256[] memory _payoutNumerators, string memory _description) public returns (bool) {
        // only proceed if the forking market is finalized
        IMarket _forkingMarket = universe.getForkingMarket();
        require(_forkingMarket.isFinalized());
        require(!isFinalized());

        disavowCrowdsourcers();

        bytes32 _winningForkPayoutDistributionHash = _forkingMarket.getWinningPayoutDistributionHash();
        IUniverse _destinationUniverse = universe.getChildUniverse(_winningForkPayoutDistributionHash);

        // follow the forking market to its universe
        if (disputeWindow != IDisputeWindow(0)) {
            // Markets go into the standard resolution period during fork migration even if they were in the initial dispute window. We want to give some time for REP to migrate.
            disputeWindow = _destinationUniverse.getOrCreateNextDisputeWindow(false);
        }
        universe.migrateMarketOut(_destinationUniverse);
        universe = _destinationUniverse;

        // Pay the REP bond.
        repBond = universe.getOrCacheMarketRepBond();
        repBondOwner = msg.sender;
        getReputationToken().trustedMarketTransfer(repBondOwner, address(this), repBond);

        // Update the Initial Reporter
        IInitialReporter _initialReporter = getInitialReporter();
        _initialReporter.migrateToNewUniverse(msg.sender);

        // If the market is past expiration use the reporting data to make an initial report
        uint256 _timestamp = augur.getTimestamp();
        if (_timestamp > endTime) {
            doInitialReportInternal(msg.sender, _payoutNumerators, _description);
        }

        return true;
    }

    function disavowCrowdsourcers() public returns (bool) {
        IMarket _forkingMarket = getForkingMarket();
        require(_forkingMarket != this);
        require(_forkingMarket != IMarket(NULL_ADDRESS));
        require(!isFinalized());
        IInitialReporter _initialParticipant = getInitialReporter();
        delete participants;
        participants.push(_initialParticipant);
        clearCrowdsourcers();
        // Send REP from the rep bond back to the address that placed it. If a report has been made tell the InitialReporter to return that REP and reset
        if (repBond > 0) {
            IV2ReputationToken _reputationToken = getReputationToken();
            uint256 _repBond = repBond;
            require(_reputationToken.noHooksTransfer(repBondOwner, _repBond));
            repBond = 0;
        } else {
            _initialParticipant.returnRepFromDisavow();
        }
        augur.logMarketParticipantsDisavowed(universe);
        return true;
    }

    function clearCrowdsourcers() private {
        crowdsourcers = mapFactory.createMap(augur, address(this));
    }

    function getHighestNonTentativeParticipantStake() public view returns (uint256) {
        if (participants.length < 2) {
            return 0;
        }
        bytes32 _payoutDistributionHash = participants[participants.length - 2].getPayoutDistributionHash();
        return getStakeInOutcome(_payoutDistributionHash);
    }

    /**
     * @notice Gets all REP stake in completed bonds for this market
     * @return uint256 indicating sum of all stake
     */
    function getParticipantStake() public view returns (uint256) {
        uint256 _sum;
        // Participants is implicitly bounded by the floor of the initial report REP cost to be no more than 21
        for (uint256 i = 0; i < participants.length; ++i) {
            _sum += participants[i].getStake();
        }
        return _sum;
    }

    /**
     * @param _payoutDistributionHash the payout distribution hash being checked
     * @return uint256 indicating the REP stake in a single outcome for a particular payout hash
     */
    function getStakeInOutcome(bytes32 _payoutDistributionHash) public view returns (uint256) {
        uint256 _sum;
        // Participants is implicitly bounded by the floor of the initial report REP cost to be no more than 21
        for (uint256 i = 0; i < participants.length; ++i) {
            IReportingParticipant _reportingParticipant = participants[i];
            if (_reportingParticipant.getPayoutDistributionHash() != _payoutDistributionHash) {
                continue;
            }
            _sum = _sum.add(_reportingParticipant.getStake());
        }
        return _sum;
    }

    /**
     * @return The forking market for the associated universe if one exists
     */
    function getForkingMarket() public view returns (IMarket) {
        return universe.getForkingMarket();
    }

    /**
     * @return The current bytes32 winning distribution hash if one exists
     */
    function getWinningPayoutDistributionHash() public view returns (bytes32) {
        return winningPayoutDistributionHash;
    }

    /**
     * @return Bool indicating if the market is finalized
     */
    function isFinalized() public view returns (bool) {
        return winningPayoutDistributionHash != bytes32(0);
    }

    /**
     * @return The designated reporter
     */
    function getDesignatedReporter() public view returns (address) {
        return getInitialReporter().getDesignatedReporter();
    }

    /**
     * @return Bool indicating if the designated reporter showed
     */
    function designatedReporterShowed() public view returns (bool) {
        return getInitialReporter().designatedReporterShowed();
    }

    /**
     * @return Bool indicating if the initial reporter was correct
     */
    function designatedReporterWasCorrect() public view returns (bool) {
        return getInitialReporter().designatedReporterWasCorrect();
    }

    /**
     * @return Time at which the event is considered ready to report on
     */
    function getEndTime() public view returns (uint256) {
        return endTime;
    }

    /**
     * @return Bool indicating if the market resolved as anything other than Invalid
     */
    function isInvalid() public view returns (bool) {
        require(isFinalized());
        if (isForkingMarket()) {
            return getWinningChildPayout(0) > 0;
        }
        return getWinningReportingParticipant().getPayoutNumerator(0) > 0;
    }

    /**
     * @return The Initial Reporter contract
     */
    function getInitialReporter() public view returns (IInitialReporter) {
        return IInitialReporter(address(participants[0]));
    }

    /**
     * @param _index The filled report or dispute at the given index
     * @return The Initial Reporter or a Dispute Crowdsourcer contract
     */
    function getReportingParticipant(uint256 _index) public view returns (IReportingParticipant) {
        return participants[_index];
    }

    /**
     * @param _payoutDistributionHash The payout distribution hash for a Dispute Crowdsourcer contract for this round of disputing
     * @return The associated Dispute Crowdsourcer contract for this round of disputing
     */
    function getCrowdsourcer(bytes32 _payoutDistributionHash) public view returns (IDisputeCrowdsourcer) {
        return  IDisputeCrowdsourcer(crowdsourcers.getAsAddressOrZero(_payoutDistributionHash));
    }

    /**
     * @return The associated Initial Reporter or a Dispute Crowdsourcer contract for the current tentative winning payout
     */
    function getWinningReportingParticipant() public view returns (IReportingParticipant) {
        return participants[participants.length-1];
    }

    /**
     * @param _outcome The outcome to get a payout for
     * @return The payout for a particular outcome for the tentative winning payout
     */
    function getWinningPayoutNumerator(uint256 _outcome) public view returns (uint256) {
        if (isForkingMarket()) {
            return getWinningChildPayout(_outcome);
        }
        return getWinningReportingParticipant().getPayoutNumerator(_outcome);
    }

    /**
     * @return The Universe associated with this Market
     */
    function getUniverse() public view returns (IUniverse) {
        return universe;
    }

    /**
     * @return The Dispute Window currently associated with this Market
     */
    function getDisputeWindow() public view returns (IDisputeWindow) {
        return disputeWindow;
    }

    /**
     * @return The time the Market was finalzied as a uint256 timestmap if the market was finalized
     */
    function getFinalizationTime() public view returns (uint256) {
        return finalizationTime;
    }

    /**
     * @return The REP token associated with this Market
     */
    function getReputationToken() public view returns (IV2ReputationToken) {
        return universe.getReputationToken();
    }

    /**
     * @return The number of outcomes (including invalid) this market has
     */
    function getNumberOfOutcomes() public view returns (uint256) {
        return numOutcomes;
    }

    /**
     * @return The number of ticks for this market. The number of ticks determines the possible on chain prices for Shares of the market. (e.g. A Market with 10 ticks can have prices 1-9 and a complete set will cost 10)
     */
    function getNumTicks() public view returns (uint256) {
        return numTicks;
    }

    /**
     * @param _outcome The outcome to get the associated Share Token for
     * @return The Share Token associated with the provided outcome
     */
    function getShareToken(uint256 _outcome) public view returns (IShareToken) {
        return shareTokens[_outcome];
    }

    /**
     * @return The uint256 timestamp for when the designated reporting period is over and anyone may report
     */
    function getDesignatedReportingEndTime() public view returns (uint256) {
        return endTime.add(Reporting.getDesignatedReportingDurationSeconds());
    }

    /**
     * @return The number of rounds of reporting + disputing that have occured
     */
    function getNumParticipants() public view returns (uint256) {
        return participants.length;
    }

    /**
     * @return The size of the validity bond
     */
    function getValidityBondAttoCash() public view returns (uint256) {
        return validityBondAttoCash;
    }

    /**
     * @return Bool indicating if slow dispute rounds have turned on
     */
    function getDisputePacingOn() public view returns (bool) {
        return disputePacingOn;
    }

    /**
     * @param _payoutNumerators array of payouts per outcome
     * @return Bytes32 has of the payout for use in other functions
     */
    function derivePayoutDistributionHash(uint256[] memory _payoutNumerators) public view returns (bytes32) {
        return augur.derivePayoutDistributionHash(_payoutNumerators, numTicks, numOutcomes);
    }

    function isContainerForShareToken(IShareToken _shadyShareToken) public view returns (bool) {
        return getShareToken(_shadyShareToken.getOutcome()) == _shadyShareToken;
    }

    function isContainerForReportingParticipant(IReportingParticipant _shadyReportingParticipant) public view returns (bool) {
        require(_shadyReportingParticipant != IReportingParticipant(0));
        if (address(preemptiveDisputeCrowdsourcer) == address(_shadyReportingParticipant)) {
            return true;
        }
        if (crowdsourcers.getAsAddressOrZero(_shadyReportingParticipant.getPayoutDistributionHash()) == address(_shadyReportingParticipant)) {
            return true;
        }
        // Participants is implicitly bounded by the floor of the initial report REP cost to be no more than 21
        for (uint256 i = 0; i < participants.length; i++) {
            if (_shadyReportingParticipant == participants[i]) {
                return true;
            }
        }
        return false;
    }

    function onTransferOwnership(address _owner, address _newOwner) internal {
        augur.logMarketTransferred(getUniverse(), _owner, _newOwner);
    }

    /**
     * @notice Transfers ownership of the REP no-show bond
     * @param _newOwner The new REP no show bond owner
     * @return Bool True
     */
    function transferRepBondOwnership(address _newOwner) public returns (bool) {
        require(msg.sender == repBondOwner);
        repBondOwner = _newOwner;
        return true;
    }

    function assertBalances() public view returns (bool) {
        universe.assertMarketBalance();
        return true;
    }

    function isForkingMarket() public view returns (bool) {
        return universe.isForkingMarket();
    }

    function getWinningChildPayout(uint256 _outcome) public view returns (uint256) {
        return universe.getWinningChildPayoutNumerator(_outcome);
    }
}
