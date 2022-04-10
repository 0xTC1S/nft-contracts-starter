require("dotenv").config({ path: __dirname + "/.env" });
const HDWalletProvider = require("@truffle/hdwallet-provider");

// dotenv.config({ path: __dirname + "/.env" });

const MNEMONIC = process.env.MNEMONIC;
// console.log(process.env);

const APIKEY = process.env.APIKEY;
const OWNERADDRESS = process.env.OWNERADDRESS;

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 7545,
      gas: 5000000,
      network_id: "*", // Match any network id
    },
    rinkeby: {
      provider: () => {
        return new HDWalletProvider(
          MNEMONIC,
          `https://eth-rinkeby.alchemyapi.io/v2/${APIKEY}`
        );
      },
      from: OWNERADDRESS,
      gas: 5500000,
      network_id: 4,
      confirmations: 2,
      timeoutBlocks: 500,
      skipDryRun: true, // Sk
    },
    // polygon: {
    //   provider: () => {
    //     return new HDWalletProvider(
    //       MNEMONIC,
    //       `https://rpc-mumbai.maticvigil.com/v1/${key}`
    //     );
    //   },
    //   from: OWNERKEY,
    //   gas: 5500000,
    //   network_id: 80001,
    //   confirmations: 2,
    //   timeoutBlocks: 500,
    //   skipDryRun: true, // Sk
    // },
    live: {
      network_id: 1,
      provider: () => {
        return new HDWalletProvider(
          MNEMONIC,
          `https://eth.alchemyapi.io/v2/${INFURAKEY}`
        );
      },
      gas: 5000000,
      gasPrice: 5000000000,
    },
  },
  mocha: {
    reporter: "eth-gas-reporter",
    reporterOptions: {
      currency: "USD",
      gasPrice: 2,
    },
  },
  compilers: {
    solc: {
      version: "^0.8.0",
      settings: {
        optimizer: {
          enabled: true,
          runs: 20, // Optimize for how many times you intend to run the code
        },
      },
    },
  },
  plugins: ["truffle-plugin-verify"],
  api_keys: {
    etherscan: process.env.ETHERSCAN,
  },
};
