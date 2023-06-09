import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";
import { expect } from "chai";
import { describe, before, beforeEach, it } from "mocha";

describe("PricingDutchAuction", () => {
  let pricingDutchAuction: Contract;
  let adminRole: string;
  let fxHashAdminRole: string;
  let signer: Signer;

  before(async () => {
    const PricingDutchAuction = await ethers.getContractFactory(
      "PricingDutchAuction"
    );
    pricingDutchAuction = await PricingDutchAuction.deploy();
    await pricingDutchAuction.deployed();

    const [deployer] = await ethers.getSigners();
    signer = deployer;

    fxHashAdminRole = ethers.utils.id("FXHASH_ADMIN");
  });

  beforeEach(async () => {
    await pricingDutchAuction.grantAdminRole(await signer.getAddress());
    await pricingDutchAuction.grantFxHashAdminRole(await signer.getAddress());
    await pricingDutchAuction.updateMinDecrementDuration(60); // Reset minDecrementDuration
  });

  it("should set the price correctly", async () => {
    const issuerId = 1;
    const opensAt = Math.floor(Date.now() / 1000) + 60; // Current timestamp + 60 seconds
    const decrementDuration = 60;
    const levels = [100, 90, 80, 70, 60];

    const details = ethers.utils.defaultAbiCoder.encode(
      ["tuple(uint256,uint256,uint256,uint256[])"],
      [[opensAt, decrementDuration, 0, levels]]
    );

    await pricingDutchAuction.setPrice(issuerId, details);
    //Fetch stored levels
    const storedLevels = await pricingDutchAuction.getLevels(issuerId);
    // Verify the stored price
    const storedDetails = await pricingDutchAuction.pricings(issuerId);
    expect(storedDetails.opensAt).to.equal(opensAt);
    expect(storedDetails.decrementDuration).to.equal(decrementDuration);
    expect(storedDetails.lockedPrice).to.equal(0);
    expect(storedLevels).to.deep.equal(levels);
  });

  it("should revert when setting price with invalid details", async () => {
    const issuerId = 1;
    const opensAt = Math.floor(Date.now() / 1000) + 60; // Current timestamp + 60 seconds
    const decrementDuration = 60;

    // Setting invalid details with incorrect level order
    const invalidLevels = [100, 90, 80, 100, 60];

    const invalidDetails = ethers.utils.defaultAbiCoder.encode(
      ["tuple(uint256,uint256,uint256,uint256[])"],
      [[opensAt, decrementDuration, 0, invalidLevels]]
    );

    await expect(
      pricingDutchAuction.setPrice(issuerId, invalidDetails)
    ).to.be.revertedWith("PRICES_MUST_DECREMENT");
  });

  it("should lock the price", async () => {
    const issuerId = 1;
    const opensAt = Math.floor(Date.now() / 1000) + 60; // Current timestamp + 60 seconds
    const decrementDuration = 60;
    const levels = [100, 90, 80, 70, 60];

    const details = ethers.utils.defaultAbiCoder.encode(
      ["tuple(uint256,uint256,uint256,uint256[])"],
      [[opensAt, decrementDuration, 0, levels]]
    );

    await pricingDutchAuction.setPrice(issuerId, details);
    await pricingDutchAuction.lockPrice(issuerId);

    // Fetch the storage and verify the locked price
    const storedDetails = await pricingDutchAuction.pricings(issuerId);
    expect(storedDetails.lockedPrice).to.equal(levels[0]);
  });

  it("should revert when getting price before it opens", async () => {
    const issuerId = 1;
    const opensAt = Math.floor(Date.now() / 1000) + 60; // Current timestamp + 60 seconds
    const decrementDuration = 60;
    const levels = [100, 90, 80, 70, 60];

    const details = ethers.utils.defaultAbiCoder.encode(
      ["tuple(uint256,uint256,uint256,uint256[])"],
      [[opensAt, decrementDuration, 0, levels]]
    );

    await pricingDutchAuction.setPrice(issuerId, details);

    const timestamp = Math.floor(Date.now() / 1000);

    await expect(
      pricingDutchAuction.getPrice(issuerId, timestamp)
    ).to.be.revertedWith("NOT_OPENED_YET");
  });

  it("should update the minDecrementDuration", async () => {
    const newMinDecrementDuration = 120;

    await pricingDutchAuction.updateMinDecrementDuration(
      newMinDecrementDuration
    );

    const retrievedMinDecrementDuration =
      await pricingDutchAuction.minDecrementDuration();
    expect(retrievedMinDecrementDuration).to.equal(newMinDecrementDuration);
  });
});
