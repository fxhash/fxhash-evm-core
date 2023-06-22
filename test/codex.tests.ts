import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract } from "ethers";

describe("Codex", function () {
  let Codex: Contract;
  let accounts: any;

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    const CodexFactory = await ethers.getContractFactory("Codex");
    Codex = await CodexFactory.deploy(accounts[1].address, accounts[2].address);
  });

  describe("codexEntryIdFromInput", function () {
    it("Should throw an error if codexId > 0 but there is no author for that codexId", async function () {
      const codexInput = {
        inputType: 1,
        value: ethers.utils.formatBytes32String("Test"),
        codexId: 1,
      };
      await expect(
        Codex.codexEntryIdFromInput(accounts[0].address, codexInput)
      ).to.be.revertedWith("CDX_EMPTY");
    });

    // Add more test cases to cover other scenarios
  });

  describe("codexAddEntry", function () {
    it("Should add an entry to codexEntries mapping", async function () {
      const value = [ethers.utils.formatBytes32String("Test")];
      await Codex.codexAddEntry(1, value);
      const newEntry = await Codex.codexEntries(0);
      expect(newEntry.entryType).to.equal(1);
      expect(newEntry.author).to.equal(accounts[0].address);
      expect(newEntry.locked).to.equal(true);
    });

    // Add more test cases to cover other scenarios
  });

  describe("codexLockEntry", function () {
    it("Should throw an error if an unauthorized user tries to lock an entry", async function () {
      const value = [ethers.utils.formatBytes32String("Test")];
      await Codex.connect(accounts[1]).codexAddEntry(1, value);
      await expect(Codex.codexLockEntry(0)).to.be.revertedWith("403");
    });

    // Add more test cases to cover other scenarios
  });

  describe("codexUpdateEntry", function () {
    it("Should throw an error if an unauthorized user tries to update an entry", async function () {
      const value = [ethers.utils.formatBytes32String("Test")];
      await Codex.connect(accounts[1]).codexAddEntry(1, value);
      await expect(
        Codex.codexUpdateEntry(
          0,
          true,
          ethers.utils.formatBytes32String("NewTest")
        )
      ).to.be.revertedWith("403");
    });

    it("Should throw an error if an entry is locked", async function () {
      const value = [ethers.utils.formatBytes32String("Test")];
      await Codex.codexAddEntry(1, value);
      await expect(
        Codex.codexUpdateEntry(
          0,
          true,
          ethers.utils.formatBytes32String("NewTest")
        )
      ).to.be.revertedWith("CDX_LOCK");
    });

    // Add more test cases to cover other scenarios
  });

  describe("updateIssuerCodexRequest", function () {
    it("Should throw an error if _issuerId is 0", async function () {
      const codexInput = {
        inputType: 1,
        value: ethers.utils.formatBytes32String("Test"),
        codexId: 0,
      };
      await expect(
        Codex.updateIssuerCodexRequest(0, codexInput)
      ).to.be.revertedWith("NO_ISSUER");
    });

    // You need to mock IIssuer contract to test other scenarios
  });

  describe("updateIssuerCodexApprove", function () {
    it("Should throw an error if issuerId is 0", async function () {
      await expect(Codex.updateIssuerCodexApprove(0, 1)).to.be.revertedWith(
        "NO_REQ"
      );
    });

    // You need to mock IModeration and IIssuer contracts to test other scenarios
  });
});
