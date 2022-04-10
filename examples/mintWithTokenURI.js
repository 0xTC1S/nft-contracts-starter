const { ethers } = require("ethers");
require("dotenv").config({ path: __dirname + "/.env" });
const ContractData = require("./scripts/helpers/abi/ERC721URIRoyalty.json");

const importWallet = (mnemonic) => {
  try {
    const wallet = ethers.Wallet.fromMnemonic(mnemonic);
    console.log(wallet);
    return wallet;
  } catch (err) {
    throw new Error(err);
  }
};

const createProviderAlchemy = (apikey, networkName) => {
  try {
    return new ethers.providers.AlchemyProvider(networkName, apikey);
  } catch (err) {
    throw new Error(err);
  }
};

const createSigner = (provider, wallet) => {
  try {
    return wallet.connect(provider);
  } catch (err) {
    throw new Error(err);
  }
};

const accessContract = (contractAddress, abi, signer) => {
  try {
    return new ethers.Contract(contractAddress, abi, signer);
  } catch (err) {
    throw new Error(err);
  }
};

/**
 * mint function to mint using ERC721URIRoyalty Contract
 * @param {*} mnemonic
 * @param {*} address
 * @param {*} tokenURI
 * @param {*} providerDetails
 * @param {*} contractDetails
 * @returns
 */

const mint = async (
  mnemonic,
  address,
  tokenURI,
  providerDetails,
  contractDetails
) => {
  try {
    const wallet = importWallet(mnemonic);
    const provider = createProviderAlchemy(
      providerDetails.apiKey,
      providerDetails.networkName
    );
    const signer = createSigner(provider, wallet);
    const contract = accessContract(
      contractDetails.contractAddress,
      contractDetails.abi,
      signer
    );
    if (await contract.deployed()) {
      const minted = await contract.mintTo(address, tokenURI);
      console.log(minted);

      // wait for 2 confirmations

      const txwait = await minted.wait(2);
      console.log(txwait);
      return "COMPLETE";
    } else {
      throw new Error("You need to deploy this contract as it does not exist");
    }
  } catch (err) {
    throw new Error(err);
  }
};

// mint to self
mint(
  process.env.MNEMONIC,
  process.env.OWNERADDRESS,
  "ipfs://QmPT7KZvDqojQtxLTHDsTVZXGxwEhiKw1J7vTQ5xMfs9H2",
  {
    apiKey: process.env.APIKEY,
    networkName: process.env.NETWORK,
  },
  { contractAddress: process.env.CONTRACTADDRESS, abi: ContractData.abi }
);
