import { ethers } from "hardhat";
import { Contract, Signer, Wallet } from "ethers";
import { expect } from "chai";

const provider = ethers.provider;
// Create and connect the wallets
const admin = new ethers.Wallet(
  "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
).connect(provider);
let nonAdmin: Signer;
let moderationIssuer: Contract;
let moderationTeam: Contract;
let allowMint: Contract;
const authorizations = [10];

describe("AllowMint", function () {
  beforeEach(async function () {
    await ethers.provider.send("hardhat_reset", []);

    [nonAdmin] = await ethers.getSigners();

    const ModerationTeam = await ethers.getContractFactory("ModerationTeam");

    moderationTeam = await ModerationTeam.deploy();
    await moderationTeam.deployed();

    const ModerationIssuer = await ethers.getContractFactory(
      "ModerationIssuer"
    );
    moderationIssuer = await ModerationIssuer.deploy(moderationTeam.address);
    await moderationIssuer.deployed();

    await moderationTeam.connect(admin).updateModerators([
      {
        moderator: await admin.getAddress(),
        authorizations,
      },
    ]);

    const AllowMintFactory = await ethers.getContractFactory("AllowMint");
    allowMint = await AllowMintFactory.deploy(moderationIssuer.address);
    await allowMint.deployed();
  });

  it("should allow minting when the token is not moderated and batch minting is allowed", async function () {
    const addr = await admin.getAddress();
    const timestamp = Math.floor(Date.now() / 1000);
    const tokenContract = await nonAdmin.getAddress();

    const isAllowed = await allowMint.isAllowed(tokenContract);

    expect(isAllowed).to.be.true;
  });

  it("should throw an error when the token is moderated", async function () {
    const addr = await admin.getAddress();
    const timestamp = Math.floor(Date.now() / 1000);
    const tokenContract = await nonAdmin.getAddress();

    const state = 2;
    const reason = 0;
    await moderationIssuer.connect(admin).reasonAdd("reason");

    await moderationIssuer
      .connect(admin)
      .moderateIssuer(tokenContract, state, reason);
    // The function call should revert with the 'TOKEN_MODERATED' error message
    await expect(
      allowMint.isAllowed(tokenContract)
    ).to.be.revertedWithCustomError(allowMint, "TokenModerated");
  });
});
