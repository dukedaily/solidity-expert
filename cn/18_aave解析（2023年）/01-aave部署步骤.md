# 基础准备

获取ETH水龙头

```sh
https://faucet.paradigm.xyz/
```

alchemy

```sh
https://eth-kovan.alchemyapi.io/v2/-qZ8NcwdvM8gsbxWyFl_Iw9znBN5UV3t
```

# 一、合约

完整部署：

```sh
npm run aave:kovan:full:migration:add-registry
```

超时了可以注释：aave.mainnet.ts里面的tasks

也可以从中间环节开始运行，注意中间没有run命令，直接跟task名字

```sh
hh full:initialize-lending-pool --pool Aave --network kovan
```



## 1. 使用官方资产部署

```sh
LendingPoolAddressesProvider: 0x604393277F9941756eF0660e52a891D80DDA9A8D
LendingPool: 0x71b364b8f6a8eC762C491c35A2eeeECC2318FfBC
LendingPoolConfigurator: 0xF58B5e7260A15d877de7c3feD692206467334F1D
StableAndVariableTokensHelper: 0xca0Cc5078B70b2A044a68a3d62168B1E70DDeE6B
ATokensAndRatesHelper: 0x3fCd82134F4D8d255dB8E13C104BfC1Ff75E7062
AToken: 0xFf7203d4a95FB96edeAFbC824ebfA0227Ce39818
DelegationAwareAToken: 0xC37111E660ec4aa36e87f88eFb234B82a2FF7AF0
StableDebtToken: 0xBdfa271e8b528f317C5EDF696DFD192996bAa59a
VariableDebtToken: 0x3e9E6972bdDd4BBb6b05602fA658e937E41DF2c8
AaveProtocolDataProvider: 0x63d6A6bF940d6D23113a393BEe99EA5AA16ad599
WETHGateway: 0xCb2148c72a5f43e92150e4f0bF638b9eCdAc2eEb
DefaultReserveInterestRateStrategy: 0x5A2c62bcE4b26Bc72B7Df2f04904d298499d98F9
rateStrategyStableTwo: 0x4d44D18925047F92f53bED911bC120A0FdD7CBA3
rateStrategyWETH: 0x5A2c62bcE4b26Bc72B7Df2f04904d298499d98F9
LendingPoolCollateralManagerImpl: 0x0E5914f696965cA1a7eCdfa17738EE28dCEb3c5D
LendingPoolCollateralManager: 0x0E5914f696965cA1a7eCdfa17738EE28dCEb3c5D
WalletBalanceProvider: 0x1d0Aa32eF595a7641d8Fd4ff3F077BFe6699318F
UiPoolDataProvider: 0xD74c7b782B50C02fbB7aD48D4117D157D415A68A
```



自己部署需要哪些准备：

1. 所有的资产需要自己部署合约，DAI、WBTC等，ETH还是使用WETH官方的。币种可以直接使用
2. chainlink自己mock，实现getPrice和setPrice方法，设置到Aggregator中
3. ui的水龙头不再使用，我们自己发送币种。先试试：deploy-new-asset



## 2. 前端需要的地址

部署UniswapRepayAdapter，根据参数，添加一个部署命令到package.json中。

其中需要：LendingPoolAddressesProvider、router2、weth参数，都是我们自己部署的。

执行，记录地址，放在前端页面的：baseUniswapAdapter字段

```sh
npx hardhat --network kovan deploy-UniswapRepayAdapter --provider 0x604393277F9941756eF0660e52a891D80DDA9A8D --router 0xDC292C81e24efB77Bc69e6d3727E3727EC1bF170 --weth 0xd0a1e359811322d97991e03f863a0c30c2cf029c

#0xaA0871B294198B81311108fC1E6a7e09C09aBD97，自己
```

执行，记录地址，这个就是UiPoolDataProviderV2，==注意是V2==，放在前端页面的：uiPoolDataProvider字段

==（自动部署脚本好像已经部署这个了）==（是的，不需要自己部署了）

```sh
npm run dev:deployUIProviderV2

#0x6062ad399E47BF75AEa0b3c5BE7077c1E8664Dcb，官方
#0x65c596620a4370DE9ed110e6594538b1E71E8bb7，自己
```

执行，记录地址，放在前端页面的：uiIncentiveDataProvider字段

```sh
npm run dev:deployUIIncentivesProviderV2

#0x9842E5B7b7C6cEDfB1952a388e050582Ff95645b，官方
#0xeCF1236E20a5bDF828a1FbA4FAaAC8ad991752F7，自己
```



## 3. 经验小结

1. 经常time out，需要反复重试。

2. lending pool脚本中，这两处总出错：我猜想是因为已经设置过了。但是看代码有没有看到相应逻辑

   ```sh
   addressesProvider.setLendingPoolImpl
   addressesProvider.setLendingPoolConfiguratorImpl
   ```

3. LendingPoolImpl和LendingPool地址不同，相当于代理关系，同一个addressesProvider只能set一次

4. LendingPoolConfiguratorImpl和LendingPoolConfigurator地址不同，相当于代理关系，同一个addressesProvider只能set一次

5. LendingPoolImpl和LendingPoolConfiguratorImpl可以设置到配置文件中，common.ts中。

6. 下面这种格式的输出来自原：withSaveAndVerify下面的registerContractInJsonDb

   ```sh
   *** AaveOracle ***
   
   Network: kovan
   tx: 0x78a8aad426a131a6f9d9b962e251e5c132348414c6d009d89e68d326cbadabe7
   contract address: 0x4578344f10246e3dc96b7D2c6E7854fF3798678A
   deployer address: 0xEf884C06F2aBf71040ff28976E3a85DDa8813ab2
   gas price: 3000000000
   gas used: 781715
   
   ******
   ```

7. 部署过程出错的少，设置的时候经常出错，一般是 timeout。

8. 每个资产的借款利率BorrowRate有一个默认的固定设置：LendingRateOracleRatesCommon结构，我们将commons.ts中LendingRateOracle字段设置为空即可，这样就会使用LendingRateOracleRatesCommon的数据。

9. 在部署自己资产、chainlink时，在部署oracle环节，chainlink里面需要加上USD地址

   ![image-20220106224136944](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20220106224136944.png)

   ![image-20220106224210279](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20220106224210279.png)
   
10. emergencyAdmin和PoolAdmin是两个地址，emergencyAdmin是index：1， PoolAdmin是index：0。

## 4. 如何添加单个新资产

1. 在index中选中本次要添加的资产，已经添加过的要注释掉。(直接这样增加有问题)

2. 在initialize脚本中，将config之后的逻辑注释掉。

3. 直接执行initialize脚本。（在migration脚本中，将前面的环节注释掉）。

   

## 5. 配置了固定地址

这些地址部署一次后可以重复使用，commons.ts

| 配置参数                     | json名字 | 地址                                       | 部署环节       |
| ---------------------------- | -------- | ------------------------------------------ | -------------- |
| ProviderRegistry             |          | 0xbC7Fe19757b45b7821Ea56Ab7d145FFE1Fa23DE4 |                |
| LendingPoolCollateralManager |          | 0x0E5914f696965cA1a7eCdfa17738EE28dCEb3c5D | initialize中   |
| LendingPoolConfigurator      |          | 0xE246D9c2dFF32DF7ee8129122BCAc2f858B7c95f | lending_pool中 |
| LendingPool（这是impl）      |          | 0x8f254f0358Bd7814672A98ebBb11491681dd1f94 | lending_pool中 |
| AaveOracle                   |          | 0x4578344f10246e3dc96b7D2c6E7854fF3798678A | oracle中       |

# 二、部署自己的资产&chainlink

运行：这个token源码中对mint没有权限校验，可以添加上。

```sh
#npx hardhat dev:deploy-all-mock-tokens --network kovan --verify

#不要加verify了，已经verify过了，否则很慢
npx hardhat dev:deploy-all-mock-tokens --network kovan
```

| name       | address                                    | mock chainlink eg. DAI/ETH                     | token decimal |
| ---------- | ------------------------------------------ | ---------------------------------------------- | ------------- |
| WETH(官方) | 0xd0a1e359811322d97991e03f863a0c30c2cf029c |                                                | 18            |
| DAI        | 0x749B1c911170A5aFEb68d4B278cD5405C718fc7F | 0x8a40f7E2c2E9Fa3d9aDced37f9b6949F30df8A33, 18 | 18            |
| LINK       | 0xb450d49CaF849875d63ADDdd5868EC1A8bfF2d29 | 0x4f8B341B5CDB526fE0ec6e0F0FA6D2D1A97aBAc5, 18 | 18            |
| WBTC       | 0x5D14d5F575a8B17801633fccaa5C0Ed78e657BdA | 0x0b93B7dcf417E4A43318bB2699c3e7475A9D3501, 18 | 8             |
| USDC       | 0x3878E7d2a355FB01a06db656690Cb8795f6663F2 | 0xD399CA4eEE55d8B32F5185fCe3E4e8C50C24D74F     | 6             |
|            |                                            |                                                |               |

1. deployer：0xEf884C06F2aBf71040ff28976E3a85DDa8813ab2
2. 任何人都有mint权限

## 1. mock chainlink源码

~~页面使用：展示价格专用ETH/DAI专用~~（这个是错的）

~~合约层面使用下面这个，主要是dai的价格不同。前者直接返回10000000000000，下面这个显示：9676888686749（计算得到，相对于eth）~~

## 0. aave追踪uniswap价格

前端页面也使用这个，symbol和decimals分别是：ETH,8，其他币种分别填写WBTC,18等。

```js

// File: chainlinkMock/ours/IERC20.sol

/**
 *Submitted for verification at Etherscan.io on 2022-01-12
 */

// File: contracts/IERC20.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity >=0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
  /**
   * @dev Returns the decimals.
   */
  function decimals() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: chainlinkMock/ours/IUniswapV2Pair.sol

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external pure returns (string memory);

  function symbol() external pure returns (string memory);

  function decimals() external pure returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  function nonces(address owner) external view returns (uint256);

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  event Mint(address indexed sender, uint256 amount0, uint256 amount1);
  event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
  event Swap(
    address indexed sender,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out,
    address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint256);

  function factory() external view returns (address);

  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );

  function price0CumulativeLast() external view returns (uint256);

  function price1CumulativeLast() external view returns (uint256);

  function kLast() external view returns (uint256);

  function mint(address to) external returns (uint256 liquidity);

  function burn(address to) external returns (uint256 amount0, uint256 amount1);

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;

  function skim(address to) external;

  function sync() external;

  function initialize(address, address) external;
}

// File: chainlinkMock/ours/mockChainlinkFollowUniswap.sol


pragma solidity 0.6.12;



contract MockAggregator {
  uint256 private _latestAnswer;
  string public symbol;
  address public addr;
  uint256 public decimals;
  mapping(bytes32 => address) symbolPairs;

  bytes32 ETH = keccak256(abi.encodePacked('ETH'));
  bytes32 DAI = keccak256(abi.encodePacked('DAI'));
  bytes32 WBTC = keccak256(abi.encodePacked('WBTC'));
  bytes32 CHAINLINK = keccak256(abi.encodePacked('CHAINLINK'));
  bytes32 MKR = keccak256(abi.encodePacked('MKR'));
  bytes32 USDC = keccak256(abi.encodePacked('USDC'));

  /*
  dai addr：0x749B1c911170A5aFEb68d4B278cD5405C718fc7F

  token地址比dai大的：
  1. 0xd0a1e359811322d97991e03f863a0c30c2cf029c, weth
  2. 0xb450d49CaF849875d63ADDdd5868EC1A8bfF2d29, link
  3. 0xF7190d0ed47b3E081D16925396A03363DdB82281, mkr（清算使用）


  token地址比dai小
  1. 0x5D14d5F575a8B17801633fccaa5C0Ed78e657BdA, wbtc
  2. 0x3878E7d2a355FB01a06db656690Cb8795f6663F2, usdc（清算使用）
  
  */

  //dai: token0
  //eth: token1
  //pair地址
  address public ethDaiPairAddr = 0xc2a84f8e6a1a6011ccE0854C482217def6FbA8eE;
  address public wbtcDaiPairAddr = 0x7a30b9AAe79374c440D5f7A0388696C8bfB76677;
  address public chainlinkDaiPairAddr = 0xCdD4b06f6FF77B8D338FAB21606B8356A1C7ed14;
  address public usdcPair = 0x5170C73cc49A68bEA24eEEea5f2ea0a070999484;

  //大小写居然还有关系，直接使用remix提示的地址来更新就行了。
  address public mkrDaiPairAddr = 0x560CcA4DE9eB4f42021F1A383825AB906ffFFA4c;

  address public daiAddr = 0x749B1c911170A5aFEb68d4B278cD5405C718fc7F;

  constructor(string memory _symbol, uint256 _decimals) public {
    symbolPairs[ETH] = ethDaiPairAddr;
    symbolPairs[DAI] = ethDaiPairAddr;
    symbolPairs[WBTC] = wbtcDaiPairAddr;
    symbolPairs[CHAINLINK] = chainlinkDaiPairAddr;
    symbolPairs[MKR] = mkrDaiPairAddr;
    symbolPairs[USDC] = usdcPair;

    bytes32 symbol_ = keccak256(abi.encodePacked(_symbol));
    require(symbolPairs[symbol_] != address(0), 'not support token symbol!');
    symbol = _symbol;
    decimals = _decimals;
  }

  function latestAnswer() external view returns (uint256) {
    bytes32 symbol_ = keccak256(abi.encodePacked(symbol));
    (uint256 priceTmp, uint256 decimalsTmp) = getTokenPriceToDai(ethDaiPairAddr);

    if (symbol_ == ETH) {
      return (priceTmp * 10**decimals) / 10**decimalsTmp;
    } else if (symbol_ == DAI) {
      return 10**decimals / (priceTmp / 10**decimalsTmp);
    } else {
      return getTokenPriceToEth(symbolPairs[symbol_]);
    }
  }

  // calculate price based on pair reserves
  function getTokenPriceToEth(address pairAddress) public view returns (uint256) {
    //数量，这个币种的精度，wbc，8；chainlink，18
    (uint256 toDaiPrice, uint256 decimals1) = getTokenPriceToDai(pairAddress);
    (uint256 daiEthPrice, uint256 decimals2) = getTokenPriceToDai(ethDaiPairAddr);
    uint256 v1 = toDaiPrice*10**decimals / 10**decimals1;
    uint256 v2 = daiEthPrice / 10**decimals2;
    
    return (v1 / v2);
  }

  // calculate price based on pair reserves
  function getTokenPriceToDai(address pairAddress) public view returns (uint256, uint256) {
    IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
    IERC20 token0 = IERC20(pair.token0());
    IERC20 token1 = IERC20(pair.token1());

    (uint256 Res0, uint256 Res1, ) = pair.getReserves();
    if (address(token0) == daiAddr) {
      //比dai地址大,eth, link
      uint256 res0 = Res0 * (10**token1.decimals());

      //103453 * 10^decimals
      return (res0 / Res1, token0.decimals());
    }

    //mkr, usdc
    uint256 res1 = Res1 * (10**token0.decimals());
    return (res1 / Res0, token1.decimals());
  }
}
```

调用方法，参考：

```js
import { ethers } from "ethers";
const { ethereum } = window;
if (ethereum) {
    var provider = new ethers.providers.Web3Provider(ethereum);
}

const uniswapUsdcAddress = "0xb4e16d0168e52d35cacd2c6185b44281ec28c9dc";
const uniswapAbi = ... // get the abi from https://etherscan.io/address/0xb4e16d0168e52d35cacd2c6185b44281ec28c9dc#code

const getUniswapContract = async address => await new ethers.Contract(address, uniswapAbi, provider);

const getEthUsdPrice = async () => await getUniswapContract(uniswapUsdcAddress)
    .then(contract => contract.getReserves())
    .then(reserves => Number(reserves._reserve0) / Number(reserves._reserve1) * 1e12); // times 10^12 because usdc only has 6 decimals
```

chainlink所有的价格都是对标ETH的，例如：

```sh
DAI: '0x22B58f1EbEDfCA50feF632bD73368b2FdA96D541'
```

![image-20220106164452409](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20220106164452409.png)

1. 查询链接：https://docs.chain.link/docs/ethereum-addresses/
2. eth的价格我们先不管了，直接把所有的资产按照aave的价格设置一下，然后添加到配置文件中。已经更新在上面的资产中了。
3. 所有对ETH的资产，chainlink，decimal都是18位。



## 2. 使用自己资产部署

```sh
N# Contracts: 20
LendingPoolAddressesProvider: 0x8bD206df9853d23bE158A9F7065Cf60A7A5F05DF
LendingPool: 0x57110816Db545D4A3910dDba38fB17221a8EB506
LendingPoolConfigurator: 0x13A25AEAEFCe2b501f5D7c9D0C728c04A5411f4e
StableAndVariableTokensHelper: 0xdF394485470400Ec71Bb88f3622EFBa40D926414
ATokensAndRatesHelper: 0x9367522153a417D2FD81aECbBc223d20f326a035
AToken: 0x134365dC86dD078e45317Cf89D423DFe83D23C36
DelegationAwareAToken: 0xa32599a37944Cb9230B4B546B664e407BB683B03
StableDebtToken: 0x8105961c17DCe4e14ccA8ea59eBDbF986ea96dC8
VariableDebtToken: 0xc2fEfC6b24C9f256d15D693F2B91fa00E68ffB31
LendingRateOracle: 0x0D7Ef5F367144139a09fd3E09d7Cce8362e60955
AaveProtocolDataProvider: 0xBE24eEC0e36B39346Ccb1DFF7a4A9ef58383358E
WETHGateway: 0xD1774E644a8e48eE18E25299f1329A19c7Dc5B63
DefaultReserveInterestRateStrategy: 0xf028382d843bA8DaD4F6D6ef7EEc228523897062
rateStrategyStableTwo: 0x3a0E7e516937cE32C584ddcA4D7EbFf52e989B6B
rateStrategyVolatileOne: 0x12098A065498d4aeC6Fcf054CBfE7554739aB661
rateStrategyStableThree: 0x92bb7bdB9E10b1FfEA31dAf35DaA3199976C6Ea3
rateStrategyVolatileTwo: 0x569F92308c3F7d50d7Cf0920f8d00e2A47508f3a
rateStrategyWETH: 0xf028382d843bA8DaD4F6D6ef7EEc228523897062
WalletBalanceProvider: 0xbb148A3BE0819d92c6ACA1F7788E2876ca2Ab245
UiPoolDataProvider: 0x071E4378Fe60153925C8aC858DAA1C91CFCf2557
```

baseUniswapAdapter:(前端使用)

```sh
npx hardhat --network kovan deploy-UniswapRepayAdapter --provider 0x8bD206df9853d23bE158A9F7065Cf60A7A5F05DF --router 0xDC292C81e24efB77Bc69e6d3727E3727EC1bF170 --weth 0xd0a1e359811322d97991e03f863a0c30c2cf029c

#0x5A88CCf2a7C0adA99ef602570a9864c195cc818B
```

uiIncentiveDataProvider:(前端使用)

```sh
npm run dev:deployUIIncentivesProviderV2

#0xF826701Bb4Db3d60255280D9a0F8bD7aBA83927C
```



## 3. verify

aave工程化代码写的真好啊，考虑的非常周全了。

```sh
npm run kovan:verify
```

# 三、日常操作

## 1. unpause市场

刚刚部署的资产市场是pause的，需要手动设置为unpause才能正常使用

```sh
hh full:unpause --pool Aave --network kovan
```

## 2. 冻结market

对某个asset的市场进行暂停使用，可以执行如下命令。

```sh
hh full:freeze --pool Aave --network kovan

#内部会调用freezeReserve(MKR地址)
#注意emergencyAdmin和PoolAdmin是两个地址，emergencyAdmin是index：1， PoolAdmin是index：0。
```

## 3. 如果错误了点击了其他市场

需要清理浏览器cache，否则一直出现网络错误。

## ==4. 更新预言机地址==

1. 将预言机部署好（==1. mock chainlink源码==），并填写到对应的配置文件中，单独运行task：3_oracles.ts，会将每个资产的oracle以键值对的形式添加到aaveOracle这个合约中，运行如下命令：

   ```sh
   hh full:deploy-oracles --pool Aave --network kovan
   ```

2. 上面都是给合约使用的，下面需要部署一个地址，ETH/USD，用于给ui界面展示价格，更新ETH/USD地址，这个合约与之前的oracle合约（==1. mock chainlink源码==）代码相同，只是输入的参数decimals是8，其他的是18。部署之后，在constants.ts中chainlinkEthUsdAggregatorProxy和chainlinkAggregatorProxy中都要修改成这个地址，然后运行命令：

   ```sh
   npm run dev:deployUIProviderV2
   ```

   将地址更新到aave-ui中的ui-config/networks.ts中：

   ```sh
   uiPoolDataProvider: '0x60311E24f29208C2E3490F8e66414Ded4C75Ee32', //duke 自己的
   ```

   

## 5. 清算

清算doc：https://docs.aave.com/developers/guides/liquidations

调整完chainlink价格：20-》30，健康系数变为0.71< 1，可以被清算

![image-20220109232037128](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20220109232037128.png)

参数：

![image-20220109232337665](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20220109232337665.png)

# 四、页面

## 1. src/ui-config文件夹

### 1.1 networks.ts中

这四个都是要修改的，1，2，4是上面部署的，3是subgraph需要额外部署。

![image-20220106080811172](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20220106080811172.png)

### 1.2. markets/index中

![image-20220105163959326](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20220105163959326.png)

## 2. 启动页面

```sh
npm run start:dev
```

## 3. 出现的错误

### 1.1. 错误1

network中的uiPoolDataProvider中，传入LendingPoolAddressesProvider地址，可以获取支持的资产列表，所以我们需要手动设置一下。这个是因为部署了uiPoolDataProvider而不是uiPoolDataProviderV2（V2是对的）

![image-20220105165935332](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20220105165935332.png)

### 1.2. 错误2

可能是LENDING_POOL的原因，存款失败（approve成功，说明rpc是可以用的）。（这个是因为setPause未设置false）导致的。

![image-20220105181112193](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20220105181112193.png)

### 1.3 错误3：

存款，再借款之后，会经常出现这个错误，需要重新启动页面服务才可以。

不知道是不是和subgraph有关系。

![image-20220106080110063](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20220106080110063.png)

切换成英文对应的错误是：

![image-20220106122517037](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20220106122517037.png)

这个发生在我存入了eth之后，对应的链接如下，切换了热点之后，多刷新几次，果然重新恢复了，难道真是网络问题？？

```sh
http://localhost:3000/deposit/0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-0xd0a1e359811322d97991e03f863a0c30c2cf029c0x604393277f9941756ef0660e52a891d80dda9a8d/confirmation?amount=0.1
```

通过将rpc修改为我们自己的alchemy之后，这个问题暂时没有再出现：

```sh
    publicJsonRPCUrl: ['https://eth-kovan.alchemyapi.io/v2/-qZ8NcwdvM8gsbxWyFl_Iw9znBN5UV3t', 'https://kovan.poa.network'],
```



### 1.4 错误4：

当使用自己的资产和chainlink配置到ui中后，一直展示上面的Reload错误，这个是因为:uiPoolDataProvider引起的（切换成官方的就可以正常显示）。部署这个合约的两个参数是两个ETH/USD的地址，我改成自己的了，也许少了方法。

### 1.5 为什么test2网络上，mkrd价格是8而不是8.9



## 4. github启动页面

https://medium.com/mobile-web-dev/how-to-build-and-deploy-a-react-app-to-github-pages-in-less-than-5-minutes-d6c4ffd30f14

react手册：https://create-react-app.dev/docs/deployment/

1. 安装

```sh
npm install gh-pages --save-dev
```

2. 修改package.json，这里经常出错，注意是：https，个人账户.github.io，repo名字

```sh
  "homepage": "https://chfry-finance.github.io/chfry-aave-interface",
```

3. 添加deploy命令

```sh
    "deploy": "gh-pages -d build",
```

4. 进行编译&部署

```sh
npm run build

npm run deploy
```

5. 进入到github项目：chfry-aave-interface，进入setting界面，进入pages页面，选择分支：gh-pages，这个分支是deploy后自动生成了，里面存放的是静态页面的信息。即刚刚build时生成的内容。

![image-20220109212659732](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20220109212659732.png)

6. 访问：https://chfry-finance.github.io/markets，部署成功！

![image-20220109212728497](https://duke-typora.s3.ap-southeast-1.amazonaws.com/uPic/image-20220109212728497.png)

7. 如果无法显示：考虑清除这个Application的本地缓存，检查package.json的homepage设置的值。

# 三、DSA联调

aave官方地址：

```js
    // Aave Lending Pool Provider    
		AaveLendingPoolProviderInterface internal constant aaveProvider =
        AaveLendingPoolProviderInterface(
            0x88757f2f99175387aB4C6a4b3067c77A695b0349
        );
    // Aave Protocol Data Provider
    AaveDataProviderInterface internal constant aaveData =
        AaveDataProviderInterface(0x3c73A5E5785cAC854D468F727c606C07488a29D6);

    AavePriceOracleInterface internal constant aavePrice =
        AavePriceOracleInterface(0xB8bE51E6563BB312Cbb2aa26e352516c25c26ac1);
```

使用我自己部署的地址（自己的token，自己的chainlink）

```sh
AaveLendingPoolProviderInterface: 0x8bD206df9853d23bE158A9F7065Cf60A7A5F05DF
AaveDataProviderInterface:  0xBE24eEC0e36B39346Ccb1DFF7a4A9ef58383358E
AavePriceOracleInterface:  0x4578344f10246e3dc96b7D2c6E7854fF3798678A
```
