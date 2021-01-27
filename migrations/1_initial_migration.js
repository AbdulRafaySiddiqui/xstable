var liquidity = artifacts.require("Liquidity");
var xst = artifacts.require("XStable");
var stabilizer = artifacts.require("Stabilizer");
var presale = artifacts.require("Presale");

module.exports = async (deployer) => {
  await deployer.deploy(xst);
  let xstContract = await xst.deployed();

  await deployer.deploy(liquidity, xstContract.address);
  let liquidityContract = await liquidity.deployed();

  await deployer.deploy(stabilizer);
  let stabilizerContract = await stabilizer.deployed();

  await deployer.deploy(presale, xstContract.address);
  let presaleContract = await presale.deployed();

  await xstContract.initialize();
  await xstContract.setPresale(presaleContract.address);
  await xstContract.setStabilizer(stabilizerContract.address);
  await xstContract.setLiquidityReserve(liquidityContract.address);
};