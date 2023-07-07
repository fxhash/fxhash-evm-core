import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-gas-reporter";
import "hardhat-contract-sizer";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  gasReporter: {
    enabled: false,
    currency: "USD",
    token: "ETH",
    gasPrice: 21,
    showTimeSpent: true,
    coinmarketcap: "bebf8f02-d0a9-4508-8fd8-3140dbdf38cb",
  },
};

export default config;
