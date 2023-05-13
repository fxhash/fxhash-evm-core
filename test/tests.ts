import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract } from "ethers";

let genTk: Contract;
let genTkProject: Contract;

describe("GenTk and GenTkProject", function () {
  let addr1: any, addr2: any, addr3: any, addr4: any;
  beforeEach(async () => {
    // Get the ContractFactory and Signers here.
    const GenTk = await ethers.getContractFactory("GenTk");
    genTk = await GenTk.deploy();
    await genTk.deployed();

    const GenTkProject = await ethers.getContractFactory("GenTkProject");
    genTkProject = await GenTkProject.deploy();
    await genTkProject.deployed();

    [addr1, addr2, addr3, addr4] = await ethers.getSigners();

    // Set GenTk and GenTkProject to each other
    await genTkProject.setGenTk(genTk.address);
    await genTk.setGenTkProject(genTkProject.address);
  });

  describe("Mint tests", function () {
    it("Should deploy GenTk and GenTkProject", async function () {
      expect(genTk.address).to.properAddress;
      expect(genTkProject.address).to.properAddress;
    });

    it("Should set genTk correctly", async function () {
      const currentGenTk = await genTkProject.getGenTk();
      expect(currentGenTk).to.equal(genTk.address);
    });

    it("Should set genTkProject correctly", async function () {
      const currentGenTkProject = await genTk.genTkProject();
      expect(currentGenTkProject).to.equal(genTkProject.address);
    });

    it("Should be able to grant and revoke the ADMIN_ROLE from an address", async function () {
      await genTk.grantAdminRole(addr2.address);
      expect(await genTk.hasRole(ethers.constants.HashZero, addr2.address)).to
        .be.true;
      await genTk.revokeAdminRole(addr2.address);
      expect(await genTk.hasRole(ethers.constants.HashZero, addr2.address)).to
        .be.false;
    });

    it("should create a project and mint new GenTk tokens correctly", async function () {
      const editions = 10;
      const price = ethers.utils.parseEther("1");
      const openingTime = Math.floor(Date.now() / 1000) + 60 * 60 * 24;
      const royaltiesBPs = 1000; // 10%
      const projectURI = "https://example.com/metadata";
      const royalties = [
        { account: addr3.address, value: 5000 },
        { account: addr4.address, value: 5000 },
      ];

      await genTkProject
        .connect(addr1)
        .createProject(
          editions,
          price,
          openingTime,
          royaltiesBPs,
          projectURI,
          royalties
        );

      await ethers.provider.send("evm_increaseTime", [60 * 60 * 24 + 1]);
      const projectId = 0;

      const initialProjectOwnerBalance = await ethers.provider.getBalance(
        addr1.address
      );
      const initialAddr2Balance = await ethers.provider.getBalance(
        addr2.address
      );
      const initialAddr3Balance = await ethers.provider.getBalance(
        addr3.address
      );
      const initialAddr4Balance = await ethers.provider.getBalance(
        addr4.address
      );

      const tx = await genTkProject
        .connect(addr2)
        .mint(projectId, { value: ethers.utils.parseEther("1") });

      const txReceipt = await tx.wait();
      const gasUsed = txReceipt.gasUsed;
      const txCost = gasUsed.mul(tx.gasPrice);

      const finalProjectOwnerBalance = await ethers.provider.getBalance(
        addr1.address
      );
      const finalAddr2Balance = await ethers.provider.getBalance(addr2.address);
      const finalAddr3Balance = await ethers.provider.getBalance(addr3.address);
      const finalAddr4Balance = await ethers.provider.getBalance(addr4.address);

      // Check that the project owner received the minting amount minus royalties
      expect(finalProjectOwnerBalance).to.equal(
        initialProjectOwnerBalance.add(ethers.utils.parseEther("0.9"))
      ); // assuming 10% royalties

      // Check that addr2's balance decreased by the minting amount plus gas cost
      expect(finalAddr2Balance).to.equal(
        initialAddr2Balance.sub(ethers.utils.parseEther("1")).sub(txCost)
      );

      // Check that addr3's balance increased by the royalties amount
      expect(finalAddr3Balance).to.equal(
        initialAddr3Balance.add(ethers.utils.parseEther("0.05"))
      ); // assuming 50% of 10% royalties

      // Check that addr4's balance increased by the royalties amount
      expect(finalAddr4Balance).to.equal(
        initialAddr4Balance.add(ethers.utils.parseEther("0.05"))
      ); // assuming 50% of 10% royalties

      // Check that the token was minted correctly
      const owner = await genTk.ownerOf(0);
      expect(owner).to.equal(addr2.address);

      // Check that the project data in storage was updated correctly
      const projectData = await genTkProject.projects(projectId);
      expect(projectData.availableSupply).to.equal(editions - 1);
    });

    it("should fail when trying to mint a token without enough Ether", async function () {
      const editions = 10;
      const price = ethers.utils.parseEther("1");
      const openingTime = Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 2;
      const royaltiesBPs = 1000; // 10%
      const projectURI = "https://example.com/metadata";
      const royalties = [{ account: addr3.address, value: 10000 }];

      await genTkProject
        .connect(addr1)
        .createProject(
          editions,
          price,
          openingTime,
          royaltiesBPs,
          projectURI,
          royalties
        );

      await ethers.provider.send("evm_increaseTime", [60 * 60 * 24 + 1]);
      const projectId = 0;

      // Attempt to mint with less Ether than required
      await expect(
        genTkProject
          .connect(addr2)
          .mint(projectId, { value: ethers.utils.parseEther("0.5") }) // this should fail
      ).to.be.revertedWith("Ether value sent is not correct");
    });

    it("should fail when trying to mint a token before the sale has started", async function () {
      const editions = 10;
      const price = ethers.utils.parseEther("1");
      const openingTime = Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 3;
      const royaltiesBPs = 1000; // 10%
      const projectURI = "https://example.com/metadata";
      const royalties = [{ account: addr3.address, value: 10000 }];

      await genTkProject
        .connect(addr1)
        .createProject(
          editions,
          price,
          openingTime,
          royaltiesBPs,
          projectURI,
          royalties
        );

      const projectId = 0;

      // Attempt to mint before the sale has started
      await expect(
        genTkProject
          .connect(addr2)
          .mint(projectId, { value: ethers.utils.parseEther("1") }) // this should fail
      ).to.be.revertedWith("Sale has not started");
    });

    it("should fail when trying to mint a token from a sold out project", async function () {
      const editions = 1; // Only one token available
      const price = ethers.utils.parseEther("1");
      const openingTime = Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 4;
      const royaltiesBPs = 1000; // 10%
      const projectURI = "https://example.com/metadata";
      const royalties = [{ account: addr3.address, value: 10000 }];

      await genTkProject
        .connect(addr1)
        .createProject(
          editions,
          price,
          openingTime,
          royaltiesBPs,
          projectURI,
          royalties
        );

      await ethers.provider.send("evm_increaseTime", [60 * 60 * 24 * 2]);
      const projectId = 0;

      // Mint the only available token
      await genTkProject
        .connect(addr2)
        .mint(projectId, { value: ethers.utils.parseEther("1") });

      // Attempt to mint another token, which should fail as the project is sold out
      await expect(
        genTkProject
          .connect(addr2)
          .mint(projectId, { value: ethers.utils.parseEther("1") })
      ).to.be.revertedWith("No more tokens available for this project");
    });
  });

  describe("Create project tests", function () {
    const editions = 10;
    const price = ethers.utils.parseEther("1");
    const openingTime = Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 5;
    const royaltiesBPs = 1000; // 10%
    const accountRoyalties = 10000; // 10%

    const projectURI = "https://example.com/metadata";

    it("should create a new project correctly", async function () {
      const royalties = [{ account: addr3.address, value: accountRoyalties }];

      const tx = await genTkProject
        .connect(addr1)
        .createProject(
          editions,
          price,
          openingTime,
          royaltiesBPs,
          projectURI,
          royalties
        );

      const projectId = 0;
      const projectData = await genTkProject.projects(projectId);
      expect(projectData.editions).to.equal(editions);
      expect(projectData.price).to.equal(price);
      expect(projectData.openingTime).to.equal(openingTime);
      expect(projectData.royaltiesBPs).to.equal(royaltiesBPs);
      expect(projectData.availableSupply).to.equal(editions);
    });

    it("should fail when trying to create a project with royalties more than 100%", async function () {
      const royalties = [{ account: addr3.address, value: accountRoyalties }];

      await expect(
        genTkProject
          .connect(addr1)
          .createProject(
            editions,
            price,
            openingTime,
            11000,
            projectURI,
            royalties
          )
      ).to.be.revertedWith("Royalties can't exceed 100%");
    });

    it("should revert if editions number is zero", async function () {
      const royalties = [{ account: addr3.address, value: accountRoyalties }];

      await expect(
        genTkProject
          .connect(addr1)
          .createProject(
            0,
            price,
            openingTime,
            royaltiesBPs,
            projectURI,
            royalties
          )
      ).to.be.revertedWith("Invalid edition number");
    });

    it("should revert if price is zero", async function () {
      const royalties = [{ account: addr3.address, value: accountRoyalties }];

      await expect(
        genTkProject
          .connect(addr1)
          .createProject(
            editions,
            0,
            openingTime,
            royaltiesBPs,
            projectURI,
            royalties
          )
      ).to.be.revertedWith("Invalid edition price");
    });

    it("should revert if opening time is in the past", async function () {
      const royalties = [{ account: addr3.address, value: accountRoyalties }];

      const pastTime = Math.floor(Date.now() / 1000) - 60 * 60;
      await expect(
        genTkProject
          .connect(addr1)
          .createProject(
            editions,
            price,
            pastTime,
            royaltiesBPs,
            projectURI,
            royalties
          )
      ).to.be.revertedWith("Invalid opening time");
    });

    it("should revert if project URI is empty", async function () {
      const royalties = [{ account: addr3.address, value: accountRoyalties }];

      await expect(
        genTkProject
          .connect(addr1)
          .createProject(
            editions,
            price,
            openingTime,
            royaltiesBPs,
            "",
            royalties
          )
      ).to.be.revertedWith("Invalid project URI");
    });
  });
});
