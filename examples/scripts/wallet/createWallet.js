import { ethers } from "ethers";

/**
 * Create a new wallet and prints to screen - this wallet will be empty
 * Please save MNEMONIC and private key if you wish to use it
 * You can use with metamask!
 */

export const createNewWallet = () => {
  const wallet = ethers.Wallet.createRandom();
  console.log({
    address: wallet.address,
    mnemonic: wallet.mnemonic.phrase,
    keys: { priv: wallet.privateKey, pub: wallet.publicKey },
  });
};

createNewWallet();
