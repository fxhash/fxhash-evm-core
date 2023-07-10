import { ethers } from "hardhat";
import { BigNumber, Contract, ContractFactory, Signer } from "ethers";
import { expect } from "chai";
import { describe, before, it } from "mocha";

describe("MintTicket", () => {
  let mintTicket: Contract;
  let issuer: Contract;
  let randomizer: Contract;
  let admin: Signer;
  let fxHashAdmin: Signer;
  let nonAdmin: Signer;

  const fxHashAdminRole = ethers.utils.id("AUTHORIZED_CALLER");

  // Helper functions
  const dailyTaxAmount = (price: BigNumber): BigNumber => {
    return price.mul(14).div(10000);
  };

  const distanceForeclosure = async (
    price: BigNumber,
    token: any,
    startDay: BigNumber
  ): Promise<BigNumber> => {
    const dailyTax = dailyTaxAmount(ethers.BigNumber.from(price));
    const daysCovered = token.taxationLocked.div(dailyTax);
    const foreclosureTime = token.taxationStart.add(daysCovered.mul(86400));
    const distance = ethers.BigNumber.from(startDay).sub(foreclosureTime);
    return distance.gt(0) ? distance : ethers.constants.Zero;
  };

  const foreclosurePrice = async (
    price: BigNumber,
    secondsElapsed: BigNumber
  ): Promise<BigNumber> => {
    const T = ethers.BigNumber.from(secondsElapsed).mul(10000).div(86400);
    const prange = price.sub(await mintTicket.minPrice()); // TODO: Check this value
    return price.sub(prange.mul(T).div(10000));
  };

  const taxRelease = (token: any, date: number): [BigNumber, BigNumber] => {
    const timeDiff = ethers.BigNumber.from(date).sub(token.taxationStart);
    const daysSinceLastTaxation = timeDiff.div(24 * 60 * 60);
    const dailyTax = dailyTaxAmount(token.price);
    const taxToPay = dailyTax.mul(daysSinceLastTaxation);
    const taxToRelease = token.taxationLocked.sub(taxToPay);
    return [taxToPay, taxToRelease];
  };

  beforeEach(async function () {
    [admin, fxHashAdmin, nonAdmin] = await ethers.getSigners();

    const RandomizerFactory: ContractFactory = await ethers.getContractFactory(
      "Randomizer"
    );
    const IssuerFactory: ContractFactory = await ethers.getContractFactory(
      "MockIssuer"
    );
    const MintTicket: ContractFactory = await ethers.getContractFactory(
      "MintTicket"
    );

    const seed = ethers.utils.formatBytes32String("seed");
    const salt = ethers.utils.formatBytes32String("salt");
    randomizer = await RandomizerFactory.deploy(seed, salt);
    await randomizer.deployed();
    mintTicket = await MintTicket.deploy(randomizer.address);
    await mintTicket.deployed();
    issuer = await IssuerFactory.deploy(mintTicket.address);
    await issuer.deployed();
    await randomizer.grantFxHashIssuerRole(mintTicket.address);
  });

  describe("createProject", () => {
    it("should create a new project", async () => {
      const gracingPeriod = 30;
      const metadata = "Project metadata";

      await issuer.createProject(gracingPeriod, metadata);

      const projectData = await mintTicket.projectData(await issuer.address);
      expect(projectData.gracingPeriod).to.equal(gracingPeriod);
      expect(projectData.metadata).to.equal(metadata);
    });

    it("should revert if the project already exists", async () => {
      const gracingPeriod = 30;
      const metadata = "Project metadata";

      await issuer.createProject(gracingPeriod, metadata);

      await expect(
        issuer.createProject(gracingPeriod, metadata)
      ).to.be.revertedWith("PROJECT_EXISTS");
    });

    it("should revert if the gracing period is less than 1 day", async () => {
      const gracingPeriod = 0;
      const metadata = "Project metadata";

      await expect(
        issuer.createProject(gracingPeriod, metadata)
      ).to.be.revertedWith("GRACING_UNDER_1");
    });
  });

  describe("mint", () => {
    it("should mint a new token with the given project and price", async () => {
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseEther("1");

      await issuer.createProject(30, "Project metadata");

      await issuer.mintTicket(minter, price);

      const tokenData = await mintTicket.tokenData(0);
      expect(tokenData.issuer).to.equal(await issuer.address);
      expect(tokenData.minter).to.equal(minter);
      expect(tokenData.price).to.equal(price);
    });

    it("should revert if the project does not exist", async () => {
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseEther("1");

      await expect(issuer.mintTicket(minter, price)).to.be.revertedWith(
        "PROJECT_DOES_NOT_EXISTS"
      );
    });

    it("should set the price to min price if the price is below the minimum price", async () => {
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseEther("0.001");
      const minprice = ethers.utils.parseEther("0.1");
      await mintTicket.setMinPrice(minprice);
      await issuer.createProject(30, "Project metadata");
      await issuer.mintTicket(minter, price);

      const tokenData = await mintTicket.tokenData(0);
      expect(tokenData.issuer).to.equal(await issuer.address);
      expect(tokenData.minter).to.equal(minter);
      expect(tokenData.price).to.equal(minprice);
    });
  });

  describe("updatePrice", () => {
    it("should update the price of the token", async () => {
      const tokenId = 0;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseEther("1");
      const newPrice = ethers.utils.parseEther("2");
      const gracingPeriod = 30;
      const coverage = gracingPeriod + 1; // Set coverage outside the gracing period

      await issuer.createProject(gracingPeriod, "Project metadata");
      await issuer.mintTicket(minter, price);

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
      const projectId = issuer.address;
      const tokenId = 0;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseEther("1");
      const newPrice = ethers.utils.parseEther("2");
      const coverage = 10;

      await issuer.createProject(30, "Project metadata");
      await issuer.mintTicket(minter, price);

      await expect(
        mintTicket.connect(fxHashAdmin).updatePrice(tokenId, newPrice, coverage)
      ).to.be.revertedWith("INSUFFICIENT_BALANCE");
    });

    it("should revert if the new price is below the minimum price", async () => {
      const projectId = issuer.address;
      const tokenId = 0;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseEther("1");
      const newPrice = ethers.utils.parseEther("0.001");
      const coverage = 10;

      await mintTicket.setMinPrice(ethers.utils.parseEther("0.1"));
      await issuer.createProject(30, "Project metadata");
      await issuer.mintTicket(minter, price);

      await expect(
        mintTicket.connect(nonAdmin).updatePrice(tokenId, newPrice, coverage)
      ).to.be.revertedWith("PRICE_BELOW_MIN_PRICE");
    });

    it("should revert if the coverage is less than 1", async () => {
      const projectId = issuer.address;
      const tokenId = 0;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseEther("1");
      const newPrice = ethers.utils.parseEther("2");
      const coverage = 0;

      await issuer.createProject(30, "Project metadata");
      await issuer.mintTicket(minter, price);

      await expect(
        mintTicket.connect(nonAdmin).updatePrice(tokenId, newPrice, coverage)
      ).to.be.revertedWith("MIN_1_COVERAGE");
    });
  });

  describe("payTax", () => {
    it("should pay the tax and update the taxationLocked", async () => {
      const projectId = issuer.address;
      const tokenId = 0;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseEther("1");

      await issuer.createProject(30, "Project metadata");
      await issuer.mintTicket(minter, price);

      const tokenDataBefore = await mintTicket.tokenData(tokenId);
      const taxAmount = ethers.utils.parseEther("0.01");

      const tokenData = await mintTicket.tokenData(tokenId);
      const dailyTax = tokenData.price.mul(14).div(10000);
      const daysCoverage = taxAmount.div(dailyTax);
      const cleanCoverage = dailyTax.mul(daysCoverage);

      await mintTicket.payTax(tokenId, { value: taxAmount });

      const tokenDataAfter = await mintTicket.tokenData(tokenId);
      const taxationLockedDiff = tokenDataAfter.taxationLocked.sub(
        tokenDataBefore.taxationLocked
      );

      expect(taxationLockedDiff).to.equal(cleanCoverage);
    });

    it("should revert if the token does not exist", async () => {
      const tokenId = 0;
      const taxAmount = ethers.utils.parseEther("0.01");

      await expect(
        mintTicket.payTax(tokenId, { value: taxAmount })
      ).to.be.revertedWith("TOKEN_DOES_NOT_EXIST");
    });
  });

  describe("claim", () => {
    it("should claim the token and update the necessary values", async () => {
      const projectId = issuer.address;
      const tokenId = 0;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseUnits("1", 18);
      const coverage = 30;
      const transferTo = await admin.getAddress();

      await issuer.createProject(30, "Project metadata");
      await issuer.mintTicket(minter, price);
      // Set taxationStart to a time outside the gracing period
      const tokenDataBefore = await mintTicket.tokenData(tokenId);
      const gracingPeriod = await mintTicket.projectData(
        tokenDataBefore.issuer
      );
      const startDay = ethers.BigNumber.from(tokenDataBefore.createdAt).add(
        ethers.BigNumber.from(gracingPeriod.gracingPeriod + 1).mul(86400)
      );

      await ethers.provider.send("evm_setNextBlockTimestamp", [
        startDay.toNumber(),
      ]);

      const dailyTax = dailyTaxAmount(price);
      const taxAmount = dailyTax.mul(coverage);
      const amountRequired = taxAmount;

      const transferAmount = amountRequired.add(ethers.utils.parseEther("1")); // Adjust the transfer amount as needed

      const tx = await mintTicket
        .connect(nonAdmin)
        .claim(tokenId, price, coverage, transferTo, {
          value: transferAmount,
        });

      await tx.wait();
      const currentBlock = await ethers.provider.getBlockNumber();
      const blockTimestamp = (await ethers.provider.getBlock(currentBlock))
        .timestamp;
      const tokenData = await mintTicket.tokenData(tokenId);
      const ownerAfter = await mintTicket.ownerOf(tokenId);
      let distanceFc = await distanceForeclosure(
        price,
        tokenDataBefore,
        ethers.BigNumber.from(blockTimestamp)
      );
      if (distanceFc.toNumber() > 86400) {
        distanceFc = ethers.BigNumber.from(86400);
      }
      const newPrice = await foreclosurePrice(price, distanceFc);
      expect(ownerAfter).to.equal(transferTo);
      expect(tokenData.price).to.equal(newPrice);

      const expectedTaxationLocked = dailyTaxAmount(newPrice).mul(coverage);
      expect(tokenData.taxationLocked).to.equal(
        expectedTaxationLocked.toString()
      );

      expect(tokenData.taxationStart).to.equal(startDay);

      const [taxToPayBefore, taxToReleaseBefore] = taxRelease(
        tokenDataBefore,
        blockTimestamp
      );
      expect(tokenData.taxationLocked).to.equal(expectedTaxationLocked);
      expect(tokenData.taxationStart).to.equal(startDay);
    });

    it("should revert if the token does not exist", async () => {
      const tokenId = 0;
      const price = ethers.utils.parseEther("1");
      const coverage = 30;
      const transferTo = await admin.getAddress();

      await expect(
        mintTicket.claim(tokenId, price, coverage, transferTo, {
          value: price.mul(coverage),
        })
      ).to.be.revertedWith("TOKEN_DOES_NOT_EXIST");
    });

    it("should revert during the gracing period", async () => {
      const projectId = issuer.address;
      const tokenId = 0;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseEther("1");
      const coverage = 30;
      const transferTo = await admin.getAddress();

      await issuer.createProject(30, "Project metadata");
      await issuer.mintTicket(minter, price);

      await expect(
        mintTicket.claim(tokenId, price, coverage, transferTo, {
          value: price.mul(coverage),
        })
      ).to.be.revertedWith("GRACING_PERIOD");
    });

    it("should revert if the price is below the minimum price", async () => {
      const projectId = issuer.address;
      const tokenId = 0;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseUnits("0.00000001", 18);
      const coverage = 30;
      const transferTo = await admin.getAddress();

      await issuer.createProject(30, "Project metadata");
      await issuer.mintTicket(minter, price);
      await mintTicket.setMinPrice(10000000000000);
      // Set taxationStart to a time outside the gracing period
      const tokenDataBefore = await mintTicket.tokenData(tokenId);
      const gracingPeriod = await mintTicket.projectData(
        tokenDataBefore.issuer
      );
      const startDay = ethers.BigNumber.from(tokenDataBefore.createdAt).add(
        ethers.BigNumber.from(gracingPeriod.gracingPeriod + 1).mul(86400)
      );

      await ethers.provider.send("evm_setNextBlockTimestamp", [
        startDay.toNumber(),
      ]);

      const dailyTax = dailyTaxAmount(price);
      const taxAmount = dailyTax.mul(coverage);
      const amountRequired = taxAmount;

      const transferAmount = amountRequired.add(ethers.utils.parseEther("1")); // Adjust the transfer amount as needed

      await expect(
        mintTicket
          .connect(nonAdmin)
          .claim(tokenId, price, coverage, transferTo, {
            value: transferAmount,
          })
      ).to.be.revertedWith("PRICE_BELOW_MIN_PRICE");
    });

    it("should revert if the coverage is zero", async () => {
      const projectId = issuer.address;
      const tokenId = 0;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseUnits("1", 18);
      const coverage = 0;
      const transferTo = await admin.getAddress();

      await issuer.createProject(30, "Project metadata");
      await issuer.mintTicket(minter, price);
      // Set taxationStart to a time outside the gracing period
      const tokenDataBefore = await mintTicket.tokenData(tokenId);
      const gracingPeriod = await mintTicket.projectData(
        tokenDataBefore.issuer
      );
      const startDay = ethers.BigNumber.from(tokenDataBefore.createdAt).add(
        ethers.BigNumber.from(gracingPeriod.gracingPeriod + 1).mul(86400)
      );

      await ethers.provider.send("evm_setNextBlockTimestamp", [
        startDay.toNumber(),
      ]);

      const dailyTax = dailyTaxAmount(price);
      const taxAmount = dailyTax.mul(coverage);
      const amountRequired = taxAmount;

      const transferAmount = amountRequired.add(ethers.utils.parseEther("1")); // Adjust the transfer amount as needed

      await expect(
        mintTicket.claim(tokenId, price, coverage, transferTo, {
          value: transferAmount,
        })
      ).to.be.revertedWith("MIN_1_COVERAGE");
    });

    it("should revert if the sent amount is less than required", async () => {
      const projectId = issuer.address;
      const tokenId = 0;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseUnits("1", 18);
      const coverage = 30;
      const transferTo = await admin.getAddress();

      await issuer.createProject(30, "Project metadata");
      await issuer.mintTicket(minter, price);
      // Set taxationStart to a time outside the gracing period
      const tokenDataBefore = await mintTicket.tokenData(tokenId);
      const gracingPeriod = await mintTicket.projectData(
        tokenDataBefore.issuer
      );
      const startDay = ethers.BigNumber.from(tokenDataBefore.createdAt).add(
        ethers.BigNumber.from(gracingPeriod.gracingPeriod + 1).mul(86400)
      );

      await ethers.provider.send("evm_setNextBlockTimestamp", [
        startDay.toNumber(),
      ]);

      await expect(
        mintTicket.claim(tokenId, price, coverage, transferTo, {
          value: 0,
        })
      ).to.be.revertedWith("AMOUNT_UNDER_PRICE");
    });
  });

  describe("consume", () => {
    it("should consume a token", async () => {
      const projectId = issuer.address;
      const tokenId = 0;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseUnits("1", 18);
      await issuer.createProject(30, "Project metadata");
      await issuer.mintTicket(minter, price);
      await issuer.consume(minter, tokenId, projectId);

      const tokenData = await mintTicket.tokenData(tokenId);
      expect(tokenData.minter).to.be.equal(ethers.constants.AddressZero);

      const projectData = await mintTicket.projectData(projectId);
      expect(projectData.gracingPeriod).to.be.equal(0);
    });

    it("should not allow consuming a token that does not exist", async () => {
      const nonExistentTokenId = 999;
      const projectId = issuer.address;

      await expect(
        issuer.consume(
          await nonAdmin.getAddress(),
          nonExistentTokenId,
          projectId
        )
      ).to.be.revertedWith("TOKEN_DOES_NOT_EXIST");
    });

    it("should not allow consuming a token from the wrong owner", async () => {
      const tokenId = 0;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseUnits("1", 18);
      await issuer.createProject(30, "Project metadata");
      await issuer.mintTicket(minter, price);
      const projectId = issuer.address;

      await expect(
        issuer.consume(await admin.getAddress(), tokenId, projectId)
      ).to.be.revertedWith("INSUFFICIENT_BALANCE");
    });

    it("should not allow consuming a token with a different project ID", async () => {
      const tokenId = 0;
      const minter = await nonAdmin.getAddress();
      const price = ethers.utils.parseUnits("1", 18);
      await issuer.createProject(30, "Project metadata");
      await issuer.mintTicket(minter, price);

      await expect(
        issuer.consume(
          await nonAdmin.getAddress(),
          tokenId,
          await nonAdmin.getAddress()
        )
      ).to.be.revertedWith("WRONG_PROJECT");
    });
  });
});
