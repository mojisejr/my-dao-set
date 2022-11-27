import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomicfoundation/hardhat-toolbox";
import "./tasks/deploy/dao";
import { config as dotenvConfig } from "dotenv";
import { resolve } from "path";
dotenvConfig({ path: resolve(__dirname, "./.env") });

const config: HardhatUserConfig = {
  defaultNetwork: "localhost",
  networks: {
    goerli: {
      url: "https://eth-goerli.g.alchemy.com/v2/uLt7UG2JOQRZKuvuhG-ARE-7_2i5oTXA",
      accounts: [process.env.wallet!],
    },
    bitkub_testnet: {
      url: "https://rpc-testnet.bitkubchain.io",
      accounts: [process.env.wallet!],
    },
    mumbai_testnet: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: [process.env.wallet!],
    },
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 3000,
      },
    },
  },
  etherscan: {
    apiKey: "23Y6847UATWJXN3ZUJAYTJFRR4H64HXKXD",
    // apiKey: "PX1UPAJSMHJPBT8N6GWIUXQZCE26TFPMU3",
  },
};

export default config;
