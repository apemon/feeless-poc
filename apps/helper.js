const Web3 = require('web3');

const getWeb3 = () => {
    return new Web3(Web3.currentProvider)
}

const getContractInstance = (web3) => (contractName) => {
    const artifact = artifacts.require(contractName) // globally injected artifacts helper
    const deployedAddress = artifact.networks[artifact.network_id].address
    const instance = new web3.eth.Contract(artifact.abi, deployedAddress)
    return instance
}

module.exports = {getWeb3, getContractInstance}