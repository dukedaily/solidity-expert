

# 第1节：AccessControl

当编写的合约多种权限控制的需求时，少量权限时，我们可以自己定义一个map，然后使用白名单方式；当涉及权限控制比较复杂时，建议直接使用标准库中的AccessControl模块，它主要支持：

1. 授权：grantRole
2. 取消权限：revokeRole
3. 权限查询：hasRole

其中，每一个Role都有自己的AdminRole，这个AdminRole可以对Role成员进行维护（增删），例如如下代码中，我们定义了一个权限 `BITVERSE_ADMIN_ROLE`

并对它设置了管理员权限：DEFAULT_ADMIN_ROLE。

```js
bytes32 private constant BITVERSE_ADMIN_ROLE = keccak256("BITVERSE_ADMIN");

constructor() {
  // 将 BITVERSE_ADMIN_ROLE 的管理员权限设置为：BITVERSE_ADMIN_ROLE
  // 这个是默认的，任何ROLE的默认ADMIN_ROLE都是DEFAULT_ADMIN_ROLE，即：0x00
  _setRoleAdmin(BITVERSE_ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
 
  // 给root地址添加DEFAULT_ADMIN_ROLE权限
  _setupRole(DEFAULT_ADMIN_ROLE, root);
}
```

AccessControl关系图：


<iframe style="border:none" width="800" height="450" src="https://whimsical.com/embed/BmYovG7CS3PmRvJ5zRTX9b"></iframe>

在上图含义为：

1. 右侧有一个BitVerseAdminRole`（黄颜色标注），成员在`members`中：acount1、account3，account2不在其中；
2. 这个`BitVerseAdminRole的adminRole`为`DEFAULT_ADMIN_ROLE`
3. `DEFAULT_ADMIN_ROLE`的member之一为root，即root可以管理`BitVerseAdminRole`下面的members，包括添加信member或者删除当前某个member



使用方式：

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MyToken is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC20("MyToken", "MTK") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
}
```

