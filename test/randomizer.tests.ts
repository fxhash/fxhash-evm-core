import { ethers } from "hardhat";
import { Contract, ContractFactory, Signer } from "ethers";
import { expect } from "chai";

function oracleIterator(iteration: number, seed: string, salt: string): string {
  let hash: string = seed;
  for (let i = 0; i < iteration; i++) {
    const encodedData: string = ethers.utils.defaultAbiCoder.encode(
      ["bytes32", "bytes32"],
      [salt, hash]
    );

    const hashedData: string = ethers.utils.keccak256(encodedData);
    hash = hashedData;
  }
  return hash;
}

describe("Randomizer", function () {
  let randomizer: Contract;
  let admin: Signer;
  let fxHashAdmin: Signer;
  let nonAdmin: Signer;
  const fxHashAdminRole = ethers.utils.id("AUTHORIZED_CALLER");
  const seed = ethers.utils.formatBytes32String("0x");
  const salt = ethers.utils.formatBytes32String("0x");

  beforeEach(async function () {
    const RandomizerFactory: ContractFactory = await ethers.getContractFactory(
      "Randomizer"
    );
    [admin, fxHashAdmin, nonAdmin] = await ethers.getSigners();

    randomizer = await RandomizerFactory.deploy(
      oracleIterator(100, seed, salt),
      salt
    );
    await randomizer.deployed();
  });

  describe("Admin functions", function () {
    it("should grant the ADMIN_ROLE to an address", async function () {
      const addressToGrant = await fxHashAdmin.getAddress();

      await randomizer.connect(admin).grantAdminRole(addressToGrant);
      const hasAdminRole = await randomizer.hasRole(
        await randomizer.DEFAULT_ADMIN_ROLE(),
        addressToGrant
      );

      expect(hasAdminRole).to.be.true;
    });

    it("should revoke the ADMIN_ROLE from an address", async function () {
      const addressToRevoke = await fxHashAdmin.getAddress();

      await randomizer.connect(admin).revokeAdminRole(addressToRevoke);
      const hasAdminRole = await randomizer.hasRole(
        await randomizer.DEFAULT_ADMIN_ROLE(),
        addressToRevoke
      );

      expect(hasAdminRole).to.be.false;
    });

    it("should grant the AUTHORIZED_CALLER role to an address", async function () {
      const addressToGrant = await fxHashAdmin.getAddress();

      await randomizer.connect(admin).authorizeCaller(addressToGrant);
      const hasFxHashAdminRole = await randomizer.hasRole(
        fxHashAdminRole,
        addressToGrant
      );

      expect(hasFxHashAdminRole).to.be.true;
    });

    it("should revoke the AUTHORIZED_CALLER role from an address", async function () {
      const addressToRevoke = await fxHashAdmin.getAddress();

      await randomizer
        .connect(admin)
        .revokeCallerAuthorization(addressToRevoke);
      const hasFxHashAdminRole = await randomizer.hasRole(
        fxHashAdminRole,
        addressToRevoke
      );

      expect(hasFxHashAdminRole).to.be.false;
    });
  });

  describe("Generate function", function () {
    beforeEach(async function () {
      await randomizer.connect(admin).authorizeCaller(fxHashAdmin.getAddress());
      await randomizer
        .connect(admin)
        .grantFxHashIssuerRole(fxHashAdmin.getAddress());
      await randomizer
        .connect(admin)
        .grantFxHashAuthorityRole(fxHashAdmin.getAddress());
    });

    it("should generate a new token", async function () {
      const tokenKey = {
        issuer: await fxHashAdmin.getAddress(),
        id: 1,
      };
      await randomizer.connect(fxHashAdmin).generate(1);
      // const count = await randomizer.countRequested();
      // expect(count).to.equal(1);
      // Verify the seed and serial_id in the seeds mapping
      const hashedKey = await randomizer.getTokenKey(
        tokenKey.issuer,
        tokenKey.id
      );
      const seed = await randomizer.seeds(hashedKey);
      expect(seed.chainSeed).to.not.equal(ethers.constants.HashZero);
      expect(seed.serialId).to.equal(1);
    });

    it("should reveal tokens and update commitment correctly", async function () {
      const tokenKey0 = {
        issuer: await fxHashAdmin.getAddress(),
        tokenId: 0,
      };
      const tokenKey1 = {
        issuer: await fxHashAdmin.getAddress(),
        tokenId: 1,
      };
      const tokenKey2 = {
        issuer: await fxHashAdmin.getAddress(),
        tokenId: 2,
      };

      await randomizer.connect(fxHashAdmin).generate(tokenKey0.tokenId);
      await randomizer.connect(fxHashAdmin).generate(tokenKey1.tokenId);
      await randomizer.connect(fxHashAdmin).generate(tokenKey2.tokenId);

      await randomizer
        .connect(fxHashAdmin)
        .reveal(
          [tokenKey2, tokenKey1, tokenKey0],
          oracleIterator(100 - 3, seed, salt)
        );

      // const hashedKey = await randomizer.getTokenKey(
      //   tokenKey0.issuer,
      //   tokenKey0.tokenId
      // );
      // const revealedSeed = await randomizer.seeds(hashedKey);
      // expect(revealedSeed.revealed).to.equal(
      //   ethers.utils.keccak256(
      //     ethers.utils.defaultAbiCoder.encode(
      //       ["bytes32", "bytes32"],
      //       [oracleIterator(100 - 1, seed, salt), revealedSeed.chainSeed]
      //     )
      //   )
      // );

      // const commitmentSeed = await randomizer.commitment();
      // expect(commitmentSeed.seed).to.equal(oracleIterator(100 - 3, seed, salt));
    });
  });
});
