<template>
    <section class="wallet-main container hero is-medium">
        <!-- create wallet if not have  -->
        <div class="wallet-nav">
            <b-dropdown aria-role="list">
                <b-icon icon="ellipsis-v" slot="trigger">
                </b-icon>

                <b-dropdown-item aria-role="listitem">
                    <b-icon icon="file-export" />
                    Backup
                </b-dropdown-item>
            </b-dropdown>
        </div>
        <div class="wallet-body">
            <div class="wallet-username">
                @apemon
            </div>
            <div class="wallet-balance">
                <span>{{balance | toDecimal}} TCC</span>
            </div>
            <div class="button-group">
                <b-button class="wallet-button" size="is-medium"
                    icon-left="paper-plane"
                    @click="send">
                    Send
                </b-button>
                <b-button class="wallet-button" size="is-medium"
                    icon-left="qrcode"
                    @click="receive">
                    Receive
                </b-button>
                <b-button class="wallet-button" size="is-medium"
                    icon-left="history">
                    Transactions
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
        toDecimal (value) {
            return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        }
    },
    data() {
        return {
            balance: 0
        }
    },
    async mounted() {
        this.walletService = new WalletService()
        try {
            await this.walletService.init('https://192.168.1.37:3000')
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
        receive() {
            this.$router.push({name: 'receive'})
        },
        send() {
            this.$router.push({name: 'send'})
        }
    }
}
</script>

<style lang="css" scoped>
.wallet-username {
    font-size: 32px;
}
.wallet-balance {
    font-size: 40px;
}
</style>