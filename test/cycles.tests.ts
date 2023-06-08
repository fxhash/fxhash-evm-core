import { ethers } from "hardhat";
import { Contract, ContractFactory, Signer } from "ethers";
import { expect } from "chai";

describe("FxHashCycles", function () {
  let fxHashCycles: Contract;
  let admin: Signer;
  let nonAdmin: Signer;
  let fxHashAdmin: Signer;

  const FXHASH_ADMIN = ethers.utils.id("FXHASH_ADMIN");

  beforeEach(async function () {
    const FxHashCycles: ContractFactory = await ethers.getContractFactory(
      "FxHashCycles"
    );
    [admin, fxHashAdmin, nonAdmin] = await ethers.getSigners();

    fxHashCycles = await FxHashCycles.deploy();
    await fxHashCycles.deployed();
  });

  describe("Admin functions", function () {
    it("should grant the ADMIN_ROLE to an address", async function () {
      const addressToGrant = await fxHashAdmin.getAddress();

      await fxHashCycles.connect(admin).grantAdminRole(addressToGrant);
      const hasAdminRole = await fxHashCycles.hasRole(
        await fxHashCycles.DEFAULT_ADMIN_ROLE(),
        addressToGrant
      );

      expect(hasAdminRole).to.be.true;
    });

    it("should revoke the ADMIN_ROLE from an address", async function () {
      const addressToRevoke = await fxHashAdmin.getAddress();

      await fxHashCycles.connect(admin).revokeAdminRole(addressToRevoke);
      const hasAdminRole = await fxHashCycles.hasRole(
        await fxHashCycles.DEFAULT_ADMIN_ROLE(),
        addressToRevoke
      );

      expect(hasAdminRole).to.be.false;
    });

    it("should grant the FXHASH_ADMIN role to an address", async function () {
      const addressToGrant = await fxHashAdmin.getAddress();

      await fxHashCycles.connect(admin).grantFxHashAdminRole(addressToGrant);
      const hasFxHashAdminRole = await fxHashCycles.hasRole(
        FXHASH_ADMIN,
        addressToGrant
      );

      expect(hasFxHashAdminRole).to.be.true;
    });

    it("should revoke the FXHASH_ADMIN role from an address", async function () {
      const addressToRevoke = await fxHashAdmin.getAddress();

      await fxHashCycles.connect(admin).revokeFxHashAdminRole(addressToRevoke);
      const hasFxHashAdminRole = await fxHashCycles.hasRole(
        FXHASH_ADMIN,
        addressToRevoke
      );

      expect(hasFxHashAdminRole).to.be.false;
    });
  });

  describe("Cycle functions", function () {
    beforeEach(async function () {
      const FxHashCycles: ContractFactory = await ethers.getContractFactory(
        "FxHashCycles"
      );
      [admin, fxHashAdmin] = await ethers.getSigners();

      fxHashCycles = await FxHashCycles.deploy();
      await fxHashCycles.deployed();

      // Grant the FxHash admin role to the fxHashAdmin address
      await fxHashCycles
        .connect(admin)
        .grantFxHashAdminRole(await fxHashAdmin.getAddress());
    });

    it("should add a new cycle", async function () {
      const cycleParams = {
        start: 100,
        openingDuration: 50,
        closingDuration: 100,
      };

      await fxHashCycles.connect(fxHashAdmin).addCycle(cycleParams);
      const cycle = await fxHashCycles.cycles(0);

      expect(cycle.start).to.equal(cycleParams.start);
      expect(cycle.openingDuration).to.equal(cycleParams.openingDuration);
      expect(cycle.closingDuration).to.equal(cycleParams.closingDuration);
    });

    it("should remove an existing cycle", async function () {
      const cycleParams = {
        start: 100,
        openingDuration: 50,
        closingDuration: 100,
      };

      await fxHashCycles.connect(fxHashAdmin).addCycle(cycleParams);
      await fxHashCycles.connect(fxHashAdmin).removeCycle(0);
      const cycle = await fxHashCycles.cycles(0);

      expect(cycle.start).to.equal(0);
      expect(cycle.openingDuration).to.equal(0);
      expect(cycle.closingDuration).to.equal(0);
    });

    it("should not allow a non-admin to remove a cycle", async function () {
      const cycleParams = {
        start: 100,
        openingDuration: 50,
        closingDuration: 100,
      };
      const cycleId = 0;

      // Add the cycle
      await fxHashCycles.connect(fxHashAdmin).addCycle(cycleParams);

      // Attempt to remove the cycle by a non-admin
      await expect(
        fxHashCycles.connect(nonAdmin).removeCycle(cycleId)
      ).to.be.revertedWith("Caller is not a FxHash admin");

      // Verify the cycle still exists
      const cycle = await fxHashCycles.cycles(cycleId);
      expect(cycle.start).to.equal(cycleParams.start);
      expect(cycle.openingDuration).to.equal(cycleParams.openingDuration);
      expect(cycle.closingDuration).to.equal(cycleParams.closingDuration);
    });

    it("should not allow a non-admin to add a cycle", async function () {
      const cycleParams = {
        start: 100,
        openingDuration: 50,
        closingDuration: 100,
      };

      // Attempt to remove the cycle by a non-admin
      await expect(
        fxHashCycles.connect(nonAdmin).addCycle(cycleParams)
      ).to.be.revertedWith("Caller is not a FxHash admin");
    });

    it("should add and remove multiple cycles", async function () {
      const cycleParams1 = {
        start: 100,
        openingDuration: 50,
        closingDuration: 100,
      };
      const cycleParams2 = {
        start: 200,
        openingDuration: 60,
        closingDuration: 120,
      };
      const cycleId1 = 0;
      const cycleId2 = 1;

      // Add the first cycle
      await fxHashCycles.connect(fxHashAdmin).addCycle(cycleParams1);
      const cycle1 = await fxHashCycles.cycles(cycleId1);
      expect(cycle1.start).to.equal(cycleParams1.start);

      // Add the second cycle
      await fxHashCycles.connect(fxHashAdmin).addCycle(cycleParams2);
      const cycle2 = await fxHashCycles.cycles(cycleId2);
      expect(cycle2.start).to.equal(cycleParams2.start);

      // Remove the first cycle
      await fxHashCycles.connect(fxHashAdmin).removeCycle(cycleId1);
      const deletedCycle1 = await fxHashCycles.cycles(cycleId1);
      expect(deletedCycle1.start).to.equal(0);

      // Remove the second cycle
      await fxHashCycles.connect(fxHashAdmin).removeCycle(cycleId2);
      const deletedCycle2 = await fxHashCycles.cycles(cycleId2);
      expect(deletedCycle2.start).to.equal(0);
    });

    it("should check if any cycles are open", async function () {
      const cycleParams1 = {
        start: 500,
        openingDuration: 100,
        closingDuration: 110,
      };
      const cycleParams2 = {
        start: 800,
        openingDuration: 50,
        closingDuration: 100,
      };

      await fxHashCycles.connect(fxHashAdmin).addCycle(cycleParams1);
      await fxHashCycles.connect(fxHashAdmin).addCycle(cycleParams2);

      const areCyclesOpen = await fxHashCycles.areCyclesOpen([[0, 1]], 500);

      expect(areCyclesOpen).to.be.true;
    });

    it("should return false if no cycles are open", async function () {
      const cycleParams1 = {
        start: 100,
        openingDuration: 10,
        closingDuration: 110,
      };
      const cycleParams2 = {
        start: 200,
        openingDuration: 10,
        closingDuration: 120,
      };

      await fxHashCycles.connect(fxHashAdmin).addCycle(cycleParams1);
      await fxHashCycles.connect(fxHashAdmin).addCycle(cycleParams2);

      const areCyclesOpen = await fxHashCycles.areCyclesOpen([[0, 1]], 400);

      expect(areCyclesOpen).to.be.false;
    });

    it("should return false if no cycle IDs are provided", async function () {
      const cycleParams1 = {
        start: 100,
        openingDuration: 50,
        closingDuration: 100,
      };
      await fxHashCycles.connect(fxHashAdmin).addCycle(cycleParams1);
      const areCyclesOpen = await fxHashCycles.areCyclesOpen([], 120);

      expect(areCyclesOpen).to.be.false;
    });
  });
});
