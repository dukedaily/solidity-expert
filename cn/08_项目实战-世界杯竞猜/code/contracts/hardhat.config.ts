import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";

//在配置文件中引用
require('dotenv').config()

let ALCHEMY_KEY = process.env.ALCHEMY_KEY || ''
let INFURA_KEY = process.env.INFURA_KEY || ''
let PRIVATE_KEY = process.env.PRIVATE_KEY || ''
let ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || ''

// console.log(ALCHEMY_KEY);
// console.log(INFURA_KEY);
// console.log(PRIVATE_KEY);
// console.log(ETHERSCAN_API_KEY);

const config: HardhatUserConfig = {
    // solidity: "0.8.9",
    // 配置网络 kovan, bsc, mainnet
    networks: {
        hardhat: {
        },
        goerli: {
            url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_KEY}`,
            accounts: [PRIVATE_KEY]
        },
        kovan: {
            url: `https://kovan.infura.io/v3/${INFURA_KEY}`,
            accounts: [PRIVATE_KEY]
        }
    },
    // 配置自动化verify相关
    etherscan: {
        apiKey: {
            goerli: ETHERSCAN_API_KEY
        }
    },
    // 配置编译器版本
    solidity: {
        version: "0.8.9",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200
            }
        }
    },
};

export default config;
