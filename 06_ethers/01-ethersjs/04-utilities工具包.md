

## 数字转换解析

1. ethers.utils.formatUnits()

   ```js
   const oneGwei = BigNumber.from("1000000000");
   formatUnits(oneGwei, "gwei");
   '1.0'
   
   
   formatEther是特殊函数，相当于：formatUnits(value, "ether")
   formatEther(value);
   // '1.0'
   ```

2. ethers.utils.parseUnits()

   ```js
   parseUnits("1.0", "ether");
   { BigNumber: "1000000000000000000" }
   
   
   parseEther是特殊函数，相当于：parseUnits(value, "ether")
   parseEther("1.0");
   // { BigNumber: "1000000000000000000" }
   ```