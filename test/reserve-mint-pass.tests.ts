import { expect } from "chai";
import { BigNumber, Contract } from "ethers";
import { ethers } from "hardhat";

describe("ReserveWhitelist", () => {
  let reserveWhitelist: Contract;
  let addr1: any;
  let addr2: any;
  let addr3: any;

  beforeEach(async () => {
    // Deploy the ReserveWhitelist contract before each test
    const ReserveWhitelistFactory = await ethers.getContractFactory(
      "ReserveWhitelist"
    );
    [addr1, addr2, addr3] = await ethers.getSigners();

    reserveWhitelist = await ReserveWhitelistFactory.deploy();
    await reserveWhitelist.deployed();
  });

  describe("isInputValid", () => {
    it("should return true when the sum of amounts is greater than or equal to the required amount", async () => {
      // Prepare test data
      const whitelist = [
        {
          whitelisted: addr1.address,
          amount: 10,
        },
        {
          whitelisted: addr2.address,
          amount: 5,
        },
        {
          whitelisted: addr3.address,
          amount: 3,
        },
      ];
      const params = {
        data: ethers.utils.defaultAbiCoder.encode(
          ["tuple(address,uint256)[]"],
          [whitelist.map((entry) => [entry.whitelisted, entry.amount])]
        ),
        amount: 15,
        sender: addr1.address,
      };

      // Call the contract function
      const result = await reserveWhitelist.isInputValid(params);

      // Assert the result
      expect(result).to.be.true;
    });

    it("should return false when the sum of amounts is less than the required amount", async () => {
      // Prepare test data
      const whitelist = [
        {
          whitelisted: addr1.address,
          amount: 5,
        },
        {
          whitelisted: addr2.address,
          amount: 3,
        },
      ];
      const params = {
        data: ethers.utils.defaultAbiCoder.encode(
          ["tuple(address,uint256)[]"],
          [whitelist.map((entry) => [entry.whitelisted, entry.amount])]
        ),
        amount: 10,
        sender: addr1.address,
      };

      // Call the contract function
      const result = await reserveWhitelist.isInputValid(params);

      // Assert the result
      expect(result).to.be.false;
    });
  });

  describe("applyMethod", () => {
    it("should decrease the amount of the whitelisted address by 1", async () => {
      // Prepare test data
      const whitelist = [
        {
          whitelisted: addr1.address,
          amount: 5,
        },
        {
          whitelisted: addr2.address,
          amount: 3,
        },
      ];
      const params = {
        current_data: ethers.utils.defaultAbiCoder.encode(
          ["tuple(address,uint256)[]"],
          [whitelist.map((entry) => [entry.whitelisted, entry.amount])]
        ),
        sender: addr1.address,
        current_amount: 8,
        user_input: "0x00",
      };

      // Call the contract function
      const [applied, packedNewData] = await reserveWhitelist.applyMethod(
        params
      );

      // Decode the updated whitelist
      const updatedWhitelist = ethers.utils.defaultAbiCoder.decode(
        ["tuple(address,uint256)[]"],
        packedNewData
      )[0];

      // Assert the result
      expect(applied).to.be.true;
      expect(updatedWhitelist).to.deep.equal([
        [addr1.address, ethers.BigNumber.from("4")],
        [addr2.address, ethers.BigNumber.from("3")],
      ]);
    });

    it("should not modify the whitelist when the sender is not whitelisted or the amount is zero", async () => {
      // Prepare test data
      const whitelist = [
        {
          whitelisted: addr1.address,
          amount: 5,
        },
        {
          whitelisted: addr2.address,
          amount: 3,
        },
      ];
      const params = {
        current_data: ethers.utils.defaultAbiCoder.encode(
          ["tuple(address,uint256)[]"],
          [whitelist.map((entry) => [entry.whitelisted, entry.amount])]
        ),
        sender: addr3.address,
        current_amount: 0,
        user_input: "0x00",
      };

      // Call the contract function
      const [applied, packedNewData] = await reserveWhitelist.applyMethod(
        params
      );

      // Decode the updated whitelist
      const updatedWhitelist = ethers.utils.defaultAbiCoder.decode(
        ["tuple(address,uint256)[]"],
        packedNewData
      )[0];

      // Assert the result
      expect(applied).to.be.false;
      expect(updatedWhitelist).to.deep.equal([
        [addr1.address, ethers.BigNumber.from("5")],
        [addr2.address, ethers.BigNumber.from("3")],
      ]);
    });
  });
});
