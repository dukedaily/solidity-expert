# 第23节：安全事故13-encodePacked攻击

abi.encodePacked() 采用非填充序列化，当序列化参数包含多个变长数组时，攻击者可以在保持所有元素顺序不变的前提下，改变两个变长数组的元素，如此序列化的结果相同。

在下面的代码中：通过构造 addUser 的输入，攻击者可以将 regularUsers 的成员加入 admins 成员，但是构造的输入和原输入的签名相同。

```js
// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "./ECDSA.sol";

contract AccessControl {
    using ECDSA for bytes32;
    mapping(address => bool) isAdmin;
    mapping(address => bool) isRegularUser;
    
    // Add admins and regular users.
    function addUsers(
        address[] calldata admins,
        address[] calldata regularUsers,
        bytes calldata signature
    )
        external
    {
        if (!isAdmin[msg.sender]) {
            // Allow calls to be relayed with an admin's signature.
          	
            bytes32 hash = keccak256(abi.encodePacked(admins, regularUsers));
            address signer = hash.toEthSignedMessageHash().recover(signature);
            require(isAdmin[signer], "Only admins can add users.");
        }
        for (uint256 i = 0; i < admins.length; i++) {
            isAdmin[admins[i]] = true;
        }
        for (uint256 i = 0; i < regularUsers.length; i++) {
            isRegularUser[regularUsers[i]] = true;
        }
    }
}
```

解决方案：使用定长数组，或者不让调用者传入 abi.encodePacked() 的参数，或者使用 abi.encode()。
