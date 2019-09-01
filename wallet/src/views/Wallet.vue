<template>
    <section class="wallet-main container hero is-medium">
        <!-- create wallet if not have  -->
        <div class="wallet-body">
            <div class="wallet-username">
                @apemon
            </div>
            <div class="wallet-balance">
                <span>{{balance | toDecimal}} TCC</span>
            </div>
            <div class="button-group">
                <b-button class="wallet-button" size="is-medium"
                    icon-left="paper-plane">
                    Send
                </b-button>
                <b-button class="wallet-button" size="is-medium"
                    icon-left="qrcode">
                    Receive
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

<style lang="css" scoped>
.wallet-main {
    width: 100%;
    background-color: #536dfe;
    color: white;
}
.wallet-body {
    padding-bottom: 2rem;
    padding-top: 2rem;
}
.wallet-username {
    font-size: 32px;
}
.wallet-balance {
    font-size: 40px;
}
.button-group {
    margin: 40px 20px 20px 20px;
}
.wallet-button {
    width: 100%;
    height: 60px;
    margin-bottom: 20px;
}

@media only screen and (min-width: 1025px) {
    .wallet-main {
        width:70%;
        background-color: #536dfe;
        color: white;
    }
    .wallet-body {
        padding-bottom: 6rem;
        padding-top: 6rem;
    }
    .button-group {
        margin-top: 40px;
    }
    .wallet-button {
        min-width: 150px;
        max-width: 100%;
        margin: 0px 20px;
        text-align: center;
        height: 50px;
    }
}
</style>