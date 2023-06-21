import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract, ContractFactory, Signer } from "ethers";

import "contracts/interfaces/IMintTicket.sol";
import "contracts/interfaces/IReserve.sol";
import "contracts/interfaces/IPricing.sol";
import "contracts/interfaces/IAllowMintIssuer.sol";
import "contracts/interfaces/IAllowMint.sol";
import "contracts/interfaces/IModeration.sol";
import "contracts/interfaces/IModerationUser.sol";
import "contracts/interfaces/IGenTk.sol";

describe("GenTk", () => {
  let genTk: Contract;
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
  let randomizer: Contract;
  let receiver: Signer;
  let signer: Signer;
  let treasury: Signer;
  const authorizations = [10, 20];

  beforeEach(async () => {
    [admin, receiver, signer, treasury] = await ethers.getSigners();

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
    await moderatorToken.setAddress("mod", moderationTeam.address);

    await moderationTeam.connect(admin).updateModerators([
      {
        moderator: await admin.getAddress(),
        authorizations,
      },
    ]);
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
    allowMintIssuer = await AllowMintIssuerFactory.deploy(
      await admin.getAddress(),
      moderationUser.address,
      await admin.getAddress()
    );

    await allowMintIssuer.deployed();

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
    issuer = await IssuerFactory.deploy();
    await issuer.deployed();
    await mintTicket.setIssuer(issuer.address);
    await randomizer.grantFxHashIssuerRole(issuer.address);
    await randomizer.grantFxHashIssuerRole(mintTicket.address);
    // Deploy the contract
    const genTkFactory: ContractFactory = await ethers.getContractFactory(
      "GenTk"
    );
    genTk = await genTkFactory.deploy(
      await admin.getAddress(),
      await signer.getAddress(),
      await treasury.getAddress(),
      await issuer.address
    );
    await issuer.setAddresses("treasury", await treasury.getAddress());
    await issuer.setAddresses("mint_ticket", await mintTicket.address);
    await issuer.setAddresses("gentk", await genTk.address);
    await issuer.setAddresses("randomizer", await randomizer.address);
    await issuer.setAddresses("mod_team", await moderationTeam.address);
    await issuer.setAddresses("al_mi", await allowMintIssuer.address);
    await issuer.setAddresses("al_m", await allowMint.address);
    await issuer.setAddresses("user_mod", await moderationUser.address);
  });
});
