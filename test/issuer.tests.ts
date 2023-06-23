import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract, ContractFactory, Signer } from "ethers";

describe("Issuer", () => {
  let genTk;
  let admin: Signer;
  let issuer: Contract;
  let mintTicket: Contract;
  let allowMint: Contract;
  let allowMintIssuer: Contract;
  let reserveMintPass: Contract;
  let reserveWhitelist: Contract;
  let pricingFixed: Contract;
  let pricingDutch: Contract;
  let moderationTeam: Contract;
  let moderationUser: Contract;
  let moderatorToken: Contract;
  let mintPassGroup: Contract;
  let codex: Contract;
  let userActions: Contract;
  let priceManager: Contract;
  let reserveManager: Contract;
  let randomizer: Contract;
  let receiver: Signer;
  let signer: Signer;
  let treasury: Signer;
  let libReserve: Contract;
  let libPricing: Contract;
  let libIssuer: Contract;
  let addr1: Signer;
  let addr2: Signer;
  let addr3: Signer;
  const authorizations = [10, 20];

  beforeEach(async () => {
    [admin, receiver, signer, treasury, addr1, addr2, addr3] =
      await ethers.getSigners();

    const LibIssuer = await ethers.getContractFactory("LibIssuer");
    const LibReserve = await ethers.getContractFactory("LibReserve");
    const LibPricing = await ethers.getContractFactory("LibPricing");
    libIssuer = await LibIssuer.deploy();
    libPricing = await LibPricing.deploy();
    libReserve = await LibReserve.deploy();
    await libIssuer.deployed();
    await libPricing.deployed();
    await libReserve.deployed();

    const ReserveWhitelistFactory = await ethers.getContractFactory(
      "ReserveWhitelist"
    );

    reserveWhitelist = await ReserveWhitelistFactory.deploy();
    await reserveWhitelist.deployed();

    const ReserveMintPass = await ethers.getContractFactory("ReserveMintPass");
    reserveMintPass = await ReserveMintPass.deploy();
    await reserveMintPass.deployed();

    const MintPassGroup = await ethers.getContractFactory("MintPassGroup");
    mintPassGroup = await MintPassGroup.deploy(
      10, // maxPerToken
      5, // maxPerTokenPerProject
      admin.getAddress(), // publicKey
      []
    );
    await mintPassGroup.deployed();

    const ModerationToken = await ethers.getContractFactory("ModerationToken");
    moderatorToken = await ModerationToken.deploy(await admin.getAddress());
    await moderatorToken.deployed();

    const ModerationTeam = await ethers.getContractFactory("ModerationTeam");

    moderationTeam = await ModerationTeam.deploy(admin.getAddress());
    await moderationTeam.deployed();

    await moderationTeam.connect(admin).updateModerators([
      {
        moderator: await admin.getAddress(),
        authorizations,
      },
    ]);

    const ModerationUser = await ethers.getContractFactory("ModerationUser");
    moderationUser = await ModerationUser.deploy(await admin.getAddress());

    const AllowMintFactory = await ethers.getContractFactory("AllowMint");
    allowMint = await AllowMintFactory.deploy(
      await admin.getAddress(),
      moderatorToken.address,
      await admin.getAddress()
    );

    await allowMint.deployed();

    const AllowMintIssuerFactory = await ethers.getContractFactory(
      "AllowMintIssuer"
    );

    const PricingDutchAuction = await ethers.getContractFactory(
      "PricingDutchAuction"
    );
    pricingDutch = await PricingDutchAuction.deploy();
    await pricingDutch.deployed();

    const PricingFixed = await ethers.getContractFactory("PricingFixed");
    pricingFixed = await PricingFixed.deploy();
    await pricingFixed.deployed();

    const RandomizerFactory: ContractFactory = await ethers.getContractFactory(
      "Randomizer"
    );
    const IssuerFactory: ContractFactory = await ethers.getContractFactory(
      "Issuer",
      {
        libraries: {
          "contracts/libs/LibIssuer.sol:LibIssuer": libIssuer.address,
        },
      }
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

    const CodexFactory: ContractFactory = await ethers.getContractFactory(
      "Codex"
    );
    const UserActionsFactory: ContractFactory = await ethers.getContractFactory(
      "UserActions"
    );
    const PriceManagerFactory: ContractFactory =
      await ethers.getContractFactory("PricingManager");
    const ReserveManagerFactory: ContractFactory =
      await ethers.getContractFactory("ReserveManager");
    userActions = await UserActionsFactory.deploy(await admin.getAddress());
    priceManager = await PriceManagerFactory.deploy(await admin.getAddress());
    reserveManager = await ReserveManagerFactory.deploy(
      await admin.getAddress()
    );

    allowMintIssuer = await AllowMintIssuerFactory.deploy(
      await admin.getAddress(),
      moderationUser.address,
      userActions.address
    );

    await allowMintIssuer.deployed();

    issuer = await IssuerFactory.deploy(2500, 1000, await admin.getAddress());
    await issuer.deployed();

    codex = await CodexFactory.deploy(
      issuer.address,
      moderationTeam.address,
      await admin.getAddress()
    );

    await mintTicket.setIssuer(issuer.address);
    await randomizer.grantFxHashIssuerRole(issuer.address);
    await randomizer.grantFxHashIssuerRole(mintTicket.address);
    // Deploy the contract
    const genTkFactory: ContractFactory = await ethers.getContractFactory(
      "GenTk"
    );

    await priceManager
      .connect(admin)
      .setPricingContract(1, pricingFixed.address, true);
    await priceManager
      .connect(admin)
      .setPricingContract(2, pricingDutch.address, true);

    await reserveManager.setReserveMethod(1, {
      reserveContract: reserveWhitelist.address,
      enabled: true,
    });
    await reserveManager.setReserveMethod(2, {
      reserveContract: reserveMintPass.address,
      enabled: true,
    });

    genTk = await genTkFactory.deploy(
      await admin.getAddress(),
      await signer.getAddress(),
      await treasury.getAddress(),
      await issuer.address
    );
    await moderatorToken.setAddresses([
      { key: "mod", value: moderationTeam.address },
    ]);
    await moderationTeam.connect(admin).updateModerators([
      {
        moderator: await admin.getAddress(),
        authorizations,
      },
    ]);

    await moderationUser.setAddresses([
      { key: "mod", value: moderationTeam.address },
    ]);

    await issuer.connect(admin).setAddresses([
      { key: "treasury", value: await treasury.getAddress() },
      { key: "mint_ticket", value: mintTicket.address },
      { key: "gentk", value: genTk.address },
      { key: "randomizer", value: randomizer.address },
      { key: "mod_team", value: moderationTeam.address },
      { key: "al_mi", value: allowMintIssuer.address },
      { key: "al_m", value: allowMint.address },
      { key: "user_mod", value: moderationUser.address },
      { key: "codex", value: codex.address },
      { key: "userAct", value: userActions.address },
      { key: "priceMag", value: priceManager.address },
      { key: "resMag", value: reserveManager.address },
    ]);

    await pricingDutch.connect(admin).authorizeCaller(issuer.address);
    await pricingFixed.connect(admin).authorizeCaller(issuer.address);

    await codex.connect(admin).authorizeCaller(issuer.address);
    await userActions.connect(admin).authorizeCaller(issuer.address);
    await userActions.connect(admin).authorizeCaller(allowMint.address);
    await userActions.connect(admin).authorizeCaller(allowMintIssuer.address);
    await priceManager.connect(admin).authorizeCaller(issuer.address);
    await reserveManager.connect(admin).authorizeCaller(issuer.address);
  });

  describe("Mint issuer", function () {
    it("It should successfully mint an issuer token", async function () {
      const timestamp = 1735589600;
      const price = 1000;
      const whitelist = [
        {
          whitelisted: await addr1.getAddress(),
          amount: 10,
        },
        {
          whitelisted: await addr2.getAddress(),
          amount: 5,
        },
        {
          whitelisted: await addr3.getAddress(),
          amount: 3,
        },
      ];
      const mintIssuerInput = {
        codex: {
          inputType: 1,
          value: ethers.utils.formatBytes32String("Test"),
          codexId: 0,
        },
        metadata: ethers.utils.formatBytes32String("Metadata"),
        inputBytesSize: 256,
        amount: 1000,
        openEditions: {
          closingTime: 0,
          extra: "0x",
        },
        mintTicketSettings: {
          gracingPeriod: 0,
          metadata: "0x",
        },
        reserves: [
          {
            methodId: 1,
            amount: 1,
            data: ethers.utils.defaultAbiCoder.encode(
              ["tuple(address,uint256)[]"],
              [whitelist.map((entry) => [entry.whitelisted, entry.amount])]
            ),
          },
        ],
        pricing: {
          pricingId: 1,
          details: ethers.utils.defaultAbiCoder.encode(
            ["uint256", "uint256"],
            [price, timestamp - 1]
          ),
          lockForReserves: true,
        },
        primarySplit: {
          percent: 1500,
          receiver: await receiver.getAddress(),
        },
        royaltiesSplit: {
          percent: 1000,
          receiver: await receiver.getAddress(),
        },
        enabled: true,
        tags: [1, 2, 3],
      };
      // Mint issuer using the input
      await ethers.provider.send("evm_setNextBlockTimestamp", [timestamp]);
      await issuer.connect(receiver).mintIssuer(mintIssuerInput);
      const issuerData = await issuer.getIssuer(0);
      expect(issuerData.metadata).to.equal(mintIssuerInput.metadata);
      expect(issuerData.balance).to.equal(mintIssuerInput.amount);
      expect(issuerData.iterationsCount).to.equal(0);
      expect(issuerData.supply).to.equal(mintIssuerInput.amount);
      expect(issuerData.openEditions.closingTime).to.equal(
        mintIssuerInput.openEditions.closingTime
      );
      expect(issuerData.reserves).to.deep.equal(
        ethers.utils.defaultAbiCoder.encode(
          ["tuple(uint256,uint256,bytes)[]"],
          [
            mintIssuerInput.reserves.map((entry) => [
              entry.methodId,
              entry.amount,
              entry.data,
            ]),
          ]
        )
      );
      expect(issuerData.primarySplit.percent).to.equal(
        mintIssuerInput.primarySplit.percent
      );
      expect(issuerData.primarySplit.receiver).to.equal(
        mintIssuerInput.primarySplit.receiver
      );
      expect(issuerData.royaltiesSplit.percent).to.equal(
        mintIssuerInput.royaltiesSplit.percent
      );
      expect(issuerData.royaltiesSplit.receiver).to.equal(
        mintIssuerInput.royaltiesSplit.receiver
      );
      expect(issuerData.info.tags).to.deep.equal(mintIssuerInput.tags);
      expect(issuerData.info.enabled).to.equal(mintIssuerInput.enabled);
      expect(issuerData.info.lockedSeconds).to.equal(0);
      expect(issuerData.info.timestampMinted).to.equal(timestamp);
      expect(issuerData.info.lockPriceForReserves).to.equal(
        mintIssuerInput.pricing.lockForReserves
      );
      expect(issuerData.info.hasTickets).to.equal(false);
      expect(issuerData.info.author).to.equal(await receiver.getAddress());
      expect(issuerData.info.pricingId).to.equal(
        mintIssuerInput.pricing.pricingId
      );
      expect(issuerData.info.codexId).to.equal(mintIssuerInput.codex.codexId);
      expect(issuerData.info.inputBytesSize).to.equal(
        mintIssuerInput.inputBytesSize
      );
    });
  });
});
