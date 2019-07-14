var DidRegistry = artifacts.require("./DidRegistry");

module.exports = function(deployer) {
    deployer.deploy(DidRegistry);
}