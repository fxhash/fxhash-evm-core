// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";

import {AllowMint} from "contracts/allow-mint/AllowMint.sol";
import {AllowMintIssuer} from "contracts/allow-mint/AllowMintIssuer.sol";
import {ConfigurationManager} from "contracts/issuer/ConfigurationManager.sol";
import {ContentStore} from "contracts/scripty/dependencies/ethfs/ContentStore.sol";
import {GenTk} from "contracts/gentk/GenTk.sol";
import {Issuer} from "contracts/issuer/Issuer.sol";
import {MintPassGroup} from "contracts/mint-pass-group/MintPassGroup.sol";
import {MintTicket} from "contracts/mint-ticket/MintTicket.sol";
import {ModerationIssuer} from "contracts/moderation/ModerationIssuer.sol";
import {ModerationTeam} from "contracts/moderation/ModerationTeam.sol";
import {ModerationUser} from "contracts/moderation/ModerationUser.sol";
import {OnChainTokenMetadataManager} from "contracts/issuer/OnChainTokenMetadataManager.sol";
import {PricingDutchAuction} from "contracts/pricing/PricingDutchAuction.sol";
import {PricingFixed} from "contracts/pricing/PricingFixed.sol";
import {PricingManager} from "contracts/issuer/PricingManager.sol";
import {Randomizer} from "contracts/randomizer/Randomizer.sol";
import {ReserveManager} from "contracts/issuer/ReserveManager.sol";
import {ReserveMintPass} from "contracts/reserve/ReserveMintPass.sol";
import {ReserveWhitelist} from "contracts/reserve/ReserveWhitelist.sol";
import {ScriptyBuilder} from "contracts/scripty/ScriptyBuilder.sol";
import {ScriptyStorage} from "contracts/scripty/ScriptyStorage.sol";

contract Deploy is Script {
    // Contracts
    AllowMint allowMint;
    AllowMintIssuer allowMintIssuer;
    ConfigurationManager configurationManager;
    ContentStore contentStore;
    GenTk genTk;
    Issuer issuer;
    MintPassGroup mintPassGroup;
    MintTicket mintTicket;
    ModerationIssuer moderationIssuer;
    ModerationTeam moderationTeam;
    ModerationUser moderationUser;
    OnChainTokenMetadataManager onchainMetadataManager;
    PricingDutchAuction pricingDA;
    PricingFixed pricingFixed;
    PricingManager pricingManager;
    Randomizer randomizer;
    ReserveManager reserveManager;
    ReserveMintPass reserveMintPass;
    ReserveWhitelist reserveWhitelist;
    ScriptyBuilder scriptyBuilder;
    ScriptyStorage scriptyStorage;

    // Users
    address admin;
    address signer;
    address treasury;
    address alice;
    address bob;
    address eve;
    address susan;

    // State
    address[] bypass = new address[](0);

    // Constants
    uint256 constant BALANCE = 100 ether;
    uint256 constant MAX_PER_TOKEN = 10;
    uint256 constant MAX_PER_TOKEN_PER_PROJECT = 5;
    bytes32 constant SALT = keccak256("salt");
    bytes32 constant SEED = keccak256("seed");

    function run() public {
        vm.startBroadcast();
        setUp();
        deploy();
        vm.stopBroadcast();
    }

    function setUp() public {
        admin = _createUser("admin");
        signer = _createUser("signer");
        treasury = _createUser("treasury");
        alice = _createUser("alice");
        bob = _createUser("bob");
        eve = _createUser("eve");
        susan = _createUser("susan");
    }

    function deploy() public {
        // Scripty
        contentStore = new ContentStore();
        scriptyBuilder = new ScriptyBuilder();
        scriptyStorage = new ScriptyStorage(address(contentStore));

        // Moderation
        moderationIssuer = new ModerationIssuer(admin);
        moderationUser = new ModerationUser(admin);
        moderationTeam = new ModerationTeam();

        // Allow Mint
        allowMint = new AllowMint(admin);
        allowMintIssuer = new AllowMintIssuer(address(moderationUser));

        // Reserve
        reserveManager = new ReserveManager();
        reserveMintPass = new ReserveMintPass(address(reserveManager));
        reserveWhitelist = new ReserveWhitelist();

        // Pricing
        pricingManager = new PricingManager();
        pricingDA = new PricingDutchAuction();
        pricingFixed = new PricingFixed();

        // Randomizer
        randomizer = new Randomizer(SEED, SALT);

        // Mint Ticket
        mintTicket = new MintTicket(address(randomizer));

        // Mint Pass Group
        mintPassGroup = new MintPassGroup(
            MAX_PER_TOKEN,
            MAX_PER_TOKEN_PER_PROJECT,
            signer,
            address(reserveMintPass),
            bypass
        );

        // Issuer
        configurationManager = new ConfigurationManager();
        issuer = new Issuer(address(configurationManager), admin);
        onchainMetadataManager = new OnChainTokenMetadataManager(address(scriptyBuilder));

        // Generative Token
        genTk = new GenTk(admin, address(issuer), address(configurationManager));
    }

    function _createUser(string memory _name) internal returns (address user) {
        user = address(uint160(uint256(keccak256(abi.encodePacked(_name)))));
        vm.deal(user, BALANCE);
        vm.label(user, _name);
    }
}
