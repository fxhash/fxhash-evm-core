import { ethers } from "hardhat";
import { Contract } from "ethers";
import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("ModerationTeam", function () {
  let moderationTeam: Contract;
  let admin: SignerWithAddress;
  let moderator1: SignerWithAddress;
  let moderator2: SignerWithAddress;

  beforeEach(async () => {
    const ModerationTeam = await ethers.getContractFactory("ModerationTeam");
    [admin, moderator1, moderator2] = await ethers.getSigners();

    moderationTeam = await ModerationTeam.deploy(admin.address);
    await moderationTeam.deployed();
  });

  it("should add a moderator and update authorizations", async function () {
    const authorizations = [1, 2, 3];

    await moderationTeam.connect(admin).updateModerators([
      {
        moderator: moderator1.address,
        authorizations,
      },
    ]);

    const receivedAuthorizations = await moderationTeam.getAuthorizations(
      moderator1.address
    );
    expect(receivedAuthorizations).to.deep.equal(authorizations);
  });

  it("should remove a moderator and update shares", async function () {
    const authorizations = [1, 2, 3];

    await moderationTeam.connect(admin).updateModerators([
      {
        moderator: moderator1.address,
        authorizations,
      },
    ]);
    const sharePercentage = 50;

    await moderationTeam.connect(admin).updateShares([
      {
        moderator: moderator1.address,
        share: sharePercentage,
      },
    ]);
    const share = await moderationTeam.moderators(moderator1.address);
    expect(share).to.equal(ethers.BigNumber.from(sharePercentage));

    await moderationTeam.connect(admin).updateShares([
      {
        moderator: moderator1.address,
        share: 0,
      },
    ]);

    const receivedAuthorizations = await moderationTeam.getAuthorizations(
      moderator1.address
    );
    expect(receivedAuthorizations).to.deep.equal([]);
  });

  it("should distribute funds to moderators", async function () {
    const authorizations = [1, 2, 3];

    // Assume we have a balance of 100 ether in the contract
    const sharePercentage = 50;
    await admin.sendTransaction({
      to: moderationTeam.address,
      value: ethers.utils.parseEther("1000"),
    });
    await moderationTeam.connect(admin).updateShares([
      {
        moderator: moderator1.address,
        share: sharePercentage,
      },
      {
        moderator: moderator2.address,
        share: sharePercentage,
      },
    ]);
    await moderationTeam.connect(admin).updateModerators([
      {
        moderator: moderator1.address,
        authorizations,
      },
      {
        moderator: moderator2.address,
        authorizations,
      },
    ]);
    const initialBalance1 = await ethers.provider.getBalance(
      moderator1.address
    );
    const initialBalance2 = await ethers.provider.getBalance(
      moderator2.address
    );

    await moderationTeam.connect(admin).withdraw();

    const finalBalance1 = await ethers.provider.getBalance(moderator1.address);
    const finalBalance2 = await ethers.provider.getBalance(moderator2.address);

    // Calculate expected balances based on share percentages, subtracting gas cost
    const expectedBalance1 = initialBalance1.add(
      ethers.utils.parseEther("500")
    );
    const expectedBalance2 = initialBalance2.add(
      ethers.utils.parseEther("500")
    );

    expect(finalBalance1.toString()).to.equal(expectedBalance1.toString());
    expect(finalBalance2.toString()).to.equal(expectedBalance2.toString());
  });
});
