import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract, Signer } from "ethers";

describe("PricingManager", function () {
  let PricingManager: Contract;
  let pricingFixed: Contract;
  let admin: Signer;

  beforeEach(async () => {
    [admin] = await ethers.getSigners();
    const PricingManagerFactory = await ethers.getContractFactory(
      "PricingManager"
    );
    const PricingFixed = await ethers.getContractFactory("PricingFixed");
    pricingFixed = await PricingFixed.deploy();
    await pricingFixed.deployed();
    PricingManager = await PricingManagerFactory.deploy(
      await admin.getAddress()
    );
    PricingManager.authorizeCaller(await admin.getAddress());
  });

  describe("setPricingContract", function () {
    it("Should correctly set a pricing contract", async function () {
      await PricingManager.setPricingContract(1, pricingFixed.address, true);

      const result = await PricingManager.getPricingContract(1);

      expect(result.pricingContract).to.equal(pricingFixed.address);
      expect(result.enabled).to.equal(true);
    });

    // Add more test cases to cover other scenarios
  });

  describe("verifyPricingMethod", function () {
    it("Should throw an error if the pricing contract does not exist", async function () {
      await expect(PricingManager.verifyPricingMethod(1)).to.be.revertedWith(
        "PRC_MTD_NOT"
      );
    });

    it("Should throw an error if the pricing contract is disabled", async function () {
      await PricingManager.setPricingContract(1, pricingFixed.address, false);

      await expect(PricingManager.verifyPricingMethod(1)).to.be.revertedWith(
        "PRC_MTD_DIS"
      );
    });

    // Add more test cases to cover other scenarios
  });

  describe("getPricingContract", function () {
    it("Should return a pricing contract", async function () {
      await PricingManager.setPricingContract(1, pricingFixed.address, true);

      const result = await PricingManager.getPricingContract(1);

      expect(result.pricingContract).to.equal(pricingFixed.address);
      expect(result.enabled).to.equal(true);
    });

    // Add more test cases to cover other scenarios
  });
});
