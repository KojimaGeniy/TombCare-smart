const { readFileSync } = require('fs')
const LoomTruffleProvider = require('loom-truffle-provider')
const HDWalletProvider = require("truffle-hdwallet-provider");

const chainId    = 'default'
const writeUrl   = 'http://127.0.0.1:46658/rpc'
const readUrl    = 'http://127.0.0.1:46658/query'
const privateKey = readFileSync('./private_key', 'utf-8')

const loomTruffleProvider = new LoomTruffleProvider(chainId, writeUrl, readUrl, privateKey)
loomTruffleProvider.createExtraAccounts(10)

const infura_apikey = "RF12tXeeoCJRZz4txW2Y";
const mnemonic = "candy maple cake sugar pudding cream honey rich smooth crumble sweet treat";
const mnemonic2 = "notable decide attract ritual outer panda defy salt judge grape other bronze";


module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    mainnet: {
      provider: new HDWalletProvider(mnemonic2, "https://mainnet.infura.io/" + infura_apikey),
      network_id: 1,
    },
    development: {
      host: "127.0.0.1",
      port: 9545,
      network_id: "8" // Match any network id
    },
    ropsten: {
      //provider: new HDWalletProvider(mnemonic, "https://ropsten.infura.io/"+infura_apikey),
      network_id: 3
    },
    kovan: {
      provider: new HDWalletProvider(mnemonic2, "https://kovan.infura.io/" + infura_apikey),
      network_id: 42
    },
    rinkeby: {
      provider: new HDWalletProvider(mnemonic2, "https://rinkeby.infura.io/"+infura_apikey),
      network_id: 4
    },
    loom_dapp_chain: {
      provider: loomTruffleProvider,
      network_id: '*'
    }
  }
};
