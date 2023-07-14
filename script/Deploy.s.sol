// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {AllowMint} from "contracts/allow-mint/AllowMint.sol";
import {AllowMintIssuer} from "contracts/allow-mint/AllowMintIssuer.sol";
import {Codex} from "contracts/issuer/Codex.sol";
import {ConfigurationManager, IConfigurationManager} from "contracts/issuer/ConfigurationManager.sol";
import {ContentStore} from "scripty.sol/contracts/scripty/dependencies/ethfs/ContentStore.sol";
import {GenTk} from "contracts/gentk/GenTk.sol";
import {Issuer} from "contracts/issuer/Issuer.sol";
import {LibReserve} from "contracts/libs/LibReserve.sol";
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
import {ReserveManager, IReserve} from "contracts/issuer/ReserveManager.sol";
import {ReserveMintPass} from "contracts/reserve/ReserveMintPass.sol";
import {ReserveWhitelist} from "contracts/reserve/ReserveWhitelist.sol";
import {ScriptyBuilder} from "scripty.sol/contracts/scripty/ScriptyBuilder.sol";
import {ScriptyStorage} from "scripty.sol/contracts/scripty/ScriptyStorage.sol";

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
    PricingManager public pricingManager;
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
    address public moderator;
    address public alice;
    address public bob;
    address public eve;
    address public susan;

    // State
    uint256[] public authorizations = [10, 20];
    address[] public bypass = new address[](0);

    // Constants
    uint256 public constant BALANCE = 100 ether;
    uint256 public constant MAX_PER_TOKEN = 10;
    uint256 public constant MAX_PER_TOKEN_PER_PROJECT = 5;
    uint256 public constant ISSUER_FEES = 1000;
    uint256 public constant ISSUER_LOCK_TIME = 1000;
    uint256 public constant ISSUER_REFERRAL_SHARE = 1000;
    uint256 public constant MARKETPLACE_MAX_REFERRAL_SHARE = 1000;
    uint256 public constant MARKETPLACE_PLATFORM_FEES = 1000;
    uint256 public constant MARKETPLACE_REFERRAL_SHARE = 1000;
    bytes32 public constant SALT = keccak256("salt");
    bytes32 public constant SEED = keccak256("seed");
    string public constant ISSUER_VOID_METADATA = "1000";

    function setUp() public virtual {
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
        configureContracts();
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
            MARKETPLACE_MAX_REFERRAL_SHARE,
            MARKETPLACE_REFERRAL_SHARE,
            MARKETPLACE_PLATFORM_FEES,
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

    function configureContracts() public {
        ModerationTeam.UpdateModeratorParam[]
            memory moderators = new ModerationTeam.UpdateModeratorParam[](1);
        IConfigurationManager.ContractEntry[]
            memory contractEntries = new IConfigurationManager.ContractEntry[](11);

        moderators[0] = ModerationTeam.UpdateModeratorParam({
            moderator: moderator,
            authorizations: authorizations
        });

        contractEntries[0] = IConfigurationManager.ContractEntry({
            key: "treasury",
            value: treasury
        });
        contractEntries[1] = IConfigurationManager.ContractEntry({
            key: "mint_tickets",
            value: address(mintTicket)
        });
        contractEntries[2] = IConfigurationManager.ContractEntry({
            key: "gentk",
            value: address(genTk)
        });
        contractEntries[3] = IConfigurationManager.ContractEntry({
            key: "randomizer",
            value: address(randomizer)
        });
        contractEntries[4] = IConfigurationManager.ContractEntry({
            key: "mod_team",
            value: address(moderationTeam)
        });
        contractEntries[5] = IConfigurationManager.ContractEntry({
            key: "al_mi",
            value: address(allowMintIssuer)
        });
        contractEntries[6] = IConfigurationManager.ContractEntry({
            key: "al_m",
            value: address(allowMint)
        });
        contractEntries[7] = IConfigurationManager.ContractEntry({
            key: "user_mod",
            value: address(moderationUser)
        });
        contractEntries[8] = IConfigurationManager.ContractEntry({
            key: "codex",
            value: address(codex)
        });
        contractEntries[9] = IConfigurationManager.ContractEntry({
            key: "priceMag",
            value: address(pricingManager)
        });
        contractEntries[10] = IConfigurationManager.ContractEntry({
            key: "resMag",
            value: address(reserveManager)
        });

        // Authorize signer on Randomizer
        randomizer.grantAuthorizedCallerRole(signer);

        // Register a moderator
        moderationTeam.updateModerators(moderators);

        // Set pricing methods
        pricingManager.setPricingContract(1, address(pricingFixed), true);
        pricingManager.setPricingContract(2, address(pricingDA), true);

        // Set reserve methods
        reserveManager.setReserveMethod(
            1,
            LibReserve.ReserveMethod({reserveContract: IReserve(reserveWhitelist), enabled: true})
        );
        reserveManager.setReserveMethod(
            2,
            LibReserve.ReserveMethod({reserveContract: IReserve(reserveMintPass), enabled: true})
        );

        configurationManager.setAddresses(contractEntries);

        configurationManager.setConfig(
            IConfigurationManager.Config({
                fees: ISSUER_FEES,
                referrerFeesShare: ISSUER_REFERRAL_SHARE,
                lockTime: ISSUER_LOCK_TIME,
                voidMetadata: ISSUER_VOID_METADATA
            })
        );
    }

    function _createUser(string memory _name) internal returns (address user) {
        user = address(uint160(uint256(keccak256(abi.encodePacked(_name)))));
        vm.deal(user, BALANCE);
        vm.label(user, _name);
    }
}
