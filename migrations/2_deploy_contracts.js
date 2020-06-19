//var Migrations = artifacts.require("./Migrations.sol");
var Financial_forensics = artifacts.require("./Financial_forensics.sol");
//represents contract abstraction

module.exports = function(deployer) {
 // deployer.deploy(Migrations);
  deployer.deploy(Financial_forensics);
};
