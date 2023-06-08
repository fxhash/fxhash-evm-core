import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { solidityKeccak256 } from "ethers/lib/utils";

describe("MintPassGroup", function () {
  let MintPassGroup: any;
  let mintPassGroup: any;
  let admin: SignerWithAddress;
  let fxHashAdmin: SignerWithAddress;
  let user1: SignerWithAddress;
  let user2: SignerWithAddress;

  before(async function () {
    // Deploy the MintPassGroup contract
    MintPassGroup = await ethers.getContractFactory("MintPassGroup");
    [admin, fxHashAdmin, user1, user2] = await ethers.getSigners();
  });

  beforeEach(async function () {
    mintPassGroup = await MintPassGroup.deploy(
      10, // maxPerToken
      5, // maxPerTokenPerProject
      fxHashAdmin.address, // publicKey
      []
    );
  });

  describe("consumePass", function () {
    it("should consume a valid pass", async function () {
      const token = "TOKEN1";
      const project = 1;
      const addr = fxHashAdmin.address;
      // Create a valid pass
      // The payload structure should be defined based on how it's used in the contract.
      const payload = ethers.utils.defaultAbiCoder.encode(
        ["tuple(string,uint256,address)"],
        [["token", 1, user1.address]]
      );

      const payloadHash = ethers.utils.hashMessage(payload);
      const signature = await fxHashAdmin.signMessage(
        ethers.utils.arrayify(payloadHash)
      );

      // Create the Pass object
      const pass = { payload: payload, signature: signature };
      console.log("payloadhash = " + payloadHash);
      console.log("address = ", fxHashAdmin.address);

      // Consume the pass
      await mintPassGroup.connect(user1).consumePass(pass);

      // Assert the state changes
      expect(await mintPassGroup.tokens("token")).to.deep.equal({
        minted: 1,
        projects: {
          "1": 1,
        },
        levelConsumed: await ethers.provider.getBlockNumber(),
        consumer: user1.address,
      });
    });

    it("should revert when consuming an invalid pass", async function () {
      // Create an invalid pass
      const payload = ethers.utils.defaultAbiCoder.encode(
        ["Payload(string,uint256,address)"],
        [["token", 1, user1.address]]
      );
      const invalidSignature = "0x...";
      const pass = { payload, invalidSignature };

      // Try to consume the pass and expect a revert
      await expect(
        mintPassGroup.connect(user1).consumePass(pass)
      ).to.be.revertedWith("PASS_INVALID_SIGNATURE");
    });
  });

  describe("setConstraints", function () {
    it("should update the constraints by fxHashAdmin", async function () {
      // Set the constraints
      await mintPassGroup.connect(fxHashAdmin).setConstraints(20, 10);

      // Assert the updated constraints
      expect(await mintPassGroup.maxPerToken()).to.equal(20);
      expect(await mintPassGroup.maxPerTokenPerProject()).to.equal(10);
    });

    it("should revert when updating the constraints by non-fxHashAdmin", async function () {
      // Try to set the constraints and expect a revert
      await expect(
        mintPassGroup.connect(admin).setConstraints(20, 10)
      ).to.be.revertedWith("Caller is not a FxHash admin");
    });
  });

  describe("setBypass", function () {
    it("should update the bypass list by fxHashAdmin", async function () {
      // Set the bypass list
      await mintPassGroup
        .connect(fxHashAdmin)
        .setBypass([user1.address, user2.address]);

      // Assert the updated bypass list
      expect(await mintPassGroup.bypass(0)).to.equal(user1.address);
      expect(await mintPassGroup.bypass(1)).to.equal(user2.address);
    });

    it("should revert when updating the bypass list by non-fxHashAdmin", async function () {
      // Try to set the bypass list and expect a revert
      await expect(
        mintPassGroup.connect(admin).setBypass([user1.address, user2.address])
      ).to.be.revertedWith("Caller is not a FxHash admin");
    });
  });

  describe("isPassValid", function () {
    it("should return true for a valid pass", async function () {
      // Create a valid pass
      const payload = ethers.utils.defaultAbiCoder.encode(
        ["tuple(string,uint256,address)"],
        [["token", 1, user1.address]]
      );
      const payloadHash = solidityKeccak256(["bytes"], [payload]);
      const signature = await fxHashAdmin.signMessage(payloadHash);
      const pass = { payload, signature };

      // Check if the pass is valid
      const isValid = await mintPassGroup.isPassValid(pass);

      // Assert the result
      expect(isValid).to.be.true;
    });

    it("should return false for an invalid pass", async function () {
      // Create an invalid pass
      const payload = ethers.utils.defaultAbiCoder.encode(
        ["tuple(string,uint256,address)"],
        [["token", 1, user1.address]]
      );
      const invalidSignature = "0x...";
      const pass = { payload, invalidSignature };

      // Check if the pass is valid
      const isValid = await mintPassGroup.isPassValid(pass);

      // Assert the result
      expect(isValid).to.be.false;
    });
  });
});
