const express = require('express')
const bodyParser = require('body-parser')
const cors = require('cors')
const HDWalletProvider = require('truffle-hdwallet-provider')
const Web3 = require('web3')
const explorer = require('./explorer')

const Factory = require('./abi/Factory')
const Wallet = require('./abi/Wallet')
const DidRegistry = require('./abi/DidRegistry')

require('dotenv').config()

const app = express()

app.use(bodyParser.json())
app.use(cors())

const web3Address = process.env.web3Address
const factoryAddress = process.env.factoryAddress
const didRegistryAddress = process.env.didRegistryAddress
const tokenAddress = process.env.tokenAddress
const privateKey = process.env.privateKey
const deployerAddress = process.env.deployerAddress
const network = process.env.network
const explorerApiKey = process.env.explorerApiKey

const provider = new HDWalletProvider(privateKey, web3Address)
const web3 = new Web3(provider)
const factory = new web3.eth.Contract(Factory.abi, factoryAddress)
const didRegistry = new web3.eth.Contract(DidRegistry.abi, didRegistryAddress)

app.listen(3000, () => {

});

app.get('/info', (req,res) => {
    var info = {
        web3Address: web3Address,
        factoryAddress: factoryAddress,
        didRegistryAddress: didRegistryAddress,
        tokenAddress: tokenAddress,
        network: network
    }
    return res.send(info)
})

app.get('/wallet/:address', async (req,res) => {
    let walletAddress = req.params.address
    let wallet = new web3.eth.Contract(Wallet.abi, walletAddress)
    let owner = await wallet.methods.owner().call()
    let registry = await wallet.methods.registry().call()
    var result = {
        owner: owner,
        registry: registry
    }
    // call explorer url
    try {
        let nonce = await explorer.getNonceFromExplorer(network, walletAddress, explorerApiKey)
        result['nonce'] = nonce

    } catch (err) {
        console.log(err)
    }

    return res.send(result)
})

app.post('/wallet/deploy', async (req,res) => {
    // compute address
    var body = req.body
    let computedAddress = buildCreate2Address(body.address, body.salt)
    if(computedAddress != body.computedAddress) return res.status(400)
    // need to more check bytecode for security
    const nonce = await web3.eth.getTransactionCount(deployerAddress)
    console.log(nonce)
    try {
        let response = await factory.methods.deploy(body.bytecode, body.salt).send({
            from: deployerAddress,
            gas: 4500000,
            gasPrice: 1000000000,
            nonce
        })
        console.log(response)
        return res.send(response.data)
    } catch(err) {
        console.log(err)
        return res.status(400).json(err)
    }
})

app.post('/wallet/owner/setRegistry', async (req,res) => {
    let body = req.body
    console.log(body)
    let wallet = new web3.eth.Contract(Wallet.abi, body.walletAddress)
    let nonce = await web3.eth.getTransactionCount(deployerAddress)
    try {
        let response = await wallet.methods.preAuthSetRegistryAddress(body.signature, didRegistryAddress, body.nonce).send({
            from: deployerAddress,
            gas: 4500000,
            gasPrice: 1000000000,
            nonce
        })
        console.log(response)
        return res.send(response.data)
    } catch(err) {
        console.log(err)
        return res.status(400).json(err)
    }
})

function buildCreate2Address(address, salt) {
    let bytecode = createByteCode(address, Wallet.bytecode)
    let saltHex = numberToUint256(salt)
    return `0x${web3.utils.sha3(`0x${[
        'ff',
        factoryAddress,
        saltHex,
        web3.utils.sha3(bytecode)
    ].map(x => x.replace(/0x/, ''))
    .join('')}`).slice(-40)}`.toLowerCase()
}

function createByteCode(address, walletByteCode) {
    let bytecode = `${walletByteCode}${encodeParam('address', address).slice(2)}`
    return bytecode 
}

function numberToUint256(value) {
    const hex = value.toString(16)
    return `0x${'0'.repeat(64-hex.length)}${hex}`
}

function encodeParam(dataType, data) {
    return web3.eth.abi.encodeParameter(dataType, data)
}