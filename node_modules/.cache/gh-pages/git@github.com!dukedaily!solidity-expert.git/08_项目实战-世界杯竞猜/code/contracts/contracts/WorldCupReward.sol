// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./utils/Reentrant.sol";
import "./utils/Ownable.sol";
import "./libraries/TransferHelper.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract WorldCupReward is Reentrant, Ownable {
    using ECDSA for bytes32;

    event SetEmergency(bool emergency);
    event SetSigner(address signer, bool state);
    event Claim(address indexed user, uint8 useFor, uint256 amount, bytes nonce);

    address public banana;
    bool public emergency;
    mapping(address => bool) public signers;
    mapping(bytes => bool) public usedNonce;

    constructor(address banana_) {
        owner = msg.sender;
        banana = banana_;
    }

    function setSigner(address signer, bool state) external onlyOwner {
        signers[signer] = state;
        emit SetSigner(signer, state);
    }

    function setEmergency(bool emergency_) external onlyOwner {
        emergency = emergency_;
        emit SetEmergency(emergency_);
    }

    function emergencyWithdraw(address to, uint256 amount) external onlyOwner {
        require(emergency, "NOT_EMERGENCY");
        TransferHelper.safeTransfer(banana, to, amount);
    }

    function claim(
        address user,
        uint8 useFor,
        uint256 amount,
        uint256 expireAt,
        bytes calldata nonce,
        bytes memory signature
    ) external nonReentrant {
        require(!emergency, "EMERGENCY");
        verify(user, useFor, amount, expireAt, nonce, signature);
        usedNonce[nonce] = true;
        TransferHelper.safeTransfer(banana, user, amount);
        emit Claim(user, useFor, amount, nonce);
    }

    function verify(
        address user,
        uint8 useFor,
        uint256 amount,
        uint256 expireAt,
        bytes calldata nonce,
        bytes memory signature
    ) public view returns (bool) {
        address recover = keccak256(abi.encode(user, useFor, amount, expireAt, nonce, address(this)))
            .toEthSignedMessageHash()
            .recover(signature);
        require(signers[recover], "NOT_SIGNER");
        require(!usedNonce[nonce], "NONCE_USED");
        require(expireAt > block.timestamp, "EXPIRED");
        return true;
    }
}
