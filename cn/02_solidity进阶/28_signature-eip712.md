# 第28节：signature-EIP712

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com



参考文章：

1. https://medium.com/coinmonks/eip712-a-full-stack-example-e12185b03d54
2. https://github.com/apurbapokharel/EIP712Example
3. 手册：https://docs.ethers.org/v5/api/signer/#Signer-signTypedData

这是官方示例代码：

```js
// All properties on a domain are optional
const domain = {
    name: 'Ether Mail',
    version: '1',
    chainId: 1,
    verifyingContract: '0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC'
};

// The named list of all type definitions
const types = {
    Person: [
        { name: 'name', type: 'string' },
        { name: 'wallet', type: 'address' }
    ],
    Mail: [
        { name: 'from', type: 'Person' },
        { name: 'to', type: 'Person' },
        { name: 'contents', type: 'string' }
    ]
};

// The data to sign
const value = {
    from: {
        name: 'Cow',
        wallet: '0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826'
    },
    to: {
        name: 'Bob',
        wallet: '0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB'
    },
    contents: 'Hello, Bob!'
};

signature = await signer._signTypedData(domain, types, value);
// '0x463b9c9971d1a144507d2e905f4e98becd159139421a4bb8d3c9c2ed04eb401057dd0698d504fd6ca48829a3c8a7a98c1c961eae617096cb54264bbdd082e13d1c'

```



合约：使用openzeppelin的标准包，构造函数的时候，需要传递参数构造：ERC721(name，version)，这两个值在后面的verify时会用到

```js
// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract TestEIP712 {
    // 其他...
    function verify(
        uint256 id,
        uint256 amt,
        address[] memory workers,
        bytes memory signature
    ) external view returns (bool) {
        bytes memory encoded = abi.encode(
            keccak256(
                'Message(uint256 id,uint256 amt,address[] workers)'
            ),
            id,
            amt,
            keccak256(abi.encodePacked(workers))
        );

        bytes32 structHash = keccak256(encoded);
      	// 里面会拼接\x19\x01、domainHash、自定义结构hash
        bytes32 digest = _hashTypedDataV4(structHash);
        return ECDSA.recover(digest, signature) == owner();
    }
}
```

testcase.ts

```js
import { verifyTypedData } from 'ethers/lib/utils'

const typedData = {
      // 这里的domain 不需要再写了，因为ethers会自动帮忙添加
      types: {
        // EIP712Domain: [
        //   { name: "name", type: "string" },
        //   { name: "version", type: "string" },
        //   { name: "chainId", type: "uint256" },
        //   { name: "verifyingContract", type: "address" }
        // ],
        Message: [
          { name: 'id', type: 'uint256' },
          { name: 'amt', type: 'uint256' },
          { name: 'workers', type: 'address[]' },
        ],
      },
      // 这个就是上面的Message
      primaryType: 'Message',
      // 这是EIP712Domain的值
      domain: {
        name: name,
        version: version,
        chainId: chainId,
        verifyingContract: contractAddress,
      },
      // 这是message的值
      message: {
        "id": id,
        "amt": amt,
        "workers": workers
      },
    };

    // 结构化签名
    const signature = await signer._signTypedData(
      typedData.domain,
      typedData.types,
      typedData.message,
    );

    // 使用ethersjs验证：
    let res = verifyTypedData(
      typedData.domain, typedData.types, typedData.message, signature,
    ).toLowerCase() === signerAddress.toLowerCase()

    console.log("etherjs验证签名有效性:", res);

    // 使用合约验证：
    await instance.verify(
    id, amt, workers, signature
)
```



后端处理签名，生成session逻辑：

使用签名信息与后台服务进行关联通常需要在客户端和服务器端之间建立一种安全的协议或机制，以确保签名信息的真实性和有效性。以下是一个可能的实现方案：

1. 客户端使用Metamask进行签名，并将签名结果发送到服务器端。
2. 服务器端验证签名信息的有效性，包括验证签名是否来自于正确的Metamask账户、签名是否正确、签名是否已过期等。
3. 如果签名信息有效，则服务器端将为该用户创建一个会话，并生成一个随机的token作为该会话的唯一标识符。
4. 服务器端将该token返回给客户端，并要求客户端在后续的请求中携带该token。
5. 客户端将该token存储在本地，例如使用LocalStorage或Cookie等方式。
6. 在后续的请求中，客户端将该token作为请求头或请求参数携带，并发送到服务器端。
7. 服务器端验证该token的有效性，并将与该token关联的用户信息作为请求处理的上下文。

通过这种方式，可以实现一个安全可靠的身份验证和会话管理机制，确保用户的身份信息和请求数据不会被篡改或伪造。同时，还可以在客户端和服务器端之间实现一些额外的安全措施，例如使用HTTPS协议、加密通信数据、限制请求频率等，以提高整个系统的安全性和可靠性。
