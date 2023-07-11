import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-gas-reporter";
import "hardhat-contract-sizer";

const config: HardhatUserConfig = {
  // Add this optional config to be able to run Forge scripts with hardhat local node
  // networks: {
  //   hardhat: {
  //     mining: {
  //       auto: false,
  //       mempool: {
  //         order: "fifo",
  //       },
  //       interval: [1000, 2000],
  //     },
  //   },
  // },
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
