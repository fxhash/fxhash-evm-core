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
let userActions: Contract;
const authorizations = [10];

async function signMessage(
  signer: Wallet,
  addr: string,
  issuer: string,
  tokenContract: string,
  tokenId: number
) {
  const domain = {
    name: "UserActions",
    version: "1",
    chainId: (await ethers.provider.getNetwork()).chainId,
    verifyingContract: userActions.address,
  };

  const types = {
    SetLastMinted: [
      { name: "addr", type: "address" },
      { name: "issuer", type: "address" },
      { name: "tokenContract", type: "address" },
      { name: "tokenId", type: "uint256" },
    ],
  };

  const value = {
    addr: addr,
    issuer: issuer,
    tokenContract: tokenContract, // Convert ETH to wei
    tokenId: tokenId,
  };

  const signature = await signer._signTypedData(domain, types, value);

  return signature;
}

describe("AllowMint", function () {
  beforeEach(async function () {
    await ethers.provider.send("hardhat_reset", []);

    [nonAdmin] = await ethers.getSigners();

    const ModerationTeam = await ethers.getContractFactory("ModerationTeam");

    moderationTeam = await ModerationTeam.deploy(admin.getAddress());
    await moderationTeam.deployed();

    const ModerationIssuer = await ethers.getContractFactory(
      "ModerationIssuer"
    );
    moderationIssuer = await ModerationIssuer.deploy(
      await admin.getAddress(),
      moderationTeam.address
    );
    await moderationIssuer.deployed();

    await moderationTeam.connect(admin).updateModerators([
      {
        moderator: await admin.getAddress(),
        authorizations,
      },
    ]);

    const UserActionsFactory = await ethers.getContractFactory("UserActions");
    userActions = await UserActionsFactory.deploy();
    await userActions.deployed();

    const AllowMintFactory = await ethers.getContractFactory("AllowMint");
    allowMint = await AllowMintFactory.deploy(moderationIssuer.address);
    await allowMint.deployed();
  });

  it("should allow minting when the token is not moderated and batch minting is allowed", async function () {
    const addr = await admin.getAddress();
    const timestamp = Math.floor(Date.now() / 1000);
    const tokenContract = await nonAdmin.getAddress();

    const isAllowed = await allowMint.isAllowed(addr, timestamp, tokenContract);

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
      allowMint.isAllowed(addr, timestamp, tokenContract)
    ).to.be.revertedWith("TOKEN_MODERATED");
  });

  it("should throw an error when batch minting is not allowed", async function () {
    const addr = await admin.getAddress();
    const timestamp = Math.floor(Date.now() / 1000) * 2;
    const tokenContract = await nonAdmin.getAddress();
    const issuer = await nonAdmin.getAddress();
    const tokenId = 1;
    const sig = signMessage(admin, addr, issuer, tokenContract, tokenId);
    await ethers.provider.send("evm_setNextBlockTimestamp", [timestamp - 1]);
    await ethers.provider.send("evm_mine", []);

    await userActions.setLastMinted(addr, issuer, tokenContract, tokenId, sig);
    await expect(
      allowMint.isAllowed(addr, timestamp, tokenContract)
    ).to.be.revertedWith("NO_BATCH_MINTING");
  });
});
