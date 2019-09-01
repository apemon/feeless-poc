<template>
    <section class="wallet-main container hero is-medium">
        <div class="wallet-nav">
            <b-icon class="wallet-nav-icon" icon="user-circle"></b-icon>
            <b-icon class="wallet-nav-icon" icon="camera"></b-icon>
        </div>
        <div class="wallet-body">
            <div class="wallet-form">
                <b-field class="wallet-field" label="Destination Address">
                    <b-input v-model="dest"></b-input>
                </b-field>
                <b-field label="Amount">
                    <b-input v-model="amount" 
                    type="number"
                    step="0.01"></b-input>
                </b-field>
            </div>
            <div class="button-group">
                <b-button class="wallet-button"
                 size="is-medium"
                 type="is-success"
                 @click="transfer">
                    Confirm
                </b-button>
                <b-button class="wallet-button"
                 size="is-medium"
                 @click="back">
                    Cancel
                </b-button>
            </div>
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
            dest: '',
            amount: 10.0
        }
    },
    async mounted() {
        this.walletService = new WalletService()
        await this.walletService.init('http://192.168.1.37:3000')
        this.info = this.walletService.loadWalletInfo()
        this.account = this.walletService.loadAccount()
    },
    methods: {
        async transfer() {
            console.log('transfer')
            await this.walletService.transfer(this.info.address, this.dest, this.amount, this.account.privateKey)
        },
        back() {
            this.$router.back()
        }
    }
}
</script>

<style lang="css" scoped>
.label {
    color: white;
}
.wallet-nav-icon {
    margin-left: 15px;
}
</style>
<style lang="css">
.label {
  color: white;
  font-size: 24px;
}
</style>