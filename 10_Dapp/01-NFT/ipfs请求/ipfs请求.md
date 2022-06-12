1. 原始地址：  ipfs://QmPMc4tcBsMqLRuCQtPmPe84bpSjrC3Ky7t3JWuHXYB4aS/100

2. 拼接成前缀：https://ipfs.io/ipfs/，得到：https://ipfs.io/ipfs/QmPMc4tcBsMqLRuCQtPmPe84bpSjrC3Ky7t3JWuHXYB4aS/100

3. 请求后得到描述文件：

   ```js
   {"image":"ipfs:\/\/QmNho7DQ8xPn3jDwevM5M3VjfDP3fe5gWV6xCfkA55RR93","name":"Doodle #100","description":"A community-driven collectibles project featuring art by Burnt Toast. Doodles come in a joyful range of colors, traits and sizes with a collection size of 10,000. Each Doodle allows its owner to vote for experiences and activations paid for by the Doodles Community Treasury. Burnt Toast is the working alias for Scott Martin, a Canadian\u2013based illustrator, designer, animator and muralist.","attributes":[{"trait_type":"face","value":"designer glasses"},{"trait_type":"hair","value":"blue brushcut"},{"trait_type":"body","value":"blue backpack"},{"trait_type":"background","value":"pink"},{"trait_type":"head","value":"orange"}]}
   ```


4. 得到image的url，再次拼接前缀，得到：https://ipfs.io/ipfs/QmNho7DQ8xPn3jDwevM5M3VjfDP3fe5gWV6xCfkA55RR93

5. 发起请求：得到图片

![image-20211019100551520](assets/image-20211019100551520.png)