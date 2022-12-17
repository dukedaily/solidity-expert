# 第28节：signature-EIP712

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

    // 调用verify：
    await instance.verify(
    id, amt, workers, signature
)
```

