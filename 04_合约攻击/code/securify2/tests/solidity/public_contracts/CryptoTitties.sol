/**
 *Submitted for verification at Etherscan.io on 2019-11-07
*/

pragma solidity ^0.5.12;

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


/**
 * Utility library of inline functions on addresses
 */
library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids
 *
 * Include with `using Counter for Counter.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the SafeMath
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function set(Counter storage counter, uint256 value) internal returns (uint256) {
        counter._value = value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract IERC721Receiver {
    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a `safeTransfer`. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onERC721Received.selector`. This
     * function MAY throw to revert and reject the transfer.
     * Note: the ERC721 contract address is always the message sender.
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}

/**
 * @title CryptoTitties Implementation of ERC721
 * @dev ERC721, ERC721Meta plus custom market implementation.
 */
contract CryptoTitties {

    using SafeMath for uint;
    using Address for address;
    using Counters for Counters.Counter;

    // ----------------------------------------------------------------------------
    // Contract ownership
    // ----------------------------------------------------------------------------

    // - variables
    address public _ownershipOwner;
    address public _ownershipNewOwner;

    // - events
    event OwnershipTransferred(address indexed _from, address indexed _to);

    // - modifiers
    modifier onlyOwner {
        require(msg.sender == _ownershipOwner, "Only contract owner is allowed.");
        _;
    }

    // - functions


    /**
     * @notice Initialize contract ownership transfer
     * @dev This function can be called only by current contract owner,
     * to initialize ownership transfer to other address.
     * @param newOwner The address of desired new owner
     */
    function ownershipTransfer(address newOwner) public onlyOwner {
        _ownershipNewOwner = newOwner;
    }

    /**
     * @notice Finish contract ownership transfer
     * @dev This function can be called only by new contract owner,
     * to accept ownership transfer.
     */
    function ownershipAccept() public {
        require(msg.sender == _ownershipNewOwner, "Only new contract owner is allowed to accept.");
        emit OwnershipTransferred(_ownershipOwner, _ownershipNewOwner);
        _ownershipOwner = _ownershipNewOwner;
        _ownershipNewOwner = address(0);
    }



    // ----------------------------------------------------------------------------
    // ERC165
    // ----------------------------------------------------------------------------

    // - variables
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    mapping(bytes4 => bool) private _supportedInterfaces;

    // - functions
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    // ----------------------------------------------------------------------------
    // ERC721
    // based on https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol
    // ----------------------------------------------------------------------------

    // - variables

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from token ID to owner
    mapping (uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to number of owned token
    mapping (address => Counters.Counter) private _ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    /*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;


    // - events
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


	// - functions

    /**
     * @dev Gets the balance of the specified address.
     * @param owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0));
        return _ownedTokensCount[owner].current();
    }

    /**
     * @dev Gets the owner of the specified token ID.
     * @param tokenId uint256 ID of the token to query the owner of
     * @return address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "Token does not exists.");
        return _ownerOf(tokenId);
    }

    /**
     * @dev Approves another address to transfer the given token ID
     * The zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param to address to be approved for the given token ID
     * @param tokenId uint256 ID of the token to be approved
     */
    function approve(address to, uint256 tokenId) public {
        address owner = _ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Gets the approved address for a token ID, or zero if no address set
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf.
     * @param to operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    /**
     * @dev Tells whether an operator is approved by a given owner.
     * @param owner owner address which you want to query the approval of
     * @param operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address.
     * Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     * Requires the msg.sender to be the owner, approved, or operator.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId));
		require(!_marketOfferExists(tokenId), "Token is offered on market can't be transfered.");
        require(!_marketAuctionExists(tokenId), "Token is in auction can't be transfered.");

        _transferFrom(from, to, tokenId);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the _msgSender() to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

    // ----------------------------------------------------------------------------
    // ERC721 Meta
    // based on https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Metadata.sol
    // ----------------------------------------------------------------------------


    // - variables

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Base uri to generate tokenURI
    string private _baseTokenURI;

    //hash to prove token images not changes in time
    string private _imagesJsonHash;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;


    // - functions

    /**
     * @dev Gets the token name.
     * @return string representing the token name
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev Gets the token symbol.
     * @return string representing the token symbol
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns an URI for a given token ID.
     * Throws if the token ID does not exist.
     * @param tokenId uint256 ID of the token to query
     */
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId));
        return string(abi.encodePacked(_baseTokenURI, uint2str(tokenId)));
    }

    /**
     * @dev Returns saved hash.
     * Throws if the token ID does not exist.
     */
    function imagesJsonHash() external view returns (string memory){
    	return _imagesJsonHash;
    }

    // ----------------------------------------------------------------------------
    // ERC721 Meta Total suply
    // added totalSuply functionality
    // ----------------------------------------------------------------------------

    // - vars

    //total suply
    uint256 private _totalSupply;

    // - functions

    /**
     * @dev Returns totalSupply.
     */
    function totalSupply() public view returns (uint256 _supply) {
        return _totalSupply;
    }

    // ----------------------------------------------------------------------------
    // Build In Market
    // ----------------------------------------------------------------------------

    // - types

    /**
    * @title MarketOffer
    * @dev Stores information about token market offer.
    */
    struct MarketOffer {
        bool isOffer;
        address owner;
        uint256 price;
    }

    /**
    * @title MarketAuction
    * @dev Stores information about token market auction.
    */
    struct MarketAuction {
        bool isAuction;
        address highestBidder;
        uint256 highestBid;
        uint256 initPrice;
        uint endTime;
    }

    // - variables

    // Mapping from token ID to MarketOffer
    mapping (uint256 => MarketOffer) private _marketOffers;

    // Mapping from token ID to MarketAuction
    mapping (uint256 => MarketAuction) private _marketAuctions;

    // Mapping from address to marketBalance (ETH)
    mapping (address => uint256) private _marketBalances;

    //Mapping from token ID to First owner of token
    mapping (uint256 => address) private _tokenFirstOwner;

    //Address allowed to place tokens owned by contract to auction
    address private _auctionsAddress;

    //Address allowed to gift (transfer) tokens owned by contract
    address private _giftsAddress;

    // - events
    event MarketOfferCreated(address indexed _from, uint256 _tokenId, uint256 _price);
    event MarketOfferRemoved(address indexed _from, uint256 _tokenId);
    event MarketOfferSold(address indexed _owner, address indexed _buyer, uint256 _tokenId, uint256 _price);
    event MarketAuctionCreated(uint256 _tokenId, uint256 _initPrice, uint256 _starttime, uint256 _endtime);
    event MarketAuctionBid(uint256 _tokenId, uint256 _bid, address _bidder, address _old_bidder);
    event MarketAuctionClaimed(uint256 _tokenId, uint256 _bid, address _bidder);

    // - functions

    /**
     * @dev Sets new _auctionsAddress allowed to place tokens owned by
     * contract to auction.
     * Requires the msg.sender to be the contract owner
     * @param auctionsAddress new _auctionsAddress
     */
    function setAuctionAddress(address auctionsAddress) public onlyOwner {
        _auctionsAddress = auctionsAddress;
    }

    /**
     * @dev Sets new _giftsAddress allowed to place tokens owned by
     * contract to auction.
     * Requires the msg.sender to be the contract owner
     * @param giftsAddress new _giftsAddress
     */
    function setGiftsAddress(address giftsAddress) public onlyOwner {
        _giftsAddress = giftsAddress;
    }

    /**
     * @dev Gets token market price, returns 0 for tokens not on market.
     * Requires token existence
     * @param _tokenId uint256 ID of the token
     */
    function marketOfferGetTokenPrice(uint256 _tokenId) public view returns (uint256 _price) {
        require(_exists(_tokenId), "Token does not exists.");
        return _marketOfferGetTokenPrice(_tokenId);
    }

    /**
     * @dev Gets token market price, returns 0 for tokens not on market.
     * Internal implementation. For tokens owned by address(0), gets token
     * not from price _marketOffers[_tokenId], but from function
     * _countBasePrice(_tokenId)
     * @param _tokenId uint256 ID of the token
     */
    function _marketOfferGetTokenPrice(uint256 _tokenId) private view returns (uint256 _price) {
        if(_tokenOwner[_tokenId]==address(0)){
            return _countBasePrice(_tokenId);
        }
        return _marketOffers[_tokenId].price;
    }

    /**
     * @dev Returns whatever token is offered on market or not.
     * Requires token existence
     * @param _tokenId uint256 ID of the token
     */
    function marketOfferExists(uint256 _tokenId) public view returns (bool) {
        require(_exists(_tokenId), "Token does not exists.");

        return _marketOfferExists(_tokenId);
    }

    /**
     * @dev Returns whatever token is offered on market or not.
     * Internal implementation. For tokens owned by address(0), gets token
     * not from price _marketOffers[_tokenId], but from function
     * _baseIsOnMarket(_tokenId)
     * @param _tokenId uint256 ID of the token
     */
    function _marketOfferExists(uint256 _tokenId) private view returns (bool) {

        if(_tokenOwner[_tokenId]==address(0)){
            return _baseIsOnMarket(_tokenId);
        }

        return _marketOffers[_tokenId].isOffer;
    }

    /**
     * @dev Places token on internal market.
     * Requires token existence. Requires token not offered and not in auction.
     * Requires owner of token == msg.sender
     * @param _tokenId uint256 ID of the token
     * @param _price uint256 token price
     */
    function marketOfferCreate(uint256 _tokenId, uint256 _price) public {
        require(_exists(_tokenId), "Token does not exists.");
        require(!_marketOfferExists(_tokenId), "Token is allready offered.");
        require(!_marketAuctionExists(_tokenId), "Token is allready in auction.");

        address _owner = _ownerOf(_tokenId);

        require(_owner==msg.sender, "Sender is not authorized.");

        _marketOffers[_tokenId].isOffer = true;
        _marketOffers[_tokenId].owner = _owner;
        _marketOffers[_tokenId].price = _price;

        if(_tokenOwner[_tokenId]==address(0)){
        	_tokenOwner[_tokenId] = _owner;
        }

        emit MarketOfferCreated(_owner, _tokenId, _price);
    }

    /**
     * @dev Removes token from internal market.
     * Requires token existence. Requires token is offered .
     * Requires owner of token == msg.sender
     * @param _tokenId uint256 ID of the token
     */
    function marketOfferRemove(uint256 _tokenId) public {
        require(_exists(_tokenId), "Token does not exists.");

        address _owner = _ownerOf(_tokenId);

        require(_owner==msg.sender, "Sender is not authorized.");
        require(_marketOfferExists(_tokenId), "Token is not offered.");

        _marketOffers[_tokenId].isOffer = false;
        _marketOffers[_tokenId].owner = address(0);
        _marketOffers[_tokenId].price = 0;

        if(_tokenOwner[_tokenId]==address(0)){
        	_tokenOwner[_tokenId] = _owner;
        }

        //marketOffers[_tokenId] = MarketOffer(false, address(0),0);
        emit MarketOfferRemoved(_owner, _tokenId);
    }

    /**
     * @dev Buy token from internal market.
     * Requires token existence. Requires token is offered.
     * Requires owner of msg.value >= token price.
     * @param _tokenId uint256 ID of the token
     */
    function marketOfferBuy(uint256 _tokenId) public payable {
        require(_exists(_tokenId), "Token does not exists.");
        require(_marketOfferExists(_tokenId), "Token is not offered.");


        uint256 _price =  _marketOfferGetTokenPrice(_tokenId);
        uint256 _finalprice = _price;
        uint256 _payed = msg.value;
        address _buyer = msg.sender;
        address _owner = _ownerOf(_tokenId);
        uint256 fee_price = 0;
        uint256 charger_fee = 0;
        uint256 charity_fee = 0;
        uint256 charity_price = 0;

        require(_price<=_payed, "Payed price is lower than market price.");

        //return balance to buyer if send more than price
        if(_payed>_price){
            _marketBalances[_buyer] = _marketBalances[_buyer].add(_payed.sub(_price));
        }


        if((_tokenOwner[_tokenId]==address(0)) || (_tokenOwner[_tokenId]==_ownershipOwner)){
            // Primary market
            if(_isCharityToken(_tokenId)){
                //charity token

                //full price payed to _charityOwnerAddress
                charity_price = _price;

                //charity sets as first owner
                _tokenFirstOwner[_tokenId] = _charityOwnerAddress;
            }else{
                //contract token

                //10% to charity
                charity_fee = _price.div(10);

                //90% to charger
                charger_fee = _price.sub(charity_fee);
            }

        }else{
            //Secondary market

            //calculate 1 %
            fee_price = _price.div(100);

            //1% to charity - final price subtracted by 1%
            charity_fee = fee_price;
            _finalprice = _finalprice.sub(fee_price);

            //1% to first owner
            if(_tokenFirstOwner[_tokenId]!=address(0)){
                //added 1% to first owner
                _marketBalances[_tokenFirstOwner[_tokenId]] = _marketBalances[_tokenFirstOwner[_tokenId]].add(fee_price);

                //final price subtracted by 1%
                _finalprice = _finalprice.sub(fee_price);
            }

            //1% to charger - final price subtracted by 1%
            charger_fee = fee_price;
            _finalprice = _finalprice.sub(fee_price);

            //add final price to market balances of seller 97 or 98%
            _marketBalances[_owner] = _marketBalances[_owner].add(_finalprice);
        }

        //remove from market
        _marketOffers[_tokenId].isOffer = false;
        _marketOffers[_tokenId].owner = address(0);
        _marketOffers[_tokenId].price = 0;

        //actual token transfer
        _transferFrom(_owner, _buyer, _tokenId);

        //eth transfers to _chargerAddress, _charityAddress, and _charityOwnerAddress
        _charityAddBalance(charity_fee);
        _chargerAddBalance(charger_fee);
        _charityOwnerAddBalance(charity_price);

        //emit market sold event
        emit MarketOfferSold(_owner, _buyer, _tokenId, _price);
    }

    /**
     * @dev Places token on internal auction.
     * Requires token existence.
     * Requires token not offered and not in auction.
     * Requires owner of token == msg.sender or if contract token _auctionsAddress == msg.sender.
     * Requires _initPrice > 0.
     * @param _tokenId uint256 ID of the token
     * @param _initPrice uint256 initial (minimal bid) price
     * @param _duration uint256 auction duration in secconds
     */
    function marketAuctionCreate(uint256 _tokenId, uint256 _initPrice, uint _duration) public {
        require(_exists(_tokenId), "Token does not exists.");
        require(!_marketOfferExists(_tokenId), "Token is allready offered.");
        require(!_marketAuctionExists(_tokenId), "Token is allready in auction.");

        address _owner = _ownerOf(_tokenId);

        //requre msg.sender to be owner
        if(_owner!=msg.sender){
            //OR require owner == _ownershipOwner
            require(_owner==_ownershipOwner, "Sender is not authorized.");
            //AND msg.sender == _auctionsAddress
            require(_auctionsAddress==msg.sender, "Sender is not authorized.");
        }

        require(_initPrice>0, "Auction Init price has to be bigger than 0.");

        //set auction parameters
        _marketAuctions[_tokenId].isAuction = true;
        _marketAuctions[_tokenId].highestBidder = address(0);
        _marketAuctions[_tokenId].highestBid = 0;
        _marketAuctions[_tokenId].initPrice = _initPrice;
        _marketAuctions[_tokenId].endTime = block.timestamp+_duration;

        //emits MarketAuctionCreated
        emit MarketAuctionCreated(_tokenId, _initPrice, block.timestamp, block.timestamp+_duration);
    }

    /**
     * @dev Bids on token in internal auction.
     * Requires token existence.
     * Requires token in auction.
     * Requires bid >= _initPrice.
     * Requires bid > highestBid.
     * @param _tokenId uint256 ID of the token
     */
    function marketAuctionBid(uint256 _tokenId) public payable {
        require(_exists(_tokenId), "Token does not exists.");
        require(_marketAuctionExists(_tokenId), "Token is not in auction.");
        require(_marketAuctions[_tokenId].highestBid < msg.value, "Bid has to be bigger than the current highest bid.");
        require(_marketAuctions[_tokenId].initPrice <= msg.value, "Bid has to be at least initPrice value.");

        address oldBidder = _marketAuctions[_tokenId].highestBidder;
        address bidder = msg.sender;
        uint256 bidValue = msg.value;

        //return old bidder bid his to market balances
        if(oldBidder!=address(0)){
            _marketBalances[oldBidder] += _marketAuctions[_tokenId].highestBid;
        }

        //set new highest bid
        _marketAuctions[_tokenId].highestBidder = bidder;
        _marketAuctions[_tokenId].highestBid = bidValue;

        //emits MarketAuctionBid
        emit MarketAuctionBid(_tokenId, bidValue, bidder, oldBidder);
    }

    /**
     * @dev Resolved internal auction. Auction can not be resolved automatically after
     * duration expires. Transfer token to auction winner (if someone bids) and
     * remove token from auction.
     * Requires token existence.
     * Requires _marketAuctions[_tokenId].isAuction.
     * Requires _marketAuctions[_tokenId].endTime < block.timestamp - duration expired.
     * @param _tokenId uint256 ID of the token
     */
    function marketAuctionClaim(uint256 _tokenId) public {
        require(_exists(_tokenId), "Token does not exists.");
        require(_marketAuctions[_tokenId].isAuction, "Token is not in auction.");
        require(_marketAuctions[_tokenId].endTime < block.timestamp, "Auction not finished yet.");

        uint256 fee_price = 0;
        uint256 charger_fee = 0;
        uint256 charity_fee = 0;
        uint256 charity_price = 0;
        uint256 _price = _marketAuctions[_tokenId].highestBid;
        uint256 _finalprice = _price;
        address _buyer = _marketAuctions[_tokenId].highestBidder;
        address _owner = _ownerOf(_tokenId);

        // if winner exist (if someone bids)
        if(_buyer != address(0)){

            if(_tokenOwner[_tokenId]==address(0)){
                // Primary market
                if(_isCharityToken(_tokenId)){
                    //charity token

                    //full price payed to _charityOwnerAddress
                    charity_price = _price;

                    //charity sets as first owner
                    _tokenFirstOwner[_tokenId] = _charityOwnerAddress;
                }else{
                    //contract token

                    //10% to charity
                    charity_fee = _price.div(10);

                    //90% to charger
                    charger_fee = _price.sub(charity_fee);
                }
            }else{
                //Secondary market

                //calculate 1 %
                fee_price = _price.div(100);

                //1% to charity - final price subtracted by 1%
                charity_fee = fee_price;
                _finalprice = _finalprice.sub(fee_price);

                //1% to first owner
                if(_tokenFirstOwner[_tokenId]!=address(0)){
                    //added 1% to first owner
                    _marketBalances[_tokenFirstOwner[_tokenId]] = _marketBalances[_tokenFirstOwner[_tokenId]].add(fee_price);

                    //final price subtracted by 1%
                    _finalprice = _finalprice.sub(fee_price);
                }

                //1% to charger - final price subtracted by 1%
                charger_fee = fee_price;
                _finalprice = _finalprice.sub(fee_price);

                //add final price to market balances of seller 97 or 98%
                _marketBalances[_owner] = _marketBalances[_owner].add(_finalprice);
            }


            //actual transfer to winner
            _transferFrom(_owner, _buyer, _tokenId);

            //emit MarketAuctionClaimed
            emit MarketAuctionClaimed(_tokenId, _price, _buyer);
        }else{
            //emit MarketAuctionClaimed - when no bidder/winner
            emit MarketAuctionClaimed(_tokenId, 0, address(0));
        }

        //remove auction
        _marketAuctions[_tokenId].isAuction = false;
        _marketAuctions[_tokenId].highestBidder = address(0);
        _marketAuctions[_tokenId].highestBid = 0;

        //eth transfers to _chargerAddress, _charityAddress, and _charityOwnerAddress
        _charityAddBalance(charity_fee);
        _chargerAddBalance(charger_fee);
        _charityOwnerAddBalance(charity_price);
    }

    /**
     * @dev Gets current highest bid, returns 0 for tokens not in auction.
     * Requires token existence
     * @param _tokenId uint256 ID of the token
     */
    function marketAuctionGetTokenPrice(uint256 _tokenId) public view returns (uint256 _price) {
        require(_exists(_tokenId), "Token does not exists.");

        return _marketAuctions[_tokenId].highestBid;
    }

    /**
     * @dev Gets address of current highest bidder, returns addres(0) for tokens not in auction.
     * Requires token existence
     * @param _tokenId uint256 ID of the token
     */
    function marketAuctionGetHighestBidder(uint256 _tokenId) public view returns (address _bidder) {
        require(_exists(_tokenId), "Token does not exists.");

        return _marketAuctions[_tokenId].highestBidder;
    }

    /**
     * @dev Returns whatever token is in auction or not.
     * @param _tokenId uint256 ID of the token
     */
    function marketAuctionExists(uint256 _tokenId) public view returns(bool _exists){
        return _marketAuctionExists(_tokenId);
    }

    /**
     * @dev Returns whatever token is in auction or not.
     * Internal implementation. Check if endTime not expired.
     * @param _tokenId uint256 ID of the token
     */
    function _marketAuctionExists(uint256 _tokenId) private view returns(bool _exists){
        if(_marketAuctions[_tokenId].endTime < block.timestamp){
            return false;
        }
        return _marketAuctions[_tokenId].isAuction;
    }

    /**
     * @dev Transfers market balance of msg.sender.
     * Requires _marketBalances[msg.sender]>0
     */
    function marketWithdrawBalance() public {
        uint amount = _marketBalances[msg.sender];
        require(amount>0, "Sender has no market balance to withdraw.");

        _marketBalances[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    /**
     * @dev Get ammount of _owner.
     * @param _owner address Requested address;
     */
    function marketGetBalance(address _owner) public view returns(uint256 _balance){
        return _marketBalances[_owner];
    }

    /**
     * @dev Send/transfer token.
     * Requires token exist.
     * Requires token is not offered or in auction.
     * Requires token is owned by _ownershipOwner
     * Requires msq.sender==_giftsAddress
     * @param _tokenId uint256 ID of the token to send
     * @param _to address to send token
     */
    function marketSendGift(uint256 _tokenId, address _to) public {
        require(_exists(_tokenId), "Token does not exists.");
        require(!_marketOfferExists(_tokenId), "Token is offered.");
        require(!_marketAuctionExists(_tokenId), "Token is in auction.");

        require(_ownerOf(_tokenId)==_ownershipOwner, "Sender is not authorized.");
        require(_giftsAddress==msg.sender, "Sender is not authorized.");

        _transferFrom(_ownerOf(_tokenId), _to, _tokenId);
    }


    // --------------------------
    // Safe transfers functions (transefer to kown adresses)
    // -------------------------

    address payable private _chargeAddress;
    address payable private _charityAddress;
    address payable private _charityOwnerAddress;

    /**
     * @dev Transfers eth to _charityAddress
     * @param _balance uint256 Ammount to transfer
     */
    function _charityAddBalance(uint256 _balance) internal {
        if(_balance>0){
            _charityAddress.transfer(_balance);
        }
    }

    /**
     * @dev Transfers eth to _charityOwnerAddress
     * @param _balance uint256 Ammount to transfer
     */
    function _charityOwnerAddBalance(uint256 _balance) internal {
        if(_balance>0){
            _charityOwnerAddress.transfer(_balance);
        }
    }

    /**
     * @dev Transfers eth to _chargeAddress
     * @param _balance uint256 Ammount to transfer
     */
    function _chargerAddBalance(uint256 _balance) internal {
        if(_balance>0){
            _chargeAddress.transfer(_balance);
        }
    }


	// --------------------------
    // Internal functions
    // -------------------------

    /**
     * @dev Internal function return owner of token _tokenOwner[_tokenId].
     * if _tokenOwner[_tokenId] == address(0), owner is _charityOwnerAddress
     * OR _ownershipOwner (based on _isCharityToken(_tokenId))
     * @param _tokenId uint256 ID of the token
     */
    function _ownerOf(uint256 _tokenId) internal view returns (address _owner) {

        if(_tokenOwner[_tokenId]==address(0)){
            //token has no owner - owner is _charityOwnerAddress OR _ownershipOwner;
            if(_isCharityToken(_tokenId)){
                //owner is _charityOwnerAddress
                return _charityOwnerAddress;
            }
            //owner is _ownershipOwner
            return _ownershipOwner;
        }
        //owner is _tokenOwner[_tokenId]
        return _tokenOwner[_tokenId];
    }

    /**
     * @dev Returns whatever token is charity token or not
     * @param _tokenId uint256 ID of the token
     */
    function _isCharityToken(uint256 _tokenId) internal pure returns (bool _isCharity) {
        if(_tokenId>720 && _tokenId<=1320){
            return true;
        }
        return false;
    }

    /**
     * @dev Returns whether the specified token exists.
     * @param _tokenId uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 _tokenId) internal view returns(bool _tokenExistence) {
        //all tokens lower then supply exists
        return (_tokenId <= _totalSupply);
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID.
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = _ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(_ownerOf(tokenId) == from);
        require(to != address(0));

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

		if(_tokenFirstOwner[tokenId]==address(0)){
			_tokenFirstOwner[tokenId] = to;
		}
        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * This function is deprecated.
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    /**
     * @dev Private function to clear current approval of a given token ID.
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }

    /**
     * @dev Converts uint256 number to string
     * @param i uint256
     */
    function uint2str(uint256 i) internal pure returns (string memory){
        uint256 _tmpN = i;

        if (_tmpN == 0) {
            return "0";
        }

        uint256 j = _tmpN;
        uint256 length = 0;

        while (j != 0){
            length++;
            j /= 10;
        }

        bytes memory bstr = new bytes(length);
        uint256 k = length - 1;

        while (_tmpN != 0) {
            bstr[k--] = byte(uint8(48 + _tmpN % 10));
            _tmpN /= 10;
        }

        return string(bstr);
    }

    /**
     * @dev Returns market price of token based on its id.
     * Only used if tokenOwner == address(0)
     * @param _tokenId uint256 id of token
     * @return uint256 marketPrice
     */
    function _countBasePrice(uint256 _tokenId) internal pure returns (uint256 _price) {

        if(_tokenId<=720){
            //reserved for gifts and auctions
            return 0;
        }
        if(_tokenId>720 && _tokenId<=1320){
            //charity owned on market
            return 100 * (uint256(10) ** 15);
        }

        if(_tokenId>1320 && _tokenId<=8020){
            // price 5
            return 34 * (uint256(10) ** 15);
        }

        if(_tokenId>=8021 && _tokenId<10920){
            // price 6
            return 40 * (uint256(10) ** 15);
        }

        if(_tokenId>=10920 && _tokenId<17720){
            // price 7
            return 47 * (uint256(10) ** 15);
        }

        if(_tokenId>=17720 && _tokenId<22920){
            // price 8
            return 54* (uint256(10) ** 15);
        }

        if(_tokenId>=22920 && _tokenId<29470){
            // price 10
            return 67 * (uint256(10) ** 15);
        }

        if(_tokenId>=29470 && _tokenId<30320){
            // price 11
            return 74 * (uint256(10) ** 15);
        }

        if(_tokenId>=30320 && _tokenId<32470){
            // price 12
            return 80 * (uint256(10) ** 15);
        }

        if(_tokenId>=32470 && _tokenId<35120){
            // price 13
            return 87 * (uint256(10) ** 15);
        }

        if(_tokenId>=35120 && _tokenId<35520){
            // price 14
            return 94 * (uint256(10) ** 15);
        }

        if(_tokenId>=35520 && _tokenId<42370){
            // price 15
            return 100 * (uint256(10) ** 15);
        }

        if(_tokenId>=42370 && _tokenId<46370){
            // price 18
            return 120 * (uint256(10) ** 15);
        }

        if(_tokenId>=46370 && _tokenId<55920){
            // price 20
            return 134 * (uint256(10) ** 15);
        }

        if(_tokenId>=55920 && _tokenId<59820){
            // price 22
            return 147 * (uint256(10) ** 15);
        }

        if(_tokenId>=59820 && _tokenId<63120){
            // price 25
            return 167 * (uint256(10) ** 15);
        }

        if(_tokenId>=63120 && _tokenId<78870){
            // price 30
            return 200 * (uint256(10) ** 15);
        }

        if(_tokenId>=78870 && _tokenId<79010){
            // price 35
            return 234 * (uint256(10) ** 15);
        }

        if(_tokenId>=79010 && _tokenId<84505){
            // price 40
            return 267 * (uint256(10) ** 15);
        }

        if(_tokenId>=84505 && _tokenId<84645){
            // price 45
            return 300 * (uint256(10) ** 15);
        }

        if(_tokenId>=84645 && _tokenId<85100){
            // price 50
            return 334 * (uint256(10) ** 15);
        }

        if(_tokenId>=85100 && _tokenId<85165){
            // price 60
            return 400 * (uint256(10) ** 15);
        }

        if(_tokenId>=85165 && _tokenId<85175){
            // price 65
            return 434 * (uint256(10) ** 15);
        }

        if(_tokenId>=85175 && _tokenId<85205){
            // price 70
            return 467 * (uint256(10) ** 15);
        }

        if(_tokenId>=85205 && _tokenId<85235){
            // price 80
            return 534 * (uint256(10) ** 15);
        }

        if(_tokenId>=85235 && _tokenId<85319){
            // price 90
            return 600 * (uint256(10) ** 15);
        }

        if(_tokenId>=85319 && _tokenId<85427){
            // price 100
            return 667 * (uint256(10) ** 15);
        }

        if(_tokenId>=85427 && _tokenId<85441){
            // price 110
            return 734 * (uint256(10) ** 15);
        }

        if(_tokenId>=85441 && _tokenId<85457){
            // price 120
            return 800 * (uint256(10) ** 15);
        }

        if(_tokenId>=85457 && _tokenId<85464){
            // price 130
            return 867 * (uint256(10) ** 15);
        }

        if(_tokenId>=85464 && _tokenId<85465){
            // price 140
            return 934 * (uint256(10) ** 15);
        }

        if(_tokenId>=85465 && _tokenId<85502){
            // price 150
            return 1000 * (uint256(10) ** 15);
        }

        if(_tokenId>=85502 && _tokenId<85506){
            // price 160
            return 1067 * (uint256(10) ** 15);
        }

        if(_tokenId==85506){
            // price 170
            return 1134 * (uint256(10) ** 15);
        }

        if(_tokenId==85507){
            // price 180
            return 1200 * (uint256(10) ** 15);
        }

        if(_tokenId>=85508 && _tokenId<85516){
            // price 200
            return 1334 * (uint256(10) ** 15);
        }

        if(_tokenId>=85516 && _tokenId<85518){
            // price 230
            return 1534 * (uint256(10) ** 15);
        }

        if(_tokenId>=85518 && _tokenId<85571){
            // price 250
            return 1667 * (uint256(10) ** 15);
        }

        if(_tokenId>=85571 && _tokenId<85587){
            // price 300
            return 2000 * (uint256(10) ** 15);
        }

        if(_tokenId>=85587 && _tokenId<85594){
            // price 350
            return 2334 * (uint256(10) ** 15);
        }

        if(_tokenId>=85594 && _tokenId<85597){
            // price 400
            return 2667 * (uint256(10) ** 15);
        }

        if(_tokenId>=85597 && _tokenId<85687){
            // price 500
            return 3334 * (uint256(10) ** 15);
        }

        if(_tokenId==85687){
            // price 550
            return 3667 * (uint256(10) ** 15);
        }

        if(_tokenId>=85688 && _tokenId<85692){
            // price 600
            return 4000 * (uint256(10) ** 15);
        }

        if(_tokenId==85692){
            // price 680
            return 4534 * (uint256(10) ** 15);
        }

        if(_tokenId>=85693 && _tokenId<85698){
            // price 700
            return 4667 * (uint256(10) ** 15);
        }

        if(_tokenId>=85698 && _tokenId<85700){
            // price 750
            return 5000 * (uint256(10) ** 15);
        }

        if(_tokenId==85700){
            // price 800
            return 5334 * (uint256(10) ** 15);
        }

        if(_tokenId==85701){
            // price 900
            return 6000 * (uint256(10) ** 15);
        }

        if(_tokenId>=85702 && _tokenId<85776){
            // price 1000
            return 6667 * (uint256(10) ** 15);
        }

        if(_tokenId==85776){
            // price 1100
            return 7334 * (uint256(10) ** 15);
        }

        if(_tokenId>=85777 && _tokenId<85788){
            // price 1500
            return 10000 * (uint256(10) ** 15);
        }

        if(_tokenId>=85788 && _tokenId<85795){
            // price 2000
            return 13334 * (uint256(10) ** 15);
        }

        if(_tokenId>=85795 && _tokenId<85798){
            // price 2500
            return 16667 * (uint256(10) ** 15);
        }

        if(_tokenId>=85798 && _tokenId<85803){
            // price 3000
            return 20000 * (uint256(10) ** 15);
        }

        if(_tokenId>=85803 && _tokenId<85806){
            // price 5000
            return 33334 * (uint256(10) ** 15);
        }

        if(_tokenId>=85806 && _tokenId<85807){
            // price 10000
            return 66667 * (uint256(10) ** 15);
        }

        if(_tokenId==85807){
            // price 50000
            return 333334 * (uint256(10) ** 15);
        }
    }

    /**
     * @dev Returns whatever token is offerd on market.
     * Only used if tokenOwner == address(0)
     * @param _tokenId uint256 id of token
     */
    function _baseIsOnMarket(uint256 _tokenId) internal pure returns (bool _isOnMarket) {
        if(_tokenId<=720){
            //reserved for gits and auctions
            return false;
        }
        if(_tokenId>720 && _tokenId<=1320){
            //charity owned on market
            return true;
        }

        if(_tokenId>1320){
            //other on market
            return true;
        }
    }

    /**
     * @dev Constructor
     */
    constructor () public {
        // register the supported interfaces to conform to ERC721 via ERC165
    	_registerInterface(_INTERFACE_ID_ERC165);
        _registerInterface(_INTERFACE_ID_ERC721);

        //set metadata values
        _name = "Crypto Tittiez";
        _symbol = "CTT";

        // register the supported interfaces to conform to ERC721 ERC721_METADATA
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);

        //set metadata values
        _baseTokenURI = "https://cryptotittiez.com/api/tokeninfo/";
        _totalSupply = 85807;

        //after tokens creation (allmost) all tokens pretends are owned by _ownershipOwner. Look at function _ownerOf
        _ownedTokensCount[msg.sender].set(85207);

        //sets known addresse
        _chargeAddress = address(0x03559A5AFC7F55F3d71619523d45889a6b0905c0);
        _charityAddress = address(0x40497Be989B8d6fb532a6A2f0Dbf759F5d644e76);
        _charityOwnerAddress = address(0x949577b216ee2D44d70d6DB210422275694cbA27);
        _auctionsAddress = address(0x6800B4f9A80a1fbA4674a5716A5554f3869b57Bf);
        _giftsAddress = address(0x3990e05DA96EFfF38b0aC9ddD495F41BB82Bf9a9);

        //after tokens creation 600 tokens pretends are owned by _charityOwnerAddress. Look at function _ownerOf
        _ownedTokensCount[_charityOwnerAddress].set(600);

        //sets json hash to prove images not change
        _imagesJsonHash = "2485dabaebe62276c976e55b290438799f2b60cdb845c50053e2c2be43fa6fce";

        //set contract owner
        _ownershipOwner = msg.sender;
    }
}