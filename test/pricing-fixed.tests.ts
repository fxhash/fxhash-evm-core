import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";
import { expect } from "chai";
import { describe, before, beforeEach, it } from "mocha";

describe("PricingFixed", () => {
  let pricingFixed: Contract;
  let adminRole: string;
  let fxHashAdminRole: string;
  let signer: Signer;

  before(async () => {
    const PricingFixed = await ethers.getContractFactory("PricingFixed");
    pricingFixed = await PricingFixed.deploy();
    await pricingFixed.deployed();

    const [deployer] = await ethers.getSigners();
    signer = deployer;

    fxHashAdminRole = ethers.utils.id("AUTHORIZED_CALLER");
  });

  beforeEach(async () => {
    // Reset the contract state before each test
    await pricingFixed.grantAdminRole(await signer.getAddress());
    await pricingFixed.authorizeCaller(await signer.getAddress());
  });

  it("should set and get the price", async () => {
    const issuerId = await signer.getAddress();
    const price = 100;
    const opensAt = Math.floor(Date.now() / 1000) - 100; // Current timestamp - 100 seconds

    await pricingFixed.setPrice(
      issuerId,
      ethers.utils.defaultAbiCoder.encode(
        ["uint256", "uint256"],
        [price, opensAt]
      )
    );

    const retrievedPrice = await pricingFixed.getPrice(issuerId, opensAt);
    expect(retrievedPrice).to.equal(price);
  });

  it("should revert when setting price with invalid details", async () => {
    const issuerId = await signer.getAddress();
    const price = 0;
    const opensAt = 2;

    await expect(
      pricingFixed.setPrice(
        issuerId,
        ethers.utils.defaultAbiCoder.encode(
          ["uint256", "uint256"],
          [price, opensAt]
        )
      )
    ).to.be.revertedWith("price <= 0");
  });

  it("should revert when getting price for non-existent issuer", async () => {
    const issuerId = ethers.constants.AddressZero;
    const timestamp = Math.floor(Date.now() / 1000);

    await expect(pricingFixed.getPrice(issuerId, timestamp)).to.be.revertedWith(
      "PRICING_NO_ISSUER"
    );
  });

  it("should revert when getting price before it opens", async () => {
    const issuerId = await signer.getAddress();
    const price = 100;
    const opensAt = Math.floor(Date.now() / 1000) + 100; // Current timestamp + 100 seconds

    await pricingFixed.setPrice(
      issuerId,
      ethers.utils.defaultAbiCoder.encode(
        ["uint256", "uint256"],
        [price, opensAt]
      )
    );

    const timestamp = Math.floor(Date.now() / 1000);

    await expect(pricingFixed.getPrice(issuerId, timestamp)).to.be.revertedWith(
      "NOT_OPENED_YET"
    );
  });
});
