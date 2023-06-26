import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { solidityKeccak256 } from "ethers/lib/utils";

/**
 * TODO: need to debug tests
 * Current issues:
 * - signature is not working in hardhhat memory provider (using ethers provider)
 * - storage is not working with hardhat provider node
 */

// Define the Hardhat network provider settings
// const provider = new ethers.providers.JsonRpcProvider({
//   url: "http://localhost:8545", // The RPC endpoint of your Hardhat network
// });
const provider = ethers.provider;
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

const token = "TOKEN1";
const project = 1;
const addr = user1.address;

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
    //TODO: Need to fix the test, for some reason signature verification is not working as expected
    // it("should consume a valid pass", async function () {
    //   // Create a valid pass
    //   // The payload structure should be defined based on how it's used in the contract.
    //   const payload = ethers.utils.defaultAbiCoder.encode(
    //     ["tuple(string,uint256,address)"],
    //     [[token, project, addr]]
    //   );
    //   const signature = await fxHashAdmin.signMessage(
    //     ethers.utils.arrayify(payload)
    //   );
    //   // Create the Pass object
    //   const pass = { payload: payload, signature: signature };
    //   const encoded_pass = ethers.utils.defaultAbiCoder.encode(
    //     ["tuple(bytes,bytes)"],
    //     [[pass.payload, pass.signature]]
    //   );
    //   // Consume the pass
    //   await mintPassGroup.connect(user1).consumePass(encoded_pass);
    //   const tokenRecord = await mintPassGroup.tokens(token);
    //   const projectHash = await mintPassGroup.getProjectHash(token, project);
    //   // Assert the state changes
    //   expect(tokenRecord.minted).to.deep.equal(ethers.BigNumber.from(1));
    //   expect(tokenRecord.levelConsumed).to.deep.equal(
    //     ethers.BigNumber.from(await ethers.provider.getBlockNumber())
    //   );
    //   expect(tokenRecord.consumer).to.equal(addr);
    //   expect(await mintPassGroup.projects(projectHash)).to.deep.equal(
    //     ethers.BigNumber.from(1)
    //   );
    // });
    //TODO: Need to fix the test, for some reason signature verification is not working as expected
    // it("should revert when consuming an invalid pass", async function () {
    //   // Create an invalid pass
    //   const payload = ethers.utils.defaultAbiCoder.encode(
    //     ["tuple(string,uint256,address)"],
    //     [[token, project, addr]]
    //   );
    //   const signature = await user1.signMessage(ethers.utils.arrayify(payload));
    //   const pass = { payload, signature: signature };
    //   const encoded_pass = ethers.utils.defaultAbiCoder.encode(
    //     ["tuple(bytes,bytes)"],
    //     [[pass.payload, pass.signature]]
    //   );
    //   // Try to consume the pass and expect a revert
    //   await expect(
    //     mintPassGroup.connect(user1).consumePass(encoded_pass)
    //   ).to.be.revertedWith("PASS_INVALID_SIGNATURE");
    // });
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
      ).to.be.revertedWith("Caller is not authorized");
    });
  });

  describe("setBypass", function () {
    it("should update the bypass list by fxHashAdmin", async function () {
      // Set the bypass list
      await mintPassGroup
        .connect(fxHashAdmin)
        .setBypass([user1.address, user2.address]);

      // Assert the updated bypass list
      const bypassList = await mintPassGroup.getBypass();
      expect(bypassList[0]).to.equal(user1.address);
      expect(bypassList[1]).to.equal(user2.address);
    });

    it("should revert when updating the bypass list by non-fxHashAdmin", async function () {
      // Try to set the bypass list and expect a revert
      await expect(
        mintPassGroup.connect(admin).setBypass([user1.address, user2.address])
      ).to.be.revertedWith("Caller is not authorized");
    });
  });

  describe("isPassValid", function () {
    //TODO: Need to fix the test, for some reason signature verification is not working as expected
    // it("should validate a valid pass", async function () {
    //   // Create a valid pass
    //   const payload = ethers.utils.defaultAbiCoder.encode(
    //     ["tuple(string,uint256,address)"],
    //     [[token, project, addr]]
    //   );
    //   const signature = await fxHashAdmin.signMessage(
    //     ethers.utils.arrayify(payload)
    //   );

    //   // Create the Pass object
    //   const pass = { payload: payload, signature: signature };
    //   const encoded_pass = ethers.utils.defaultAbiCoder.encode(
    //     ["tuple(bytes,bytes)"],
    //     [[pass.payload, pass.signature]]
    //   );
    //   await mintPassGroup.connect(user1).consumePass(encoded_pass);

    //   // Check if the pass is valid (no need to assign the result)
    //   await mintPassGroup.connect(user1).isPassValid(pass.payload);
    // });

    it("should revert for an invalid pass", async function () {
      // Create an invalid pass
      const payload = ethers.utils.defaultAbiCoder.encode(
        ["tuple(string,uint256,address)"],
        [["token2", 2, addr]]
      );
      const signature = await fxHashAdmin.signMessage(
        ethers.utils.arrayify(payload)
      );

      // Create the Pass object
      const pass = { payload: payload, signature: signature };
      const encoded_pass = ethers.utils.defaultAbiCoder.encode(
        ["tuple(bytes,bytes)"],
        [[pass.payload, pass.signature]]
      );
      await expect(mintPassGroup.isPassValid(encoded_pass)).to.be.revertedWith(
        "PASS_NOT_CONSUMED"
      );
    });
  });
});
