import { ethers, waffle } from "hardhat";
import { expect } from "chai";
import { Contract } from "ethers";

describe("ReserveManager", function () {
  let ReserveManager: Contract;
  let ReserveWhitelist: Contract;
  let accounts: any;

  beforeEach(async () => {
    accounts = await ethers.getSigners();

    // Deploy ReserveWhitelist
    const ReserveWhitelistFactory = await ethers.getContractFactory(
      "ReserveWhitelist"
    );
    ReserveWhitelist = await ReserveWhitelistFactory.deploy();

    // Deploy ReserveManager
    const ReserveManagerFactory = await ethers.getContractFactory(
      "ReserveManager"
    );
    ReserveManager = await ReserveManagerFactory.deploy();
  });

  describe("isReserveValid", function () {
    it("Should return true if reserve is valid", async function () {
      const whitelistEntry = [accounts[1].address, 1000];
      const data = ethers.utils.defaultAbiCoder.encode(
        ["tuple(address,uint256)[]"],
        [[whitelistEntry]]
      );

      const reserveMethod = {
        reserveContract: ReserveWhitelist.address,
        methodData: data,
      };
      await ReserveManager.setReserveMethod(1, reserveMethod);

      const reserve = {
        methodId: 1,
        data: data,
        amount: 1,
      };
      expect(await ReserveManager.isReserveValid(reserve)).to.equal(true);
    });

    // Add more test cases to cover other scenarios
  });

  describe("applyReserve", function () {
    it("Should apply reserve successfully", async function () {
      const whitelistEntry = [accounts[1].address, 1000];
      const data = ethers.utils.defaultAbiCoder.encode(
        ["tuple(address,uint256)[]"],
        [[whitelistEntry]]
      );
      const reserveMethod = {
        reserveContract: ReserveWhitelist.address,
        methodData: data,
      };
      await ReserveManager.setReserveMethod(1, reserveMethod);

      const reserve = {
        methodId: 1,
        data: data,
        amount: 10,
      };
      const output = await ReserveManager.applyReserve(reserve, "0x");
      //expect(output).to.equal(true);
      // Parse output data to validate changes

      // Add more test cases to cover other scenarios
    });
  });

  describe("setReserveMethod", function () {
    it("Should set reserve method successfully", async function () {
      const whitelistEntry = [accounts[1].address, 1000];
      const data = ethers.utils.defaultAbiCoder.encode(
        ["tuple(address,uint256)[]"],
        [[whitelistEntry]]
      );
      const reserveMethod = {
        reserveContract: ReserveWhitelist.address,
        methodData: data,
      };
      await ReserveManager.setReserveMethod(1, reserveMethod);

      const method = await ReserveManager.getReserveMethod(1);
      expect(method.reserveContract).to.equal(ReserveWhitelist.address);
      //   expect(ethers.utils.parseBytes32String(method.methodData)).to.equal(
      //     "MethodData"
      //   );
    });

    // Add more test cases to cover other scenarios
  });

  describe("getReserveMethod", function () {
    it("Should get reserve method successfully", async function () {
      const reserveMethod = {
        reserveContract: ReserveWhitelist.address,
        methodData: ethers.utils.formatBytes32String("MethodData"),
      };
      await ReserveManager.setReserveMethod(1, reserveMethod);

      const method = await ReserveManager.getReserveMethod(1);
      expect(method.reserveContract).to.equal(ReserveWhitelist.address);
    //   expect(ethers.utils.parseBytes32String(method.methodData)).to.equal(
    //     "MethodData"
    //   );
    });

    // Add more test cases to cover other scenarios
  });
});
