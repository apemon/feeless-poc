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
            if(this.walletService.isEmpty()) {
                this.account = this.walletService.createNewPrivateKey()
                // generate create2 wallet address
                let salt = 1
                let address = this.account.address
                let computedAddress = this.walletService.buildCreate2Address(address, salt)
                let response = await this.walletService.deployWallet(address, computedAddress, salt)
                // register name
                let info = this.walletService.loadWalletInfo()
                await this.walletService.registerDidRegistry(info.address, this.account.privateKey)
                await this.walletService.mint(info.address)
            } else {
                // load wallet
                let info = this.walletService.loadWalletInfo()
                this.account = this.walletService.loadAccount()
                
                // load balance
                this.balance = await this.walletService.queryBalance(info.address)
                console.log(this.balance)
            }
            
            
        } catch (err) {
            console.log(err)
            return
        }
    },
    methods: {
        
    }
}
</script>