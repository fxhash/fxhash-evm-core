import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";
import { expect } from "chai";

describe("AllowIssuerMint", function () {
  let admin: Signer;
  let nonAdmin: Signer;
  let moderationUser: Contract;
  let moderationTeam: Contract;
  let allowIssuerMint: Contract;
  let userActions: Contract;
  const authorizations = [20];

  beforeEach(async function () {
    await ethers.provider.send("hardhat_reset", []);

    [admin, nonAdmin] = await ethers.getSigners();

    const ModerationUser = await ethers.getContractFactory("ModerationUser");
    moderationUser = await ModerationUser.deploy(await admin.getAddress());
    await moderationUser.deployed();

    const ModerationTeam = await ethers.getContractFactory("ModerationTeam");

    moderationTeam = await ModerationTeam.deploy(admin.getAddress());
    await moderationTeam.deployed();
    await moderationUser.setAddress([
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

    const AllowMintFactory = await ethers.getContractFactory("AllowMintIssuer");
    allowIssuerMint = await AllowMintFactory.deploy(
      await admin.getAddress(),
      moderationUser.address,
      userActions.address
    );

    await allowIssuerMint.deployed();
    await userActions.connect(admin).authorizeCaller(allowIssuerMint.address);
  });

  it("should update the user moderation contract", async function () {
    const ModerationUser = await ethers.getContractFactory("ModerationUser");

    let moderationUser = await ModerationUser.deploy(admin.getAddress());
    await moderationUser.deployed();
    await allowIssuerMint.updateUserModerationContract(moderationUser.address);
    expect(await allowIssuerMint.userModerationContract()).to.equal(
      moderationUser.address
    );
  });

  it("should update the user actions contract", async function () {
    await allowIssuerMint.updateUserActionsContract(await admin.getAddress());
    expect(await allowIssuerMint.userActions()).to.equal(
      await admin.getAddress()
    );
  });

  it("should update the mint delay", async function () {
    const newMintDelay = 1800;
    await allowIssuerMint.updateMintDelay(newMintDelay);
    expect(await allowIssuerMint.mintDelay()).to.equal(newMintDelay);
  });

  it("should return true when address is allowed", async function () {
    // Mock the isUserAllowed function to return true
    const isAllowed = await allowIssuerMint.isAllowed(
      await admin.getAddress(),
      100000
    );
    expect(isAllowed).to.be.true;
  });

  it("should throw an error when address is banned", async function () {
    // Mock the isUserAllowed function to return false
    const userAddress = await nonAdmin.getAddress();
    const state = 3;
    const reason = 0;
    await moderationUser.connect(admin).reasonAdd("reason");
    await moderationUser
      .connect(admin)
      .moderateUser(userAddress, state, reason);
    await expect(
      allowIssuerMint.isAllowed(await nonAdmin.getAddress(), 0)
    ).to.be.rejectedWith("ACCOUNT_BANNED");
  });

  it("should throw an error when delay between mint is too short", async function () {
    const timestamp = Math.floor(Date.now() / 1000);
    await allowIssuerMint.updateMintDelay(timestamp * 2);
    await ethers.provider.send("evm_setNextBlockTimestamp", [timestamp * 2]);
    await expect(
      allowIssuerMint.isAllowed(await nonAdmin.getAddress(), timestamp * 2)
    ).to.be.rejectedWith("DELAY_BETWEEN_MINT_TOO_SHORT");
  });
});
