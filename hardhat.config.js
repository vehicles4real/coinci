'use strict';

require('@nomiclabs/hardhat-waffle');

module.exports = {
  solidity: "0.8.4",
  networks: {
    mainnet: {
      url: 'https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      accounts: { mnemonic: 'YOUR_MNEMONIC' }
    },
    polygon: {
      url: 'https://polygon-mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      accounts: { mnemonic: 'YOUR_MNEMONIC' }
    },
    sepolia: {
      url: 'https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID',
      accounts: { mnemonic: 'YOUR_MNEMONIC' }
    }
  }
};
