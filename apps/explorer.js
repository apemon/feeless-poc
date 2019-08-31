const axios = require('axios')

var Explorer = {
    getNonceFromExplorer: getNonceFromExplorer
}

async function getNonceFromExplorer(network, address, apiKey) {
    try {
        if(network == 'kovan') {
            let path = 'http://api-kovan.etherscan.io/api?module=account&action=txlist&address='+ address +'&startblock=0&apikey=' + apiKey
            let response = await axios.get(path)
            return response.data.result.length
        } else if(network == 'thaichain') {
            let path = 'https://exp.tch.in.th/api/address/' + address
            let response = await axios.get(path)
            return response.data['number_of_transactions']
        }
    } catch (err) {
        console.log(err)
        throw err
    }
}

module.exports = Explorer