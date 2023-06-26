import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract, Signer } from "ethers";

describe("UserActions", function () {
  let UserActions: Contract;
  let admin: Signer;

  beforeEach(async () => {
    [admin] = await ethers.getSigners();
    const UserActionsFactory = await ethers.getContractFactory("UserActions");
    UserActions = await UserActionsFactory.deploy(await admin.getAddress());
    await UserActions.authorizeCaller(await admin.getAddress());
  });

  describe("getUserActions", function () {
    it("Should return the default values for a new user", async function () {
      const userActions = await UserActions.getUserActions(
        await admin.getAddress()
      );
      expect(userActions.lastIssuerMinted).to.equal(0);
      expect(userActions.lastIssuerMintedTime).to.equal(0);
      expect(userActions.lastMinted.length).to.equal(0);
      expect(userActions.lastMintedTime).to.equal(0);
    });

    // Add more test cases to cover other scenarios
  });

  describe("setLastIssuerMinted", function () {
    it("Should correctly set the last issuer minted and the timestamp", async function () {
      await UserActions.setLastIssuerMinted(await admin.getAddress(), 1);
      const userActions = await UserActions.getUserActions(
        await admin.getAddress()
      );
      expect(userActions.lastIssuerMinted).to.equal(1);
      expect(userActions.lastIssuerMintedTime).to.be.above(0);
    });

    // Add more test cases to cover other scenarios
  });

  describe("setLastMinted", function () {
    it("Should correctly set the last minted tokenId and the timestamp", async function () {
      await UserActions.setLastMinted(await admin.getAddress(), 100);
      const userActions = await UserActions.getUserActions(
        await admin.getAddress()
      );
      expect(userActions.lastMinted[0]).to.equal(100);
      expect(userActions.lastMintedTime).to.be.above(0);
    });

    // Add more test cases to cover other scenarios
  });

  describe("resetLastIssuerMinted", function () {
    it("Should reset lastIssuerMintedTime if the issuerId matches the last minted one", async function () {
      await UserActions.setLastIssuerMinted(await admin.getAddress(), 1);
      await UserActions.resetLastIssuerMinted(await admin.getAddress(), 1);
      const userActions = await UserActions.getUserActions(
        await admin.getAddress()
      );
      expect(userActions.lastIssuerMintedTime).to.equal(0);
    });

    it("Should not reset lastIssuerMintedTime if the issuerId does not match the last minted one", async function () {
      await UserActions.setLastIssuerMinted(await admin.getAddress(), 1);
      await UserActions.resetLastIssuerMinted(await admin.getAddress(), 2);
      const userActions = await UserActions.getUserActions(
        await admin.getAddress()
      );
      expect(userActions.lastIssuerMintedTime).to.be.above(0);
    });
  });
});
