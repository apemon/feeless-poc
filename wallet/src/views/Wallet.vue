<template>
    <section class="hero is-medium is-primary">
        <!-- create wallet if not have  -->
        <div>
            hello world
        </div>
    </section>
</template>

<script>
import { Route } from 'vue-router'
import WalletService from '../services/wallet_service'

export default {
    filters: {

    },
    data() {
        return {

        }
    },
    async mounted() {
        this.walletService = new WalletService()
        await this.walletService.init('http://localhost:3000');
        this.account = this.walletService.createNewPrivateKey()
        // generate create2 wallet address
        let salt = 1
        let address = this.account.address
        let computedAddress = this.walletService.buildCreate2Address(address, salt)
        console.log(computedAddress)
        // send bytecode to provider to deploy wallet
        // send bytecode,address,salt,computedAddress
        // register did
        //this.did = new this.web3.eth.Contract(didAbi,'0xB457C434D0fd4b206614c16afA1B5d1F649294DD')
        //console.log(this.did)
        // register proxy name
    },
    methods: {
        
    }
}
</script>