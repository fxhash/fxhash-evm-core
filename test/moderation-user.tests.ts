import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";
import { expect } from "chai";
import { describe, before, it } from "mocha";

describe("ModerationUser", () => {
  let moderationUser: Contract;
  let moderationTeam: Contract;
  let admin: Signer;
  let moderator: Signer;
  let user1: Signer;
  let user2: Signer;
  const authorizations = [20];

  before(async () => {
    const ModerationTeam = await ethers.getContractFactory("ModerationTeam");
    const ModerationUser = await ethers.getContractFactory("ModerationUser");
    [admin, moderator, user1, user2] = await ethers.getSigners();

    moderationUser = await ModerationUser.deploy(await admin.getAddress());
    await moderationUser.deployed();
    moderationTeam = await ModerationTeam.deploy(admin.getAddress());
    await moderationTeam.deployed();
    await moderationUser.setAddress("mod", moderationTeam.address);

    await moderationTeam.connect(admin).updateModerators([
      {
        moderator: moderator.getAddress(),
        authorizations,
      },
    ]);
  });

  describe("moderate", () => {
    it("should moderate a user", async () => {
      const userAddress = await user1.getAddress();
      const state = 1;
      const reason = 1;

      await moderationUser
        .connect(moderator)
        .moderate(userAddress, state, reason);

      const userState = await moderationUser.userState(userAddress);
      expect(userState).to.equal(state);
    });

    it("should revert when non-moderator tries to moderate a user", async () => {
      const userAddress = await user2.getAddress();
      const state = 1;
      const reason = 1;

      await expect(
        moderationUser.connect(user1).moderate(userAddress, state, reason)
      ).to.be.revertedWith("NOT_MOD");
    });
  });

  describe("ban", () => {
    it("should ban a user", async () => {
      const userAddress = await user1.getAddress();
      const reason = 2;

      await moderationUser.connect(moderator).ban(userAddress, reason);

      const userState = await moderationUser.userState(userAddress);
      expect(userState).to.equal(3);
    });
  });

  describe("verify", () => {
    it("should verify a user", async () => {
      const userAddress = await user1.getAddress();

      await moderationUser.connect(moderator).verify(userAddress);

      const userState = await moderationUser.userState(userAddress);
      expect(userState).to.equal(10);
    });

    it("should revert when non-moderator tries to verify a user", async () => {
      const userAddress = await user2.getAddress();

      await expect(
        moderationUser.connect(user1).verify(userAddress)
      ).to.be.revertedWith("NOT_MOD");
    });
  });

  describe("reasonAdd", () => {
    it("should add a new reason", async () => {
      const reason = "Reason 1";

      await moderationUser.connect(moderator).reasonAdd(reason);

      const storedReason = await moderationUser.reasons(0);
      expect(storedReason).to.equal(reason);
    });

    it("should revert when non-moderator tries to add a new reason", async () => {
      const reason = "Reason 2";

      await expect(
        moderationUser.connect(user1).reasonAdd(reason)
      ).to.be.revertedWith("NOT_MOD");
    });
  });

  describe("reasonUpdate", () => {
    it("should update a reason", async () => {
      const reasonId = 0;
      const reason = "Reason 1";
      await moderationUser.connect(moderator).reasonAdd(reason);
      const storedReason = await moderationUser.reasons(reasonId);
      expect(storedReason).to.equal(reason);
      const updatedReason = "Updated Reason";

      await moderationUser
        .connect(moderator)
        .reasonUpdate(reasonId, updatedReason);

      const updatedStoredReason = await moderationUser.reasons(reasonId);
      expect(updatedStoredReason).to.equal(updatedReason);
    });

    it("should revert when non-moderator tries to update a reason", async () => {
      const reasonId = 0;
      const updatedReason = "Updated Reason";

      await expect(
        moderationUser.connect(user1).reasonUpdate(reasonId, updatedReason)
      ).to.be.revertedWith("NOT_MOD");
    });
  });
});
