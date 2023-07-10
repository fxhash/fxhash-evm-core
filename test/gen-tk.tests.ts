import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract, ContractFactory, Signer } from "ethers";
import { admin } from "../typechain-types/contracts/abstract";

describe("GenTk", () => {
  let genTk: Contract;
  let mockIssuer: Contract;
  let configurationManager: Contract;

  let owner: Signer;
  let receiver: Signer;
  let signer: Signer;
  let treasury: Signer;

  const tokenId = 0;
  const metadata = "ipfs://1234";

  beforeEach(async () => {
    [owner, receiver, signer, treasury] = await ethers.getSigners();

    const MockIssuerFactory: ContractFactory = await ethers.getContractFactory(
      "MockIssuer"
    );
    mockIssuer = await MockIssuerFactory.deploy(await owner.getAddress());

    const ConfigurationManager = await ethers.getContractFactory(
      "ConfigurationManager"
    );

    // Deploy the contract and wait for it to be mined
    configurationManager = await ConfigurationManager.deploy();
    await configurationManager.deployed();

    // Deploy the contract
    const genTkFactory: ContractFactory = await ethers.getContractFactory(
      "GenTk"
    );
    genTk = await genTkFactory.deploy(
      await owner.getAddress(),
      mockIssuer.address,
      configurationManager.address
    );
  });

  it("should mint a token", async () => {
    // Prepare token parameters

    // Mint the token
    await mockIssuer.connect(owner).mint({
      tokenId: tokenId,
      receiver: await receiver.getAddress(),
      issuerId: 0,
      iteration: 1,
      inputBytes: "0x",
      metadata: "",
      royaltyReceiver: await receiver.getAddress(),
      royaltyShare: 10,
    });

    // Check the token data
    const tokenData = await genTk.getTokenData(tokenId);
    expect(tokenData.issuerId).to.equal(0);
    expect(tokenData.iteration).to.equal(1);
    expect(tokenData.inputBytes).to.equal("0x");
    expect(tokenData.minter).to.equal(await receiver.getAddress());

    // Check the token URI
    const tokenURI = await genTk.tokenURI(tokenId);
    expect(tokenURI).to.equal(metadata);
  });

  it("should assign metadata to tokens", async () => {
    // Prepare token metadata
    const tokenMetadata = [
      { tokenId: 1, metadata: "ipfs://abcd" },
      { tokenId: 2, metadata: "ipfs://efgh" },
    ];

    // Mint the tokens
    await genTk.connect(issuer).mint({
      tokenId: 1,
      receiver: await receiver.getAddress(),
      issuerId: 1,
      iteration: 1,
      inputBytes: "0x",
      metadata: "",
      royaltyReceiver: await receiver.getAddress(),
      royaltyShare: 10,
    });
    await genTk.connect(issuer).mint({
      tokenId: 2,
      receiver: await receiver.getAddress(),
      issuerId: 1,
      iteration: 1,
      inputBytes: "0x",
      metadata: "",
      royaltyReceiver: await receiver.getAddress(),
      royaltyShare: 10,
    });

    // Assign metadata to tokens
    await genTk.connect(signer).assignMetadata(tokenMetadata);

    // Check the token URIs
    const token1URI = await genTk.tokenURI(0);
    expect(token1URI).to.equal(tokenMetadata[0].metadata);
    const token2URI = await genTk.tokenURI(1);
    expect(token2URI).to.equal(tokenMetadata[1].metadata);
  });

  it("should set the signer", async () => {
    // Set the signer
    const newSigner = await signer.getAddress();
    await genTk.connect(owner).setSigner(await owner.getAddress());

    // // Check the signer
    // const contractSigner = await genTk.signer.getAddress();
    // expect(contractSigner).to.equal(await owner.getAddress());
  });

  it("should set the treasury", async () => {
    // Set the treasury
    const newTreasury = await treasury.getAddress();
    await genTk.connect(owner).setTreasury(newTreasury);

    // // Check the treasury
    // const contractTreasury = await genTk.treasury();
    // expect(contractTreasury).to.equal(newTreasury);
  });

  it("should transfer the treasury balance", async () => {
    const amount = ethers.utils.parseEther("1");
    await owner.sendTransaction({
      to: genTk.address,
      value: amount,
    });
    const preTreasuryBalance = await ethers.provider.getBalance(
      await treasury.getAddress()
    );
    // Transfer the treasury balance
    await genTk.connect(owner).transferTreasury(amount);

    // Check the treasury balance
    const treasuryBalance = await ethers.provider.getBalance(
      await treasury.getAddress()
    );
    expect(treasuryBalance).to.equal(preTreasuryBalance.add(amount));
  });
});
