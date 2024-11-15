/**
 * @type import('hardhat/config').HardhatUserConfig
 */

require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@nomicfoundation/hardhat-chai-matchers");
require("@openzeppelin/hardhat-upgrades");
require("hardhat-contract-sizer");
require("hardhat-abi-exporter");

const { PRIVATE_KEY } = process.env;

module.exports = {
  networks: {
    hardhat: {},
    localhost: {
      url: "http://localhost:8545",
    },
    NEOX: {
      url: "https://mainnet-1.rpc.banelabs.org",
      accounts: [`0x${PRIVATE_KEY}`],
      chainId: 47763,
      gasPrice: 40000000000,
    },
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
        details: {
          yul: false,
        },
      },
    },
  },
  defaultNetwork: "NEOX",
};
