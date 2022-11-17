// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./core/ChainRunnersTypes.sol";
import "./interfaces/IChainRunnersRenderer.sol";

/*
               ::::                                                                                                                                                  :::#%=
               @*==+-                                                                                                                                               ++==*=.
               #+=#=++..                                                                                                                                        ..=*=*+-#:
                :=+++++++=====================================:    .===============================================. .=========================================++++++++=
                 .%-+%##+=--==================================+=..=+-=============================================-+*+======================================---+##+=#-.
                   -+++@@%++++@@@%+++++++++++++++++++++++++++%#++++++%#+++#@@@#+++++++++@@%++++++++++++++++++++@#+.=+*@*+*@@@@*+++++++++++++++++++++++%@@@#+++#@@+++=
                    -*-#%@@%%%=*%@%*++=++=+==+=++=++=+=++=++==#@%#%#+++=+=*@%*+=+==+=+++%*++==+=++=+==+=++=+=++@%%#%#++++*@%#++=++=++=++=+=++=++=+=+*%%*==*%@@@*:%=
                     :@:+@@@@@@*+++%@@*+===========+*=========#@@========+#%==========*@========##*#*+=======*@##*======#@#+=======*#*============+#%++#@@%#@@#++=.
                      .*+=%@%*%@%##++@@%#=-==-=--==*%=========*%==--=--=-====--=--=-=##=--=-=--%%%%%+=-=--=-=*%=--=--=-=#%=--=----=#%=--=-=--=-+%#+==#%@@*#%@=++.
                        +%.#@@###%@@@@@%*---------#@%########@%*---------------------##---------------------##---------%%*--------@@#---------+#@=#@@#+==@@%*++-
                        .:*+*%@#+=*%@@@*=-------=#%#=-------=%*---------=*#*--------#+=--------===--------=#%*-------=#%*-------==@%#--------=%@@%#*+=-+#%*+*:.
       ====================%*.@@%#==+##%@*=----------------+@#+---------@@*-------=*@+---------@@*--------=@+--------+@=--------*@@+-------+#@@%#==---+#@.*%====================
     :*=--==================-:=#@@%*===+*@%+=============%%%@=========*%@*========+@+=--=====+%@+==========@+========+@========*%@@+======%%%**+=---=%@#=:-====================-#-
       +++**%@@@#*****************@#*=---=##%@@@@@@@@@@@@@#**@@@@****************%@@*+++@#***********#@************************************+=------=*@#*********************@#+=+:
        .-##=*@@%*----------------+%@%=---===+%@@@@@@@*+++---%#++----------------=*@@*+++=-----------=+#=------------------------------------------+%+--------------------+#@-=@
         :%:#%#####+=-=-*@@+--=-==-=*@=--=-==-=*@@#*=-==-=-+@===-==-=-=++==-=-==--=@%===-==----+-==-==--+*+-==-==---=*@@@@@@%#===-=-=+%@%-==-=-==-#@%=-==-==--+#@@@@@@@@@@@@*+++
        =*=#@#=----==-=-=++=--=-==-=*@=--=-==-=*@@+-=-==-==+@===-=--=-*@@*=-=-==--+@=--=-==--+#@-==-==---+%-==-==---=+++#@@@#--==-=-=++++-=--=-===#%+=-==-==---=++++++++@@@%.#*
        +#:@%*===================++%#=========%@%=========#%=========+#@%+=======#%==========*@#=========*%=========+*+%@@@+========+*==========+@@%+**+================*%#*=+=
       *++#@*+=++++++*#%*+++++=+++*%%++++=++++%%*=+++++++##*=++++=++=%@@++++=++=+#%++++=++++#%@=+++++++=*#*+++++++=#%@@@@@*++=++++=#%@*+++=++=+++@#*****=+++++++=+++++*%@@+:=+=
    :=*=#%#@@@@#%@@@%#@@#++++++++++%%*+++++++++++++++++**@*+++++++++*%#++++++++=*##++++++++*%@%+++++++++##+++++++++#%%%%%%++++**#@@@@@**+++++++++++++++++=*%@@@%#@@@@#%@@@%#@++*:.
    #*:@#=-+%#+:=*@*=-+@%#++++++++#%@@#*++++++++++++++#%@#*++++++++*@@#+++++++++@#++++++++*@@#+++++++++##*+++++++++++++++++###@@@@++*@@#+++++++++++++++++++*@@#=:+#%+--+@*=-+%*.@=
    ++=#%#+%@@%=#%@%#+%%#++++++*#@@@%###**************@@@++++++++**#@##*********#*********#@@#++++++***@#******%@%#*++**#@@@%##+==+++=*#**********%%*++++++++#%#=%@@%+*%@%*+%#*=*-
     .-*+===========*@@+++++*%%%@@@++***************+.%%*++++#%%%@@%=:=******************--@@#+++*%%@#==+***--*@%*++*%@@*===+**=--   -************++@%%#++++++#@@@*==========*+-
        =*******##.#%#++++*%@@@%+==+=             *#-%@%**%%###*====**-               -@:*@@##@###*==+**-.-#=+@@#*@##*==+***=                     =+=##%@*+++++*%@@#.#%******:
               ++++%#+++*#@@@@+++==.              **-@@@%+++++++===-                 -+++#@@+++++++==:  :+++%@@+++++++==:                          .=++++@%##++++@@%++++
             :%:*%%****%@@%+==*-                .%==*====**+...                      #*.#+==***....    #+=#%+==****:.                                ..-*=*%@%#++*#%@=+%.
            -+++#%+#%@@@#++===                  .@*++===-                            #%++===           %#+++===                                          =+++%@%##**@@*.@:
          .%-=%@##@@%*==++                                                                                                                                 .*==+#@@%*%@%=*=.
         .+++#@@@@@*++==.                                                                                                                                    -==++#@@@@@@=+%
       .=*=%@@%%%#=*=.                                                                                                                                          .*+=%@@@@%+-#.
       @=-@@@%:++++.                                                                                                                                              -+++**@@#+*=:
    .-+=*#%%++*::.                                                                                                                                                  :+**=#%@#==#
    #*:@*+++=:                                                                                                                                                          =+++@*++=:
  :*-=*=++..                                                                                                                                                             .=*=#*.%=
 +#.=+++:                                                                                                                                                                   ++++:+#
*+=#-::                                                                                                                                                                      .::*+=*

*/

contract ChainRunners is ERC721Enumerable, Ownable, ReentrancyGuard {
    mapping(uint256 => ChainRunnersTypes.ChainRunner) runners;

    address public renderingContractAddress;

    event GenerateRunner(uint256 indexed tokenId, uint256 dna);
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _reservedTokenIds;

    uint256 private constant MAX_RUNNERS = 10000;
    uint256 private constant FOUNDERS_RESERVE_AMOUNT = 85;
    uint256 private constant MAX_PUBLIC_RUNNERS =
        MAX_RUNNERS - FOUNDERS_RESERVE_AMOUNT;
    uint256 private constant MINT_PRICE = 0.05 ether;
    uint256 private constant MAX_PER_ADDRESS = 10;

    uint256 private constant MAX_PER_EARLY_ACCESS_ADDRESS = 5;

    uint256 private runnerZeroHash;
    uint256 private runnerZeroDNA;

    uint256 public earlyAccessStartTimestamp;
    uint256 public publicSaleStartTimestamp;

    mapping(address => bool) public isOnEarlyAccessList;
    mapping(address => uint256) public earlyAccessMintedCounts;
    mapping(address => uint256) private founderMintCountsRemaining;

    constructor() ERC721("Chain Runners", "RUN") {}

    modifier whenPublicSaleActive() {
        require(isPublicSaleOpen(), "Public sale not open");
        _;
    }

    modifier whenEarlyAccessActive() {
        require(isEarlyAccessOpen(), "Early access not open");
        _;
    }

    function setRenderingContractAddress(address _renderingContractAddress)
        public
        onlyOwner
    {
        renderingContractAddress = _renderingContractAddress;
    }

    function mintPublicSale(uint256 _count)
        external
        payable
        nonReentrant
        whenPublicSaleActive
        returns (uint256, uint256)
    {
        require(
            _count > 0 && _count <= MAX_PER_ADDRESS,
            "Invalid Runner count"
        );
        require(
            _tokenIds.current() + _count <= MAX_PUBLIC_RUNNERS,
            "All Runners have been minted"
        );
        require(
            _count * MINT_PRICE == msg.value,
            "Incorrect amount of ether sent"
        );

        uint256 firstMintedId = _tokenIds.current() + 1;

        for (uint256 i = 0; i < _count; i++) {
            _tokenIds.increment();
            mint(_tokenIds.current());
        }

        return (firstMintedId, _count);
    }

    function mintEarlyAccess(uint256 _count)
        external
        payable
        nonReentrant
        whenEarlyAccessActive
        returns (uint256, uint256)
    {
        require(_count != 0, "Invalid Runner count");
        require(
            isOnEarlyAccessList[msg.sender],
            "Address not on Early Access list"
        );
        require(
            _tokenIds.current() + _count <= MAX_PUBLIC_RUNNERS,
            "All Runners have been minted"
        );
        require(
            _count * MINT_PRICE == msg.value,
            "Incorrect amount of ether sent"
        );

        uint256 userMintedAmount = earlyAccessMintedCounts[msg.sender] + _count;
        require(
            userMintedAmount <= MAX_PER_EARLY_ACCESS_ADDRESS,
            "Max Early Access count per address exceeded"
        );

        uint256 firstMintedId = _tokenIds.current() + 1;
        for (uint256 i = 0; i < _count; i++) {
            _tokenIds.increment();
            mint(_tokenIds.current());
        }
        earlyAccessMintedCounts[msg.sender] = userMintedAmount;
        return (firstMintedId, _count);
    }

    function allocateFounderMint(address _addr, uint256 _count)
        public
        onlyOwner
        nonReentrant
    {
        founderMintCountsRemaining[_addr] = _count;
    }

    function founderMint(uint256 _count)
        public
        nonReentrant
        returns (uint256, uint256)
    {
        require(
            _count > 0 && _count <= MAX_PER_ADDRESS,
            "Invalid Runner count"
        );
        require(
            _reservedTokenIds.current() + _count <= FOUNDERS_RESERVE_AMOUNT,
            "All reserved Runners have been minted"
        );
        require(
            founderMintCountsRemaining[msg.sender] >= _count,
            "You cannot mint this many reserved Runners"
        );

        uint256 firstMintedId = MAX_PUBLIC_RUNNERS + _tokenIds.current() + 1;
        for (uint256 i = 0; i < _count; i++) {
            _reservedTokenIds.increment();
            mint(MAX_PUBLIC_RUNNERS + _reservedTokenIds.current());
        }
        founderMintCountsRemaining[msg.sender] -= _count;
        return (firstMintedId, _count);
    }

    function mint(uint256 tokenId) internal {
        ChainRunnersTypes.ChainRunner memory runner;
        runner.dna = uint256(
            keccak256(
                abi.encodePacked(
                    tokenId,
                    msg.sender,
                    block.difficulty,
                    block.timestamp
                )
            )
        );

        _safeMint(msg.sender, tokenId);
        runners[tokenId] = runner;
    }

    function getRemainingEarlyAccessMints(address _addr)
        public
        view
        returns (uint256)
    {
        if (!isOnEarlyAccessList[_addr]) {
            return 0;
        }
        return MAX_PER_EARLY_ACCESS_ADDRESS - earlyAccessMintedCounts[_addr];
    }

    function getRemainingFounderMints(address _addr)
        public
        view
        returns (uint256)
    {
        return founderMintCountsRemaining[_addr];
    }

    function isPublicSaleOpen() public view returns (bool) {
        return
            block.timestamp >= publicSaleStartTimestamp &&
            publicSaleStartTimestamp != 0;
    }

    function isEarlyAccessOpen() public view returns (bool) {
        return
            !isPublicSaleOpen() &&
            block.timestamp >= earlyAccessStartTimestamp &&
            earlyAccessStartTimestamp != 0;
    }

    function addToEarlyAccessList(address[] memory toEarlyAccessList)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < toEarlyAccessList.length; i++) {
            isOnEarlyAccessList[toEarlyAccessList[i]] = true;
        }
    }

    function removeFromEarlyAccessList(address[] memory toRemove)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < toRemove.length; i++) {
            isOnEarlyAccessList[toRemove[i]] = false;
        }
    }

    function setPublicSaleTimestamp(uint256 timestamp) external onlyOwner {
        publicSaleStartTimestamp = timestamp;
    }

    function setEarlyAccessTimestamp(uint256 timestamp) external onlyOwner {
        earlyAccessStartTimestamp = timestamp;
    }

    function checkHash(string memory seed) public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(seed)));
    }

    function configureRunnerZero(
        uint256 _runnerZeroHash,
        uint256 _runnerZeroDNA
    ) external onlyOwner {
        require(runnerZeroHash == 0, "Runner Zero has already been configured");
        runnerZeroHash = _runnerZeroHash;
        runnerZeroDNA = _runnerZeroDNA;
    }

    function mintRunnerZero(string memory seed) external {
        require(runnerZeroHash != 0, "Runner Zero has not been configured");
        require(!_exists(0), "Runner Zero has already been minted");
        require(checkHash(seed) == runnerZeroHash, "Incorrect seed");

        ChainRunnersTypes.ChainRunner memory runner;
        runner.dna = runnerZeroDNA;

        _safeMint(msg.sender, 0);
        runners[0] = runner;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (renderingContractAddress == address(0)) {
            return "";
        }

        IChainRunnersRenderer renderer = IChainRunnersRenderer(
            renderingContractAddress
        );
        return renderer.tokenURI(_tokenId, runners[_tokenId]);
    }

    function tokenURIForSeed(uint256 _tokenId, uint256 seed)
        public
        view
        virtual
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (renderingContractAddress == address(0)) {
            return "";
        }

        ChainRunnersTypes.ChainRunner memory runner;
        runner.dna = seed;

        IChainRunnersRenderer renderer = IChainRunnersRenderer(
            renderingContractAddress
        );
        return renderer.tokenURI(_tokenId, runner);
    }

    function getDna(uint256 _tokenId) public view returns (uint256) {
        return runners[_tokenId].dna;
    }

    receive() external payable {}

    function withdraw() public onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }
}
