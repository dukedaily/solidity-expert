

1. 解决多版本编译：

   如果指定多个版本，当合约中未指定明确版本时，hardhat会默认使用最高的版本编译，此时会出现问题；解决办法是对特定的文件明确编译器版本号，即下文中的overrides部分：

   ```js
   solidity: {
           overrides: {
               '@uniswap/v3-core/contracts/libraries/FullMath.sol': {
                   version: '0.7.6'
               },
               '@uniswap/v3-core/contracts/libraries/TickMath.sol': {
                   version: '0.7.6'
               }
           },
           compilers: [
               {
                   version: '0.8.10',
                   settings: {
                       optimizer: {
                           enabled: true,
                           runs: 200
                       }
                   }
               },
               {
                   version: '0.6.12'
               }
           ]
       },
   ```

   