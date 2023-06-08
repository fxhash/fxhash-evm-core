import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { solidityKeccak256 } from "ethers/lib/utils";

// Define the Hardhat network provider settings
const provider = new ethers.providers.JsonRpcProvider({
  url: "http://localhost:8545", // The RPC endpoint of your Hardhat network
});

// Create and connect the wallets
const admin = new ethers.Wallet(
  "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
).connect(provider);
const fxHashAdmin = new ethers.Wallet(
  "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"
).connect(provider);
const user1 = new ethers.Wallet(
  "0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a"
).connect(provider);
const user2 = new ethers.Wallet(
  "0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6"
).connect(provider);

describe("MintPassGroup", function () {
  let MintPassGroup: any;
  let mintPassGroup: any;

  before(async function () {
    // Deploy the MintPassGroup contract
    MintPassGroup = await ethers.getContractFactory("MintPassGroup");
  });

  beforeEach(async function () {
    await ethers.provider.send("hardhat_reset", []);
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
      const addr = user1.address;
      // Create a valid pass
      // The payload structure should be defined based on how it's used in the contract.
      const payload = ethers.utils.defaultAbiCoder.encode(
        ["tuple(string,uint256,address)"],
        [[token, project, addr]]
      );
      const signature = await fxHashAdmin.signMessage(
        ethers.utils.arrayify(payload)
      );

      // Create the Pass object
      const pass = { payload: payload, signature: signature };
      console.log("client side payload = " + payload);
      console.log("client side signer = ", fxHashAdmin.address);
      console.log("client side signature = ", signature);

      // Consume the pass
      await mintPassGroup.connect(user1).consumePass(pass);
      const t = await mintPassGroup.tokens(token);

      // Assert the state changes
      expect(t).to.deep.equal([
        ethers.BigNumber.from("1"), // minted
        ethers.BigNumber.from(await ethers.provider.getBlockNumber()), // levelConsumed
        addr, // consumer
        { "1": ethers.BigNumber.from("1") }, // projects
      ]);
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
