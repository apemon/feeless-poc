var JunkCoin = artifacts.require("./JunkCoin");

module.exports = function(deployer, network, accounts) {
    deployer.deploy(JunkCoin, "JunkCoin", "JUNK", 0);
}