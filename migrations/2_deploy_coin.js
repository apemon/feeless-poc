var TCCoin = artifacts.require("./TCCoin");

module.exports = function(deployer, network, accounts) {
    deployer.deploy(TCCoin, "TCCoin", "TC", 0);
}