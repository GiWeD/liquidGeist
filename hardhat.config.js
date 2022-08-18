require("@nomiclabs/hardhat-waffle");

require('@openzeppelin/hardhat-upgrades');

require("@nomiclabs/hardhat-etherscan");

require("@nomiclabs/hardhat-web3");

//require("hardhat-gas-reporter");

module.exports = {
  // latest Solidity version
  solidity: {
    compilers: [
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      }
    ]
  },

  networks: {

    // fantomTestnet network specification
    fantomTestnet: {
      url: `https://rpc.testnet.fantom.network`,
      chainId: 0xfa2,
      gas: 2100000,
      gasPrice: 8000000000,
    },


    // fantomOpera network specification
    fantomOpera: {
      url: `https://rpc.ftm.tools/`,
      chainId: 250,
      //accounts: [`0x${""}`], //
      gas: 1000000
    },


    hardhat: {
      forking: {
          url: "https://rpc.ftm.tools", // command line:  npx hardhat node --fork https://rpcapi.fantom.network,
      },
      //accounts: []
    }
  
  },

  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    //apiKey: ""
  }

}