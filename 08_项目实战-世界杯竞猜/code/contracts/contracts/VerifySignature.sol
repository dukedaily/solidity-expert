// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract VerifySignature {
    // 1. 对真正的内容进行哈希处理，私钥最终只对这个进行签名
    function getMessageHash(address _to, uint256 _amount)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_to, _amount));
    }

    // 2. 对内容的哈希进行二次哈希，这个用于做verify处理
    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                //这是标准字符串: \x19Ethereum Signed Message:\n
                //32表示后面的哈希内容长度
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    // 3. 传入基础数据和签名，内部会计算出哈希值，并使用签名进行校验。
    // 这个是最核心的方法，最终外部仅调用这个
    function verify(
        bytes32 _msgHash,
        bytes memory _signature,
        address _signer
    ) public pure returns (bool) {
        return recoverSigner(_msgHash, _signature) == _signer;
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
