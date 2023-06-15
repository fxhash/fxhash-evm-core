import { ethers } from "hardhat";
import { Contract, ContractFactory, Signer } from "ethers";
import { expect } from "chai";
import { describe, before, it } from "mocha";

describe("MintTicket", () => {
  let mintTicket: Contract;
  let issuer: Contract;
  let randomizer: Contract;
  let admin: Signer;
  let fxHashAdmin: Signer;
  let nonAdmin: Signer;

  const fxHashAdminRole = ethers.utils.id("FXHASH_ADMIN");

  beforeEach(async function () {
    [admin, fxHashAdmin, nonAdmin] = await ethers.getSigners();

    const RandomizerFactory: ContractFactory = await ethers.getContractFactory(
      "Randomizer"
    );
    const IssuerFactory: ContractFactory = await ethers.getContractFactory(
      "FxHashIssuer"
    );
    const MintTicket: ContractFactory = await ethers.getContractFactory(
      "MintTicket"
    );

    const seed = ethers.utils.formatBytes32String("seed");
    const salt = ethers.utils.formatBytes32String("salt");
    randomizer = await RandomizerFactory.deploy(seed, salt);
    await randomizer.deployed();

    mintTicket = await MintTicket.deploy(
      await admin.getAddress(),
      randomizer.address,
      randomizer.address
    );
    await mintTicket.deployed();
    issuer = await IssuerFactory.deploy(mintTicket.address);
    await issuer.deployed();
    await mintTicket.setIssuer(issuer.address);
  });

  describe("createProject", () => {
    it("should create a new project", async () => {
      const projectId = 1;
      const gracingPeriod = 30;
      const metadata = "Project metadata";

      await issuer.createProject(projectId, gracingPeriod, metadata);

      const projectData = await mintTicket.projectData(projectId);
      expect(projectData.gracingPeriod).to.equal(gracingPeriod);
      expect(projectData.metadata).to.equal(metadata);
    });

    it("should revert if the project already exists", async () => {
      const projectId = 1;
      const gracingPeriod = 30;
      const metadata = "Project metadata";

      await issuer.createProject(projectId, gracingPeriod, metadata);

      await expect(
        issuer.createProject(projectId, gracingPeriod, metadata)
      ).to.be.revertedWith("PROJECT_EXISTS");
    });

    it("should revert if the gracing period is less than 1 day", async () => {
      const projectId = 1;
      const gracingPeriod = 0;
      const metadata = "Project metadata";

      await expect(
        issuer.createProject(projectId, gracingPeriod, metadata)
      ).to.be.revertedWith("GRACING_UNDER_1");
    });
  });

  describe("mint", () => {
    it("should mint a new token with the given project and price", async () => {
      const projectId = 1;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseEther("1");

      await issuer.createProject(projectId, 30, "Project metadata");

      await issuer.mint(projectId, minter, price);

      const tokenData = await mintTicket.tokenData(0);
      expect(tokenData.projectId).to.equal(projectId);
      expect(tokenData.minter).to.equal(minter);
      expect(tokenData.price).to.equal(price);
    });

    it("should revert if the project does not exist", async () => {
      const projectId = 1;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseEther("1");

      await expect(issuer.mint(projectId, minter, price)).to.be.revertedWith(
        "PROJECT_DOES_NOT_EXISTS"
      );
    });

    it("should set the price to min price if the price is below the minimum price", async () => {
      const projectId = 1;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseEther("0.001");
      const minprice = ethers.utils.parseEther("0.1");
      await mintTicket.setMinPrice(minprice);
      await issuer.createProject(projectId, 30, "Project metadata");
      await issuer.mint(projectId, minter, price);

      const tokenData = await mintTicket.tokenData(0);
      expect(tokenData.projectId).to.equal(projectId);
      expect(tokenData.minter).to.equal(minter);
      expect(tokenData.price).to.equal(minprice);
    });
  });

  describe("updatePrice", () => {
    it("should update the price of the token", async () => {
      const projectId = 1;
      const tokenId = 0;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseEther("1");
      const newPrice = ethers.utils.parseEther("2");
      const gracingPeriod = 30;
      const coverage = gracingPeriod + 1; // Set coverage outside the gracing period

      await issuer.createProject(projectId, gracingPeriod, "Project metadata");
      await issuer.mint(projectId, minter, price);

      // Transfer sufficient funds to cover the tax
      const taxAmount = ethers.utils.parseEther("0.01");
      await mintTicket.payTax(tokenId, { value: taxAmount });

      await mintTicket
        .connect(nonAdmin)
        .updatePrice(tokenId, newPrice, coverage);

      const tokenData = await mintTicket.tokenData(tokenId);
      expect(tokenData.price).to.equal(newPrice);
    });

    it("should revert if the token does not exist", async () => {
      const tokenId = 0;
      const newPrice = ethers.utils.parseEther("2");
      const coverage = 10;

      await expect(
        mintTicket.connect(nonAdmin).updatePrice(tokenId, newPrice, coverage)
      ).to.be.revertedWith("TOKEN_DOES_NOT_EXIST");
    });

    it("should revert if the sender is not the owner of the token", async () => {
      const projectId = 1;
      const tokenId = 0;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseEther("1");
      const newPrice = ethers.utils.parseEther("2");
      const coverage = 10;

      await issuer.createProject(projectId, 30, "Project metadata");
      await issuer.mint(projectId, minter, price);

      await expect(
        mintTicket.connect(fxHashAdmin).updatePrice(tokenId, newPrice, coverage)
      ).to.be.revertedWith("INSUFFICIENT_BALANCE");
    });

    it("should revert if the new price is below the minimum price", async () => {
      const projectId = 1;
      const tokenId = 0;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseEther("1");
      const newPrice = ethers.utils.parseEther("0.001");
      const coverage = 10;

      await mintTicket.setMinPrice(ethers.utils.parseEther("0.1"));
      await issuer.createProject(projectId, 30, "Project metadata");
      await issuer.mint(projectId, minter, price);

      await expect(
        mintTicket.connect(nonAdmin).updatePrice(tokenId, newPrice, coverage)
      ).to.be.revertedWith("PRICE_BELOW_MIN_PRICE");
    });

    it("should revert if the coverage is less than 1", async () => {
      const projectId = 1;
      const tokenId = 0;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseEther("1");
      const newPrice = ethers.utils.parseEther("2");
      const coverage = 0;

      await issuer.createProject(projectId, 30, "Project metadata");
      await issuer.mint(projectId, minter, price);

      await expect(
        mintTicket.connect(nonAdmin).updatePrice(tokenId, newPrice, coverage)
      ).to.be.revertedWith("MIN_1_COVERAGE");
    });
  });
});
