import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";
import { expect } from "chai";

describe("AllowMint", function () {
  let admin: Signer;
  let nonAdmin: Signer;
  let moderatorToken: Contract;
  let moderationTeam: Contract;
  let allowMint: Contract;
  let userActions: Contract;
  const authorizations = [10];

  beforeEach(async function () {
    await ethers.provider.send("hardhat_reset", []);

    [admin, nonAdmin] = await ethers.getSigners();

    const ModerationToken = await ethers.getContractFactory("ModerationToken");
    moderatorToken = await ModerationToken.deploy(await admin.getAddress());
    await moderatorToken.deployed();

    const ModerationTeam = await ethers.getContractFactory("ModerationTeam");

    moderationTeam = await ModerationTeam.deploy(admin.getAddress());
    await moderationTeam.deployed();
    await moderatorToken.setContract([
      { key: "mod", value: moderationTeam.address },
    ]);
    await moderationTeam.connect(admin).updateModerators([
      {
        moderator: await admin.getAddress(),
        authorizations,
      },
    ]);

    const UserActionsFactory = await ethers.getContractFactory("UserActions");
    userActions = await UserActionsFactory.deploy(await admin.getAddress());
    await userActions.deployed();

    const AllowMintFactory = await ethers.getContractFactory("AllowMint");
    allowMint = await AllowMintFactory.deploy(
      await admin.getAddress(),
      moderatorToken.address,
      userActions.address
    );

    await allowMint.deployed();
    await userActions.connect(admin).authorizeCaller(allowMint.address);
    await userActions.connect(admin).authorizeCaller(await admin.getAddress());
  });

  it("should allow minting when the token is not moderated and batch minting is allowed", async function () {
    const addr = await admin.getAddress();
    const timestamp = Math.floor(Date.now() / 1000);
    const id = 1;

    const isAllowed = await allowMint.isAllowed(addr, timestamp, id);

    expect(isAllowed).to.be.true;
  });

  it("should throw an error when the token is moderated", async function () {
    const addr = await admin.getAddress();
    const timestamp = Math.floor(Date.now() / 1000);
    const id = 1;

    const state = 2;
    const reason = 0;
    await moderatorToken.connect(admin).reasonAdd("reason");

    await moderatorToken.connect(admin).moderateToken(id, state, reason);
    // The function call should revert with the 'TOKEN_MODERATED' error message
    await expect(allowMint.isAllowed(addr, timestamp, id)).to.be.revertedWith(
      "TOKEN_MODERATED"
    );
  });

  it("should throw an error when batch minting is not allowed", async function () {
    const addr = await admin.getAddress();
    const timestamp = Math.floor(Date.now() / 1000) * 2;
    const id = 1;
    await ethers.provider.send("evm_setNextBlockTimestamp", [timestamp - 1]);
    await ethers.provider.send("evm_mine", []);

    await userActions.setLastMinted(addr, id);
    await expect(allowMint.isAllowed(addr, timestamp, id)).to.be.revertedWith(
      "NO_BATCH_MINTING"
    );
  });
});
