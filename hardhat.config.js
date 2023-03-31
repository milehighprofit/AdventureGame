require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config()

module.exports = {
  solidity: '0.8.17',
  networks: {
    goerli: {
      url: process.env.YOUR_QUICKNODE_API_URL,
      accounts: [process.env.PRIVATE_KEY]
    },
  },
};
