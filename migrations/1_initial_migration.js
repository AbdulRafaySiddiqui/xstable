var liquidity = artifacts.require("Liquidity");
var xst = artifacts.require("XStable");
var stabilizer = artifacts.require("Stabilizer");
var presale = artifacts.require("Presale");

module.exports = function (deployer) {
  var xstContract, liquidityContract, stabilizerContract;

  deployer.deploy(xst).then(instance => {
    xstContract = instance;
    return deployer.deploy(liquidity, xstContract.address).then(instance => {
      liquidityContract = instance;
      return deployer.deploy(stabilizer).then(instance => {
        stabilizerContract = instance;
        return deployer.deploy(presale, xstContract.address).then(instance => {
          xstContract.setLiquidityReserve(liquidityContract);
          xstContract.setStabilizer(stabilizer);
          xstContract.setPresale(instance);
        });
      });
    });
  });

};
