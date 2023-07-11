import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";
import { expect } from "chai";

describe("ReserveMintPass", () => {
  let reserve: Contract;
  let reserveManager: Contract;

  let group: Contract;
  let owner: Signer;
  let addr1: Signer;

  beforeEach(async () => {
    [owner, addr1] = await ethers.getSigners();

    // Deploy ReserveManager
    const ReserveManagerFactory = await ethers.getContractFactory(
      "ReserveManager"
    );
    reserveManager = await ReserveManagerFactory.deploy();

    const ReserveMintPass = await ethers.getContractFactory("ReserveMintPass");
    reserve = await ReserveMintPass.deploy(await owner.getAddress());
    await reserve.deployed();

    const MintPassGroup = await ethers.getContractFactory("MintPassGroup");
    group = await MintPassGroup.deploy(
      10, // maxPerToken
      5, // maxPerTokenPerProject
      await owner.getAddress(),
      await owner.getAddress(), // publicKey
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
    //TODO: need to fix test and signature
    // it("should apply the method if user input and current amount are provided", async () => {
    //   const token = "TOKEN1";
    //   const project = 0;
    //   const addr = await addr1.getAddress();
    //   const target = group.address;
    //   const payload = ethers.utils.defaultAbiCoder.encode(
    //     ["tuple(string,uint256,address)"],
    //     [[token, project, await addr1.getAddress()]]
    //   );
    //   const signature = await owner.signMessage(ethers.utils.arrayify(payload));

    //   // Create the Pass object
    //   const pass = { payload: payload, signature: signature };
    //   const encoded_pass = ethers.utils.defaultAbiCoder.encode(
    //     ["tuple(bytes,bytes)"],
    //     [[pass.payload, pass.signature]]
    //   );
    //   const currentData = ethers.utils.defaultAbiCoder.encode(
    //     ["address"],
    //     [target]
    //   );

    //   const params = {
    //     userInput: encoded_pass,
    //     currentAmount: 10,
    //     currentData: currentData,
    //     sender: addr,
    //   };
    //   const tx = await reserve.connect(addr1).applyReserve(params);
    //   const receipt = await tx.wait();
    //   const event = receipt.events?.find(
    //     (e: { event: string }) => e.event === "MethodApplied"
    //   );
    //   const [applied, new_data] = event.args;
    //   expect(new_data).to.equal(currentData);
    //   expect(applied).to.be.true;
    // });

    it("should not apply the method if user input or current amount is missing", async () => {
      const token = "TOKEN1";
      const project = await addr1.getAddress();
      const addr = await addr1.getAddress();
      const target = group.address;
      const payload = ethers.utils.defaultAbiCoder.encode(
        ["tuple(string,address,address)"],
        [[token, project, await addr1.getAddress()]]
      );
      const signature = await owner.signMessage(ethers.utils.arrayify(payload));

      // Create the Pass object
      const pass = { payload: payload, signature: signature };
      const encoded_pass = ethers.utils.defaultAbiCoder.encode(
        ["tuple(bytes,bytes)"],
        [[pass.payload, pass.signature]]
      );
      const currentData = ethers.utils.defaultAbiCoder.encode(
        ["address"],
        [target]
      );

      const params = {
        userInput: encoded_pass,
        currentAmount: 0,
        currentData: currentData,
        sender: addr,
      };
      await expect(
        reserve.connect(owner).applyReserve(params, addr)
      ).to.be.revertedWith("INVALID_CURRENT_AMOUNT");
    });
  });
});
