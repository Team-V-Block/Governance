const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe("Governance Contract", function () {
  let Governance, owner, addr1, addr2;

  // Get the contract, signers and deploy before each test
  beforeEach(async function () {
    Governance = await ethers.getContractFactory("Governance");
    [owner, addr1, addr2] = await ethers.getSigners();

    Govern = await Governance.deploy();

    await Govern.deployed();
  });

  describe("Deployment", function () {
    it("Grants the deploying address a chairman role by default", async function () {
      expect(await Govern.getRole(owner.address)).to.equal(await Govern.CHAIRMAN_ROLE());
    });
  });

  describe("Chairman Role", function () {
    it("Grants an address a student role", async function () {
      // Grant addr a shareholder role of student
      let studentRole = await Govern.STUDENT_ROLE();
      await Govern.grantRole(studentRole, addr1.address);
      expect(await Govern.getRole(addr1.address)).to.equal(studentRole);
    });
    it("Grants an address a teacher role", async function () {
      // Grant addr a shareholder role of teacher
      let teacherRole = await Govern.TEACHER_ROLE();
      await Govern.grantRole(teacherRole, addr2.address);
      expect(await Govern.getRole(addr2.address)).to.equal(teacherRole);
    });
  });

  describe("Voting", function () {
    it ("Should be able to change voting allowed status", async function (){
      //Change voting status
      await Govern.changeVotingAllowed(false);

      expect(await Govern.votingAllowed()).to.equal(false);
    });
    it("Voting results should not return empty", async function () {

      // Add candidates
      await Govern.addCandidates(["Ben", "Ban", "Bin", "Bon"]);
      
      // Vote for a shareholder
      await Govern.vote(1);
      
      expect(await Govern.votingResult()).not.empty
    });
    it("should allow shareholders to vote if true", async function () {
      // Will pass if votingAllowed is set to true
      assert.equal(await Govern.votingAllowed(), true, "Voting is allowed");

      // Grant second addr a shareholder role e.g. studentRole so they can vote
      let studentRole = await Govern.STUDENT_ROLE();
      await Govern.grantRole(studentRole, addr1.address);

      // Shareholder adds Candidates
      await Govern.addCandidates(["Ben", "Ban", "Bin", "Bon"]);

      // First Shareholder votes
      await Govern.vote(2);

      // Second Shareholder votes
      await Govern.connect(addr1).vote(2);

      // Expected vote count for Candidate with index 2, "Bin" is 2
      expect(await Govern.getVoteCount(2)).to.equal(2);
    });
    it ("Should be able to change voting result privacy", async function (){
      //Change voting status
      await Govern.changeResultStatus(true);

      expect(await Govern.resultPublic()).to.equal(true);
    });
  });
});
