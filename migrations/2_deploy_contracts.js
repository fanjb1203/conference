var Conference = artifacts.require("./Conference.sol");
var Decode = artifacts.require("./Decode.sol");
module.exports = function(deployer) {
  deployer.deploy(Conference);
  deployer.deploy(Decode);
};

