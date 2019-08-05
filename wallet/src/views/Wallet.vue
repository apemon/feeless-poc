<template>
    <section class="hero is-primary">
        <!-- create wallet if not have  -->
        <div>
            hello world11111111111111111111111111111111111111111111111111111111
        </div>
    </section>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';
import { Route } from 'vue-router'
import Web3 from 'web3'
const {abi:didAbi } = require('../contracts/IDidRegistry.json')
const {abi:walletAbi, bytecode:walletByteCode} = require('../contracts/Wallet.json')

@Component
export default class Home extends Vue {
    web3:any;
    wallet:any;
    account:any;
    did:any;
    data() {
        return {
            msg: 'hello world 123'
        }
    }
    mounted() {
        if (typeof this.web3 !== 'undefined') {
            this.web3 = new Web3(this.web3.currentProvider);
        } else {
            this.web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:7545'));
            //web3 = new Web3(new Web3.providers.HttpProvider('https://kovan.infura.io/v3/4cab21ef5bcb43fda533bf575782fe18'));
        }
        // create wallet first
        this.wallet = this.web3.eth.accounts.wallet.create()
        // generate private key
        this.account = this.web3.eth.accounts.create('')
        // save wallet to localStorage
        this.wallet.add(this.account)
        this.wallet.save('')
        // generate create2 wallet address
        let salt = 1
        let factoryAddress = '0x712C56A7e12772F1Fa8711306B2F4E6426CD6Ed8'
        let address = this.account.address
        let bytecode = `${walletByteCode}${this.encodeParam('address', address).slice(2)}`
        console.log(bytecode)
        let computedAddress = this.buildCreate2Address(factoryAddress, this.numberToUint256(salt), bytecode);
        console.log(computedAddress)
        // send bytecode to provider to deploy wallet
        // send bytecode,address,salt,computedAddress
        // register did
        this.did = new this.web3.eth.Contract(didAbi,'0xB457C434D0fd4b206614c16afA1B5d1F649294DD')
        console.log(this.did)
        // register proxy name
    }

    buildCreate2Address(creatorAddress:String, saltHex:String, byteCode:String):String {
        return `0x${this.web3.utils.sha3(`0x${[
            'ff',
            creatorAddress,
            saltHex,
            this.web3.utils.sha3(byteCode)
        ].map(x => x.replace(/0x/, ''))
        .join('')}`).slice(-40)}`.toLowerCase()
    }

    numberToUint256(value:Number):String {
        const hex = value.toString(16)
        return `0x${'0'.repeat(64-hex.length)}${hex}`
    }

    encodeParam(dataType:String, data:String):String {
        return this.web3.eth.abi.encodeParameter(dataType, data)
    }
}
</script>