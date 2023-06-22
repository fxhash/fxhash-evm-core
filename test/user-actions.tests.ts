import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract } from "ethers";

describe("UserActions", function () {
  let UserActions: Contract;
  let accounts: any;

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    const UserActionsFactory = await ethers.getContractFactory("UserActions");
    UserActions = await UserActionsFactory.deploy();
  });

  describe("getUserActions", function () {
    it("Should return the default values for a new user", async function () {
      const userActions = await UserActions.getUserActions(accounts[1].address);
      expect(userActions.lastIssuerMinted).to.equal(0);
      expect(userActions.lastIssuerMintedTime).to.equal(0);
      expect(userActions.lastMinted.length).to.equal(0);
      expect(userActions.lastMintedTime).to.equal(0);
    });

    // Add more test cases to cover other scenarios
  });

  describe("setLastIssuerMinted", function () {
    it("Should correctly set the last issuer minted and the timestamp", async function () {
      await UserActions.setLastIssuerMinted(accounts[1].address, 1);
      const userActions = await UserActions.getUserActions(accounts[1].address);
      expect(userActions.lastIssuerMinted).to.equal(1);
      expect(userActions.lastIssuerMintedTime).to.be.above(0);
    });

    // Add more test cases to cover other scenarios
  });

  describe("setLastMinted", function () {
    it("Should correctly set the last minted tokenId and the timestamp", async function () {
      await UserActions.setLastMinted(accounts[1].address, 100);
      const userActions = await UserActions.getUserActions(accounts[1].address);
      expect(userActions.lastMinted[0]).to.equal(100);
      expect(userActions.lastMintedTime).to.be.above(0);
    });

    // Add more test cases to cover other scenarios
  });

  describe("resetLastIssuerMinted", function () {
    it("Should reset lastIssuerMintedTime if the issuerId matches the last minted one", async function () {
      await UserActions.setLastIssuerMinted(accounts[1].address, 1);
      await UserActions.resetLastIssuerMinted(accounts[1].address, 1);
      const userActions = await UserActions.getUserActions(accounts[1].address);
      expect(userActions.lastIssuerMintedTime).to.equal(0);
    });

    it("Should not reset lastIssuerMintedTime if the issuerId does not match the last minted one", async function () {
      await UserActions.setLastIssuerMinted(accounts[1].address, 1);
      await UserActions.resetLastIssuerMinted(accounts[1].address, 2);
      const userActions = await UserActions.getUserActions(accounts[1].address);
      expect(userActions.lastIssuerMintedTime).to.be.above(0);
    });
  });
});
