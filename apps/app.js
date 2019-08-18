const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const Web3 = require('web3');

require('dotenv').config();

const app = express();

app.use(bodyParser.json());
app.use(cors());

app.listen(3000, () => {

});

app.get('/info', (req,res) => {
    var info = {
        web3Address: process.env.web3Address,
        factoryAddress: process.env.factoryAddress,
        didRegistryAddress: process.env.didRegistryAddress,
        tokenAddress: process.env.tokenAddress
    }
    return res.send(info);
});