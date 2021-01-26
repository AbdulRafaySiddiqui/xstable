const Migrations = artifacts.require("Migrations");
var xst = artifacts.require("XST.sol");

module.exports = function (deployer) {
  deployer.deploy(xst);
};
