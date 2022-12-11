/**
[TestInfo]
pattern: IncorrectERC721InterfacePattern

 */
pragma solidity ^0.5.0;

contract ContractNotApplicable {
    function transfer(uint value) external {}
}

contract TokenCompliant {// compliant
    function balanceOf(address _owner) external view returns (uint256) {return 0;}

    function ownerOf(uint256 _tokenId) external view returns (address) {return address(0);}

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable {}

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {}

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {}

    function approve(address _approved, uint256 _tokenId) external payable {}

    function setApprovalForAll(address _operator, bool _approved) external {}

    function getApproved(uint256 _tokenId) external view returns (address) {return address(0);}

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {return true;}
}

contract TokenViolation {// violation
    function balanceOf(address _owner) external view returns (uint256) {return 0;}

    function ownerOf(uint256 _tokenId) external view {} // incorrect return signature

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable {}

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {}

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {}

    function approve(address _approved, uint256 _tokenId) external payable {}

    function setApprovalForAll(address _operator, bool _approved) external {}

    function getApproved(uint256 _tokenId) external view returns (address) {return address(0);}

    function isApprovedForAll(address _owner, address _operator) external view {} // incorrect return signature
}