import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract, Signer } from "ethers";

describe("ConfigurationManager", function () {
  let configurationManager: Contract;
  let owner: Signer;
  let addr1: Signer;
  let addr2: Signer;

  before(async function () {
    // Get the ContractFactory and Signers here.
    const ConfigurationManager = await ethers.getContractFactory(
      "ConfigurationManager"
    );
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy the contract and wait for it to be mined
    configurationManager = await ConfigurationManager.deploy();
    await configurationManager.deployed();
  });

  describe("setConfig", function () {
    it("should set the configuration successfully", async function () {
      const config = {
        fees: 10,
        referrerFeesShare: 20,
        lockTime: 100,
        voidMetadata: "some metadata",
      };
      await configurationManager.connect(owner).setConfig(config);

      const actualConfig = await configurationManager.getConfig();
      expect(actualConfig.fees).to.equal(config.fees);
      expect(actualConfig.referrerFeesShare).to.equal(config.referrerFeesShare);
      expect(actualConfig.lockTime).to.equal(config.lockTime);
      expect(actualConfig.voidMetadata).to.equal(config.voidMetadata);
    });

    it("should revert if not owner", async function () {
      const config = {
        fees: 10,
        referrerFeesShare: 20,
        lockTime: 100,
        voidMetadata: "some metadata",
      };
      await expect(
        configurationManager.connect(addr2).setConfig(config)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });
  });

  describe("setAddress", function () {
    it("should set addresses correctly", async function () {
      const entries = [
        { key: "ContractA", value: await addr1.getAddress() },
        { key: "ContractB", value: await addr2.getAddress() },
      ];

      await configurationManager.connect(owner).setAddress(entries);
      expect(await configurationManager.getAddress("ContractA")).to.equal(
        await addr1.getAddress()
      );
      expect(await configurationManager.getAddress("ContractB")).to.equal(
        await addr2.getAddress()
      );
    });

    it("should revert if not owner", async function () {
      const entries = [
        { key: "ContractA", value: await addr1.getAddress() },
        { key: "ContractB", value: await addr2.getAddress() },
      ];
      await expect(
        configurationManager.connect(addr1).setAddress(entries)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("should revert if address is null", async function () {
      const entries = [
        { key: "ContractA", value: ethers.constants.AddressZero },
      ];
      await expect(
        configurationManager.connect(owner).setAddress(entries)
      ).to.be.revertedWith("Address is null");
    });
  });
});
