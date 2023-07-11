// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {AllowMint} from "contracts/allow-mint/AllowMint.sol";
import {AllowMintIssuer} from "contracts/allow-mint/AllowMintIssuer.sol";
import {Codex} from "contracts/issuer/Codex.sol";
import {ConfigurationManager} from "contracts/issuer/ConfigurationManager.sol";
import {ContentStore} from "contracts/scripty/dependencies/ethfs/ContentStore.sol";
import {GenTk} from "contracts/gentk/GenTk.sol";
import {Issuer} from "contracts/issuer/Issuer.sol";
import {Marketplace} from "contracts/marketplace/Marketplace.sol";
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
    AllowMint public allowMint;
    AllowMintIssuer public allowMintIssuer;
    Codex public codex;
    ConfigurationManager public configurationManager;
    ContentStore public contentStore;
    GenTk public genTk;
    Issuer public issuer;
    Marketplace public marketplace;
    MintPassGroup public mintPassGroup;
    MintTicket public mintTicket;
    ModerationIssuer public moderationIssuer;
    ModerationTeam public moderationTeam;
    ModerationUser public moderationUser;
    OnChainTokenMetadataManager public onchainMetadataManager;
    PricingDutchAuction public pricingDA;
    PricingFixed public pricingFixed;
    PricingManager pricingManager;
    Randomizer public randomizer;
    ReserveManager public reserveManager;
    ReserveMintPass public reserveMintPass;
    ReserveWhitelist public reserveWhitelist;
    ScriptyBuilder public scriptyBuilder;
    ScriptyStorage public scriptyStorage;

    // Users
    address public admin;
    address public signer;
    address public treasury;
    address public alice;
    address public bob;
    address public eve;
    address public susan;

    // State
    address[] public bypass = new address[](0);

    // Constants
    uint256 public constant BALANCE = 100 ether;
    uint256 public constant MAX_PER_TOKEN = 10;
    uint256 public constant MAX_PER_TOKEN_PER_PROJECT = 5;
    uint256 public constant MAX_REFERRAL_SHARE = 1000;
    uint256 public constant PLATFORM_FEES = 1000;
    uint256 public constant REFERRAL_SHARE = 1000;
    bytes32 public constant SALT = keccak256("salt");
    bytes32 public constant SEED = keccak256("seed");

    function setUp() public {
        createAccounts();
    }

    function createAccounts() public {
        admin = _createUser("admin");
        signer = _createUser("signer");
        treasury = _createUser("treasury");
        alice = _createUser("alice");
        bob = _createUser("bob");
        eve = _createUser("eve");
        susan = _createUser("susan");
    }

    function run() public {
        vm.startBroadcast();
        deployContracts();
        vm.stopBroadcast();
    }

    function deployContracts() public {
        // Configuration
        configurationManager = new ConfigurationManager();

        // Scripty
        contentStore = new ContentStore();
        scriptyBuilder = new ScriptyBuilder();
        scriptyStorage = new ScriptyStorage(address(contentStore));

        // Metadata
        onchainMetadataManager = new OnChainTokenMetadataManager(address(scriptyBuilder));

        // Moderation
        moderationIssuer = new ModerationIssuer(address(configurationManager));
        moderationUser = new ModerationUser(address(configurationManager));
        moderationTeam = new ModerationTeam();

        // Allowlist
        allowMint = new AllowMint(address(moderationIssuer));
        allowMintIssuer = new AllowMintIssuer(address(moderationUser));

        // Codex
        codex = new Codex(address(moderationTeam));

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

        // Marketplace
        marketplace = new Marketplace(
            admin,
            MAX_REFERRAL_SHARE,
            REFERRAL_SHARE,
            PLATFORM_FEES,
            treasury
        );

        // Mint Ticket
        mintTicket = new MintTicket(address(randomizer));

        // Mint Pass
        mintPassGroup = new MintPassGroup(
            MAX_PER_TOKEN,
            MAX_PER_TOKEN_PER_PROJECT,
            signer,
            address(reserveMintPass),
            bypass
        );

        // Issuer
        issuer = new Issuer(address(configurationManager), alice);

        // Token
        genTk = new GenTk(alice, address(issuer), address(configurationManager));
    }

    function _createUser(string memory _name) internal returns (address user) {
        user = address(uint160(uint256(keccak256(abi.encodePacked(_name)))));
        vm.deal(user, BALANCE);
        vm.label(user, _name);
    }
}
