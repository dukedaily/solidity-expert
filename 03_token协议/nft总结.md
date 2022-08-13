# NFT721

goerli成功：

1. https://goerli.etherscan.io/address/0x6338cbc71de0628c91f69ddf57a07edf5afab59a#code

2. morils的api查看，可以返回正确返回id = 1的数据

   ```sh
   curl -X 'GET' \
     'https://deep-index.moralis.io/api/v2/0x6491D615b6DB93154d6123e97751897CCe524787/nft?chain=goerli' \
     -H 'accept: application/json' \
     -H 'X-API-Key: ix9R1cyuOsdtAElOtcN0i0uMa7foYNoKpUOyNihzDjvMBDRUpiB98nfnsZJ8WQ1D' > goerli.json
   ```

3. 代码中，有baseURL，创建时只需要输入json文件的hash值即可

4. 但是opensea中依然无法正确展示
