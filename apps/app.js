const express = require('express');
const Web3 = require('web3');
const TokenContractSource = require('./../build/contracts/JunkCoin.json');

const web3 = new Web3('http://localhost:7545');

let TokenAddress = TokenContractSource.networks['5777'].address;
let instance = new web3.eth.Contract(TokenContractSource.abi, TokenAddress);

const app = express();
app.listen(3000, () => {

});

app.get('/balance/:addr', async(req,res) => {
    let balance = await instance.methods.balanceOf(req.params.addr).call();
    return res.send(balance);
});