from securify.analyses.patterns.abstract_pattern import Severity
from securify.analyses.patterns.ir.base_interface_signatures_pattern import InterfaceSignaturesBasePattern


class IncorrectERC721InterfacePattern(InterfaceSignaturesBasePattern):
    name = "Incorrect ERC721 Interface"

    description = "Incorrect signature for ERC721 interface functions."

    severity = Severity.MEDIUM
    tags = {}

    interface_signatures = InterfaceSignaturesBasePattern.parse_signatures(
        """
        function balanceOf(address _owner) external view returns (uint256);
        function ownerOf(uint256 _tokenId) external view returns (address);
        function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;
        function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
        function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
        function approve(address _approved, uint256 _tokenId) external payable;
        function setApprovalForAll(address _operator, bool _approved) external;
        function getApproved(uint256 _tokenId) external view returns (address);
        function isApprovedForAll(address _owner, address _operator) external view returns (bool);
        """
    )
