<template>
    <section class="wallet-main container hero is-medium">
        <div class="wallet-qr">
            <qrcode-vue :value="address" :size="size" level="H"></qrcode-vue>
        </div>
        <div class="wallet-body">
            <div class="wallet-username">
                @apemon
            </div>
            <div class="wallet-address">
                {{address}}
            </div>
            <div class="button-group">
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
import QrcodeVue from 'qrcode.vue'

export default {
    components: {
        QrcodeVue
    },
    data() {
        return {
            address: '',
            size: 260
        }
    },
    async mounted() {
        // init wallet
        this.walletService = new WalletService()
        await this.walletService.init('https://192.168.1.37:3000')
        this.info = this.walletService.loadWalletInfo()
        this.account = this.walletService.loadAccount()
        this.address = this.info.address
    },
    methods: {
        back() {
            this.$router.back()
        }
    }
}
</script>

<style lang="css" scoped>
.wallet-qr {
    background-color: white;
    padding: 10px;
    margin: 20px;
}
.wallet-username {
    font-size: 28px;
}
.wallet-address {
    font-size: 24px;
    overflow-wrap: break-word;
    padding: 0px 20px;
}
</style>