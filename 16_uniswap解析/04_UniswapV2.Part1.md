![9df3ca81-f3e1-4130-b9c1-d5e0fd0ad0ba](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/9df3ca81-f3e1-4130-b9c1-d5e0fd0ad0ba.svg)



1. feeOn收取手续费是给官方的，这个之前一直是关着的

2. 0.3%的swap费用是一直存在的，这个用于奖励给LP持有者。（在periphery的Library中hard code）

   ```js
       function getAmountOut(
           uint256 amountIn,
           uint256 reserveIn,
           uint256 reserveOut
       ) internal pure returns (uint256 amountOut) {
           require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
           require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
           uint256 amountInWithFee = amountIn.mul(997);
           uint256 numerator = amountInWithFee.mul(reserveOut);
           uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
           amountOut = numerator / denominator;
       }
   ```

   
