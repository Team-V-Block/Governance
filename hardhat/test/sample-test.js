const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Governance Contract", function () {
  let Governance, owner, addr1, addr2;

  // This will run before each test
  beforeEach(async function () {
    Governance = await ethers.getContractFactory("Governance");
    [owner] = await ethers.getSigners();

    Govern = await Governance.deploy();

    await Govern.deployed();
  });

  describe("Deployment", function () {
    it("Should get the Chairman Role as deployer address", async function () {
      expect(await Govern.getRoleChairman()).to.equal(owner.address);
    });
  });
});
