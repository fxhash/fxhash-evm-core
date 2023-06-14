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

  beforeEach(async function () {});

  before(async () => {
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
    issuer = await IssuerFactory.deploy();
    await issuer.deployed();
    mintTicket = await MintTicket.deploy(
      await admin.getAddress(),
      issuer.address,
      randomizer.address
    );
    await mintTicket.deployed();
  });

  describe("createProject", () => {
    it("should create a new project", async () => {
      const projectId = 1;
      const gracingPeriod = 30;
      const metadata = "Project metadata";

      await mintTicket.createProject(projectId, gracingPeriod, metadata);

      const projectData = await mintTicket.projectData(projectId);
      expect(projectData.gracingPeriod).to.equal(gracingPeriod);
      expect(projectData.metadata).to.equal(metadata);
    });

    it("should revert if the project already exists", async () => {
      const projectId = 1;
      const gracingPeriod = 30;
      const metadata = "Project metadata";

      await mintTicket.createProject(projectId, gracingPeriod, metadata);

      await expect(
        mintTicket.createProject(projectId, gracingPeriod, metadata)
      ).to.be.revertedWith("PROJECT_EXISTS");
    });

    it("should revert if the gracing period is less than 1 day", async () => {
      const projectId = 1;
      const gracingPeriod = 0;
      const metadata = "Project metadata";

      await expect(
        mintTicket.createProject(projectId, gracingPeriod, metadata)
      ).to.be.revertedWith("GRACING_UNDER_1");
    });
  });
});
