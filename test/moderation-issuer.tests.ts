import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";
import { expect } from "chai";
import { describe, before, beforeEach, it } from "mocha";

describe("ModerationIssuer", () => {
  let moderatorToken: Contract;
  let moderationTeam: Contract;

  let admin: Signer;
  let moderator: Signer;
  let user1: Signer;
  const authorizations = [10];

  beforeEach(async () => {
    [admin, moderator, user1] = await ethers.getSigners();
    const ModerationIssuer = await ethers.getContractFactory(
      "ModerationIssuer"
    );

    const ModerationTeam = await ethers.getContractFactory("ModerationTeam");
    [admin, moderator, user1] = await ethers.getSigners();

    moderationTeam = await ModerationTeam.deploy(admin.getAddress());
    await moderationTeam.deployed();
    moderatorToken = await ModerationIssuer.deploy(moderationTeam.address);
    await moderatorToken.deployed();

    await moderationTeam.connect(admin).updateModerators([
      {
        moderator: await moderator.getAddress(),
        authorizations,
      },
    ]);
  });

  describe("reasonAdd", () => {
    it("should add a new reason", async () => {
      const reason = "Reason 1";

      await moderatorToken.connect(moderator).reasonAdd(reason);

      const storedReason = await moderatorToken.reasons(0);
      expect(storedReason).to.equal(reason);
    });

    it("should revert when non-moderator tries to add a new reason", async () => {
      const reason = "Reason 2";

      await expect(
        moderatorToken.connect(user1).reasonAdd(reason)
      ).to.be.revertedWithCustomError(moderatorToken, "NotMod");
    });
  });

  describe("moderateIssuer", () => {
    it("should moderate a token", async () => {
      const issuer = await user1.getAddress();
      const state = 1;
      const reason = 0;
      await moderatorToken.connect(moderator).reasonAdd("reason");

      await moderatorToken
        .connect(moderator)
        .moderateIssuer(issuer, state, reason);

      const moderationState = await moderatorToken.issuerState(issuer);
      expect(moderationState).to.equal(state);
    });

    it("should revert when non-moderator tries to moderate a token", async () => {
      const issuer = await user1.getAddress();
      const state = 1;
      const reason = 1;

      await expect(
        moderatorToken.connect(user1).moderateIssuer(issuer, state, reason)
      ).to.be.revertedWithCustomError(moderatorToken, "NotMod");
    });
  });

  describe("report", () => {
    it("should report a token", async () => {
      const issuer = await user1.getAddress();
      const reason = 0;
      await moderatorToken.connect(moderator).reasonAdd("reason");

      await moderatorToken.connect(moderator).report(issuer, reason);

      const reportKey = await moderatorToken.getHashedKey(
        issuer,
        await moderator.getAddress()
      );
      const storedReason = await moderatorToken.reports(reportKey);
      expect(storedReason).to.equal(reason);
    });

    it("should revert when non-moderator tries to report a token with non-existent reason", async () => {
      const issuer = await user1.getAddress();
      const reason = 10;

      await expect(
        moderatorToken.connect(moderator).report(issuer, reason)
      ).to.be.revertedWith("REASON_DOESNT_EXISTS");
    });
  });

  describe("getReportKey", () => {
    it("should return the correct report key", async () => {
      const issuer = await user1.getAddress();
      const reporter = await moderator.getAddress();

      const expectedKey = ethers.utils.keccak256(
        ethers.utils.solidityPack(["address", "address"], [issuer, reporter])
      );

      const reportKey = await moderatorToken.getHashedKey(issuer, reporter);
      expect(reportKey).to.equal(expectedKey);
    });
  });

  describe("isModerator", () => {
    it("should return true for a moderator", async () => {
      const isModerator = await moderatorToken.isModerator(
        await moderator.getAddress()
      );
      expect(isModerator).to.be.true;
    });

    it("should return false for a non-moderator", async () => {
      const isModerator = await moderatorToken.isModerator(
        await user1.getAddress()
      );
      expect(isModerator).to.be.false;
    });
  });
});
