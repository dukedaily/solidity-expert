https://moralis.io/



查看rinkeby网络，account：0xEf884C06F2aBf71040ff28976E3a85DDa8813ab2

1. 查看持有的erc20 token

```js
curl -X 'GET' \
  'https://deep-index.moralis.io/api/v2/0xEf884C06F2aBf71040ff28976E3a85DDa8813ab2/erc20?chain=rinkeby' \
  -H 'accept: application/json' \
  -H 'X-API-Key: ix9R1cyuOsdtAElOtcN0i0uMa7foYNoKpUOyNihzDjvMBDRUpiB98nfnsZJ8WQ1D'
```

2. 查看持有的nft token

```sh
curl -X 'GET' \
  'https://deep-index.moralis.io/api/v2/0xEf884C06F2aBf71040ff28976E3a85DDa8813ab2/nft?chain=rinkeby' \
  -H 'accept: application/json' \
  -H 'X-API-Key: ix9R1cyuOsdtAElOtcN0i0uMa7foYNoKpUOyNihzDjvMBDRUpiB98nfnsZJ8WQ1D'
```
