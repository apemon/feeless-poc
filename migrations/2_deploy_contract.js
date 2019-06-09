var JunkCoin = artifacts.require("./JunkCoin");

module.exports = function(deployer) {
    deployer.deploy(JunkCoin, "JunkCoin", "JUNK", 0);
}