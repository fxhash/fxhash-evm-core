import { ethers } from "hardhat";
import { Contract, ContractFactory, Signer } from "ethers";
import { expect } from "chai";

describe("Randomizer", function () {
  let randomizer: Contract;
  let admin: Signer;
  let fxHashAdmin: Signer;
  let nonAdmin: Signer;
  const fxHashAdminRole = ethers.utils.id("FXHASH_ADMIN");

  beforeEach(async function () {
    const RandomizerFactory: ContractFactory = await ethers.getContractFactory(
      "Randomizer"
    );
    [admin, fxHashAdmin, nonAdmin] = await ethers.getSigners();

    const seed = ethers.utils.formatBytes32String("seed");
    const salt = ethers.utils.formatBytes32String("salt");
    randomizer = await RandomizerFactory.deploy(seed, salt);
    await randomizer.deployed();
  });

  //   describe("Admin functions", function () {
  //     it("should grant the ADMIN_ROLE to an address", async function () {
  //       const addressToGrant = await fxHashAdmin.getAddress();

  //       await randomizer.connect(admin).grantAdminRole(addressToGrant);
  //       const hasAdminRole = await randomizer.hasRole(
  //         await randomizer.DEFAULT_ADMIN_ROLE(),
  //         addressToGrant
  //       );

  //       expect(hasAdminRole).to.be.true;
  //     });

  //     it("should revoke the ADMIN_ROLE from an address", async function () {
  //       const addressToRevoke = await fxHashAdmin.getAddress();

  //       await randomizer.connect(admin).revokeAdminRole(addressToRevoke);
  //       const hasAdminRole = await randomizer.hasRole(
  //         await randomizer.DEFAULT_ADMIN_ROLE(),
  //         addressToRevoke
  //       );

  //       expect(hasAdminRole).to.be.false;
  //     });

  //     it("should grant the FXHASH_ADMIN role to an address", async function () {
  //       const addressToGrant = await fxHashAdmin.getAddress();

  //       await randomizer.connect(admin).grantFxHashAdminRole(addressToGrant);
  //       const hasFxHashAdminRole = await randomizer.hasRole(
  //         fxHashAdminRole,
  //         addressToGrant
  //       );

  //       expect(hasFxHashAdminRole).to.be.true;
  //     });

  //     it("should revoke the FXHASH_ADMIN role from an address", async function () {
  //       const addressToRevoke = await fxHashAdmin.getAddress();

  //       await randomizer.connect(admin).revokeFxHashAdminRole(addressToRevoke);
  //       const hasFxHashAdminRole = await randomizer.hasRole(
  //         fxHashAdminRole,
  //         addressToRevoke
  //       );

  //       expect(hasFxHashAdminRole).to.be.false;
  //     });
  //   });

  describe("Generate function", function () {
    beforeEach(async function () {
      await randomizer
        .connect(admin)
        .grantFxHashAdminRole(fxHashAdmin.getAddress());
      await randomizer
        .connect(admin)
        .grantFxHashIssuerRole(fxHashAdmin.getAddress());
      await randomizer
        .connect(admin)
        .grantFxHashAuthorityRole(fxHashAdmin.getAddress());
    });

    // it("should generate a new token", async function () {
    //   const tokenKey = {
    //     issuer: await fxHashAdmin.getAddress(),
    //     id: 1,
    //   };
    //   await randomizer.connect(fxHashAdmin).generate(1);
    //   const count = await randomizer.count_requested();
    //   expect(count).to.equal(1);
    //   // Verify the seed and serial_id in the seeds mapping
    //   const hashedKey = await randomizer.getTokenKey(
    //     tokenKey.issuer,
    //     tokenKey.id
    //   );
    //   const seed = await randomizer.seeds(hashedKey);
    //   expect(seed.chain_seed).to.not.equal(ethers.constants.HashZero);
    //   expect(seed.serial_id).to.equal(1);
    // });

    it("should reveal tokens and update commitment correctly", async function () {
      const tokenKey = {
        issuer: await fxHashAdmin.getAddress(),
        id: 1,
      };

      const seed = ethers.utils.formatBytes32String("seed");
      await randomizer.connect(fxHashAdmin).generate(tokenKey.id);
      await randomizer.connect(fxHashAdmin).reveal([tokenKey], seed);

      const revealedSeed = await randomizer.seeds(
        randomizer.getTokenKey(tokenKey.issuer, tokenKey.id)
      ).revealed;
      expect(revealedSeed).to.equal(
        ethers.utils.keccak256(
          ethers.utils.defaultAbiCoder.encode(
            ["bytes32", "bytes32"],
            [seed, seed]
          )
        )
      );

      const commitmentSeed = await randomizer.commitment();
      expect(commitmentSeed).to.equal(seed);
    });
  });
});
