import Web3 from 'web3'
import axios from 'axios'
import moment from 'moment'
import DidRegistry from '../contracts/DidRegistry.json'
import WalletContract from '../contracts/Wallet.json'

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
        }
        
        // get web3
        if (typeof this.web3 !== 'undefined') {
            this.web3 = new Web3(this.web3.currentProvider);
        } else {
            this.web3 = new Web3(new Web3.providers.HttpProvider(this.config.web3Address));
        }
        // web client for wallet service provider
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

    registerDIDRegistry(username) {

    }
    createAddress(salt) {

    }
    queryBalance() {

    }
    queryTransaction() {

    }

    // specific web3 method
    buildCreate2Address(address, salt) {
        let walletByteCode = WalletContract.bytecode
        let byteCode = `${walletByteCode}${this.encodeParam('address', address).slice(2)}`
        let saltHex = this.numberToUint256(salt)
        return `0x${this.web3.utils.sha3(`0x${[
            'ff',
            this.config.factoryAddress,
            saltHex,
            this.web3.utils.sha3(byteCode)
        ].map(x => x.replace(/0x/, ''))
        .join('')}`).slice(-40)}`.toLowerCase()
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