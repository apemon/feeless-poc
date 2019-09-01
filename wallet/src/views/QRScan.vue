<template>
    <section class="wallet-main container hero is-medium">
        <div class="wallet-qr">
            <qrcode-stream
                @init="onInit"
                @decode="onDecode"
          />
        </div>
        <div class="wallet-body">
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
import { QrcodeStream } from 'vue-qrcode-reader'

export default {
    components: {
        QrcodeStream
    },
    data() {
        return {
            qrCode: '',
            loading: false
        }
    },
    async mounted() {
        
    },
    methods: {
        async onInit(promise) {
            this.loading = true
            try {
                await promise
                this.loading = false
            } catch (err) {
                this.$buefy.toast.open({
                    message: err,
                    type: 'is-danger'
                })
                this.loading = false
            }
        },
        onDecode(data) {
            if(data.length == 42) {
                this.$router.push({
                    name:'send',
                    query: {
                        dest: data
                    } 
                })
            } else if (data[0] == '{'){

            } else {
                this.$buefy.toast.open({
                    message: 'unrecognize qr',
                    type: 'is-danger'
                })
            }
        },
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
</style>