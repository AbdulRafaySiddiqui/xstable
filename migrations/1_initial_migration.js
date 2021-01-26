const Migrations = artifacts.require("Migrations");
var xst = artifacts.require("XStable");

module.exports = function (deployer) {
  deployer.deploy(xst);
};
