var Conference = artifacts.require("./Conference.sol");
var Decode = artifacts.require("./Decode.sol");
var SmartSponsor = artifacts.require("./SmartSponsor.sol");
module.exports = function(deployer) {
  deployer.deploy(Conference);
  deployer.deploy(Decode);
  deployer.deploy(SmartSponsor);
};

