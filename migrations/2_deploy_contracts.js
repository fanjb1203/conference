var Conference = artifacts.require("./Conference.sol");
var Decode = artifacts.require("./Decode.sol");
var SmartSponsor = artifacts.require("./SmartSponsor.sol");
var Ballot = artifacts.require("./Ballot.sol");
module.exports = function(deployer) {
  deployer.deploy(Conference);
  deployer.deploy(Decode);
  deployer.deploy(SmartSponsor);
  deployer.deploy(Ballot);
};

