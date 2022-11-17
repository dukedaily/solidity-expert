import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
// import * as dotenv from "dotenv";
require('dotenv').config()

const PRIVATE_KEY = process.env.PRIVATE_KEY || ''
const ALCHEMY_KEY = process.env.ALCHEMY_KEY || ''
const INFURA_KEY = process.env.INFURA_KEY || ''
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || ''

console.log("PRIVATE_KEY: ", PRIVATE_KEY);
console.log("ALCHEMY_KEY: ", ALCHEMY_KEY);

const config: HardhatUserConfig = {
    networks: {
        hardhat: {
        },
        goerli: {
            url: `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_KEY}`,
            accounts: [PRIVATE_KEY]
        },
        mainnet: {
            url: `https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_KEY}`,
            accounts: [PRIVATE_KEY]
        },
        kovan: {
            // url: `https://eth-kovan.g.alchemy.com/v2/${ALCHEMY_KEY}`,
            url: `https://kovan.infura.io/v3/${INFURA_KEY}`,
            accounts: [PRIVATE_KEY]
        },
        ropsten: {
            // url: `https://eth-kovan.g.alchemy.com/v2/${ALCHEMY_KEY}`,
            url: `https://ropsten.infura.io/v3/${INFURA_KEY}`,
            accounts: [PRIVATE_KEY]
        }
    },
    solidity: {
        version: "0.8.9",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200
            }
        }
    },
    etherscan: {
        apiKey: {
          ropsten: ETHERSCAN_API_KEY
        }
      }
};

export default config;
