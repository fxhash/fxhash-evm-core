import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";
import { expect } from "chai";

describe("ReserveMintPass", () => {
  let reserve: Contract;
  let group: Contract;
  let owner: Signer;
  let addr1: Signer;

  beforeEach(async () => {
    [owner, addr1] = await ethers.getSigners();

    const ReserveMintPass = await ethers.getContractFactory("ReserveMintPass");
    reserve = await ReserveMintPass.deploy();
    await reserve.deployed();

    const MintPassGroup = await ethers.getContractFactory("MintPassGroup");
    group = await MintPassGroup.deploy(
      10, // maxPerToken
      5, // maxPerTokenPerProject
      owner.getAddress(), // publicKey
      []
    );
    await group.deployed();
  });

  describe("isInputValid", () => {
    it("should return true for a valid input", async () => {
      const params = {
        data: ethers.utils.defaultAbiCoder.encode(["address"], [group.address]),
        amount: 8,
        sender: owner.getAddress(),
      };

      const isValid = await reserve.isInputValid(params);

      expect(isValid).to.be.true;
    });

    it("should revert for an invalid input", async () => {
      const params = {
        data: "0x",
        amount: 8,
        sender: owner.getAddress(),
      };
      await expect(reserve.isInputValid(params)).to.be.revertedWith(
        "INVALID_DATA"
      );
    });
  });

  describe("applyReserve", () => {
    it("should apply the method if user input and current amount are provided", async () => {
      const token = "TOKEN1";
      const project = 1;
      const addr = await addr1.getAddress();
      const target = group.address;
      const payload = ethers.utils.defaultAbiCoder.encode(
        ["tuple(string,uint256,address)"],
        [[token, project, await addr1.getAddress()]]
      );
      const signature = await owner.signMessage(ethers.utils.arrayify(payload));

      // Create the Pass object
      const pass = { payload: payload, signature: signature };
      const encoded_pass = ethers.utils.defaultAbiCoder.encode(
        ["tuple(bytes,bytes)"],
        [[pass.payload, pass.signature]]
      );
      const current_data = ethers.utils.defaultAbiCoder.encode(
        ["address"],
        [target]
      );

      const params = {
        user_input: encoded_pass,
        current_amount: 10,
        current_data: current_data,
        sender: addr,
      };
      const tx = await reserve.connect(addr1).applyReserve(params);
      const receipt = await tx.wait();
      const event = receipt.events?.find(
        (e: { event: string }) => e.event === "MethodApplied"
      );
      const [applied, new_data] = event.args;
      expect(new_data).to.equal(current_data);
      expect(applied).to.be.true;
    });

    it("should not apply the method if user input or current amount is missing", async () => {
      const token = "TOKEN1";
      const project = 1;
      const addr = await addr1.getAddress();
      const target = group.address;
      const payload = ethers.utils.defaultAbiCoder.encode(
        ["tuple(string,uint256,address)"],
        [[token, project, await addr1.getAddress()]]
      );
      const signature = await owner.signMessage(ethers.utils.arrayify(payload));

      // Create the Pass object
      const pass = { payload: payload, signature: signature };
      const encoded_pass = ethers.utils.defaultAbiCoder.encode(
        ["tuple(bytes,bytes)"],
        [[pass.payload, pass.signature]]
      );
      const current_data = ethers.utils.defaultAbiCoder.encode(
        ["address"],
        [target]
      );

      const params = {
        user_input: encoded_pass,
        current_amount: 0,
        current_data: current_data,
        sender: addr,
      };
      await expect(
        reserve.connect(addr1).applyReserve(params)
      ).to.be.revertedWith("INVALID_CURRENT_AMOUNT");
    });
  });
});
