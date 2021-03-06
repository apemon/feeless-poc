import Web3 from 'web3'
import axios from 'axios'
import moment from 'moment'
import WalletContract from '../contracts/Wallet.json'
import TokenContract from '../contracts/TCCoin.json'
import BigNumber from 'bignumber.js'

class WalletService {
    constructor() {
        
    }

    async init(url) {
        this.provider = url;
        try {
            let response = await axios.get(url+"/info")
            this.config = response.data
        } catch(err) {
            console.log(err)
            // push message to ui
            throw err
        }
        
        // get web3
        if (typeof this.web3 !== 'undefined') {
            this.web3 = new Web3(this.web3.currentProvider)
        } else {
            this.web3 = new Web3(new Web3.providers.HttpProvider(this.config.web3Address))
        }
        // web client for wallet service provider

    }

    isEmpty() {
        return !localStorage["TCWallet"]
    }

    loadAccount() {
        let wallet = this.web3.eth.accounts.wallet.load('')
        return wallet[0]
    }

    loadWalletInfo() {
        return JSON.parse(localStorage.getItem('TCWallet'))
    }

    createNewPrivateKey() {
        // create wallet first
        let wallet = this.web3.eth.accounts.wallet.create()
        // generate private key
        let account = this.web3.eth.accounts.create('')
        // save wallet to localStorage
        wallet.add(account)
        wallet.save('')
        return account
    }

    async getWalletInfo(address) {
        try {
            let response = await axios.get(this.provider + '/wallet/' + address )
            return response.data
        } catch(err) {
            console.log(err)
        }
    }

    async deployWallet(address, computedAddress, salt) {
        let bytecode = this.createByteCode(address)
        let request = {
            bytecode: bytecode,
            address: address,
            computedAddress: computedAddress,
            salt: salt
        }
        try {
            let response = await axios.post(this.provider + '/wallet/deploy', request)
            let walletObj = {
                address: computedAddress,
                owner: address
            }
            localStorage.setItem('TCWallet', JSON.stringify(walletObj))
            return response.data.address
        } catch (err) {
            console.log(err)
        }
    }

    async registerDidRegistry(walletAddress, privateKey) {
        // create hash msg
        let instance = new this.web3.eth.Contract(WalletContract.abi, walletAddress)
        let walletInfo = await this.getWalletInfo(walletAddress)
        let nonce = walletInfo.nonce
        let hash = await instance.methods.createPreAuthSetRegistryAddress(this.config.didRegistryAddress, nonce).call()
        // sign
        let signature = this.web3.eth.accounts.sign(hash, privateKey)
        // send to backend to process pre auth request
        let request = {
            walletAddress: walletAddress,
            nonce: nonce,
            signature: signature.signature
        }
        try {
            let response = await axios.post(this.provider + '/wallet/'+ walletAddress +'/setRegistry', request)
            return response.data
        } catch(err) {
            console.log(err)
        }
    }

    async queryBalance(walletAddress) {
        let instance = new this.web3.eth.Contract(TokenContract.abi, this.config.tokenAddress)
        let balance = await instance.methods.balanceOf(walletAddress).call()
        return BigNumber(balance).div(1e2).toNumber()
    }

    async transfer(walletAddress, destination, amount, privateKey) {
        console.log(walletAddress)
        let walletInfo = await this.getWalletInfo(walletAddress)
        let nonce = walletInfo.nonce
        let instance = new this.web3.eth.Contract(WalletContract.abi, walletAddress)
        amount = BigNumber(amount).times(1e2).toNumber()
        let hash = await instance.methods.createPreAuthTransferToken(this.config.tokenAddress, destination, amount, this.config.fee, nonce).call()
        let signature = this.web3.eth.accounts.sign(hash, privateKey)
        let request = {
            walletAddress: walletAddress,
            nonce: nonce,
            fee: this.config.fee,
            amount: amount,
            destination: destination,
            signature: signature.signature
        }
        try {
            let response = await axios.post(this.provider + '/wallet/' + walletAddress + '/transfer', request)
            return response.data
        } catch (err) {
            console.log(err)
        }
    }

    async mint(walletAddress) {
        try {
            let response = await axios.post(this.provider + '/wallet/' + walletAddress + '/mint', {})
            return response
        } catch(err) {
            console.log(err)
        }
    }

    // specific web3 method
    buildCreate2Address(address, salt) {
        let bytecode = this.createByteCode(address)
        let saltHex = this.numberToUint256(salt)
        return `0x${this.web3.utils.sha3(`0x${[
            'ff',
            this.config.factoryAddress,
            saltHex,
            this.web3.utils.sha3(bytecode)
        ].map(x => x.replace(/0x/, ''))
        .join('')}`).slice(-40)}`.toLowerCase()
    }

    createByteCode(address) {
        let walletByteCode = WalletContract.bytecode
        let bytecode = `${walletByteCode}${this.encodeParam('address', address).slice(2)}`
        return bytecode 
    }

    numberToUint256(value) {
        const hex = value.toString(16)
        return `0x${'0'.repeat(64-hex.length)}${hex}`
    }

    encodeParam(dataType, data) {
        return this.web3.eth.abi.encodeParameter(dataType, data)
    }
}

export default WalletService