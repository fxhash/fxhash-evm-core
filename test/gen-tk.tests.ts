import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract, ContractFactory, Signer } from "ethers";

describe("GenTk", () => {
  let genTk: Contract;
  let owner: Signer;
  let issuer: Signer;
  let receiver: Signer;
  let signer: Signer;
  let treasury: Signer;

  beforeEach(async () => {
    // Deploy the contract
    const genTkFactory: ContractFactory = await ethers.getContractFactory(
      "GenTk"
    );
    [owner, issuer, receiver, signer, treasury] = await ethers.getSigners();
    genTk = await genTkFactory.deploy(
      await owner.getAddress(),
      await signer.getAddress(),
      await treasury.getAddress(),
      await issuer.getAddress()
    );
  });

  it("should mint a token", async () => {
    // Prepare token parameters
    const tokenId = 1;
    const metadata = "ipfs://1234";

    // Mint the token
    await genTk.connect(issuer).mint({
      tokenId,
      receiver: await receiver.getAddress(),
      issuerId: 1,
      iteration: 1,
      inputBytes: "0x",
      metadata,
      royaltyReceiver: await receiver.getAddress(),
      royaltyShare: 10,
    });

    // Check the token data
    const tokenData = await genTk.getTokenData(tokenId);
    expect(tokenData.issuerId).to.equal(1);
    expect(tokenData.iteration).to.equal(1);
    expect(tokenData.inputBytes).to.equal("0x");
    expect(tokenData.minter).to.equal(await receiver.getAddress());
    expect(tokenData.royaltyShare).to.equal(10);
    expect(tokenData.royaltyReceiver).to.equal(await receiver.getAddress());

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
    const token1URI = await genTk.tokenURI(1);
    expect(token1URI).to.equal(tokenMetadata[0].metadata);
    const token2URI = await genTk.tokenURI(2);
    expect(token2URI).to.equal(tokenMetadata[1].metadata);
  });

  it("should set the signer", async () => {
    // Set the signer
    const newSigner = await signer.getAddress();
    await genTk.connect(owner).setSigner(await owner.getAddress());

    // Check the signer
    const contractSigner = await genTk.signer.getAddress();
    expect(contractSigner).to.equal(await owner.getAddress());
  });

  it("should set the treasury", async () => {
    // Set the treasury
    const newTreasury = await treasury.getAddress();
    await genTk.connect(owner).setTreasury(newTreasury);

    // Check the treasury
    const contractTreasury = await genTk.treasury();
    expect(contractTreasury).to.equal(newTreasury);
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
