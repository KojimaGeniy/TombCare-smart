var TombCare = artifacts.require("./TombCareCore");
var TestToken = artifacts.require("./TestToken");
var TestSuka = artifacts.require("./TestSuka");

module.exports = function(deployer) {
  deployer.deploy(TestToken).then(function() {
    return deployer.deploy(TombCare,TestToken.address);
  });
  //deployer.deploy(TestSuka);
};
