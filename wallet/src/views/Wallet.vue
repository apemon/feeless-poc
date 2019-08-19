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
        try {
            await this.walletService.init('http://localhost:3000')
            this.account = this.walletService.createNewPrivateKey()
            // generate create2 wallet address
            let salt = 1
            let address = this.account.address
            let computedAddress = this.walletService.buildCreate2Address(address, salt)
            let response = await this.walletService.deployWallet(address, computedAddress, salt)
        } catch (err) {
            console.log(err)
            return
        }
    },
    methods: {
        
    }
}
</script>