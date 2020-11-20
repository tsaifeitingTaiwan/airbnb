const ConvertLib = artifacts.require("ConvertLib");

const airbnb = artifacts.require("airbnb");

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, airbnb);
  deployer.deploy(airbnb);
};
