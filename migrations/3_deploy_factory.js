var Factory = artifacts.require("./Factory");

module.exports = function(deployer, network, accounts) {
    const address = accounts[0]
    deployer.deploy(Factory, address);
}