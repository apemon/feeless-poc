var Wallet = artifacts.require("./Wallet");

module.exports = function(deployer, network, accounts) {
    const address = accounts[0]
    deployer.deploy(Wallet, address);
}