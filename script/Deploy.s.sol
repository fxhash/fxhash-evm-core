// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Accounts} from "script/utils/Accounts.s.sol";
import {AllowMint} from "contracts/reserves/AllowMint.sol";
import {AllowMintIssuer} from "contracts/reserves/AllowMintIssuer.sol";
import {Codex} from "contracts/metadata/Codex.sol";
import {ConfigurationManager, IConfigurationManager, ConfigInfo} from "contracts/admin/ConfigurationManager.sol";
import {ContentStore} from "scripty.sol/contracts/scripty/dependencies/ethfs/ContentStore.sol";
import {FxHashFactory} from "contracts/factories/FxHashFactory.sol";
import {GenTk} from "contracts/issuer/GenTk.sol";
import {GenTkFactory} from "contracts/factories/GenTkFactory.sol";
import {IssuerFactory} from "contracts/factories/IssuerFactory.sol";
import {Issuer} from "contracts/issuer/Issuer.sol";
import {IReserve, ReserveMethod} from "contracts/interfaces/IReserve.sol";
import {MintPassGroup} from "contracts/reserves/MintPassGroup.sol";
import {MintTicket} from "contracts/reserves/MintTicket.sol";
import {ModerationIssuer} from "contracts/admin/moderation/ModerationIssuer.sol";
import {ModerationTeam} from "contracts/admin/moderation/ModerationTeam.sol";
import {ModerationUser} from "contracts/admin/moderation/ModerationUser.sol";
import {OnChainTokenMetadataManager} from "contracts/metadata/OnChainTokenMetadataManager.sol";
import {PricingDutchAuction} from "contracts/pricing/PricingDutchAuction.sol";
import {PricingFixed} from "contracts/pricing/PricingFixed.sol";
import {PricingManager} from "contracts/pricing/PricingManager.sol";
import {Randomizer} from "contracts/issuer/Randomizer.sol";
import {ReserveManager} from "contracts/reserves/ReserveManager.sol";
import {ReserveMintPass} from "contracts/reserves/ReserveMintPass.sol";
import {ReserveWhitelist} from "contracts/reserves/ReserveWhitelist.sol";
import {Script} from "forge-std/Script.sol";
import {ScriptyBuilder} from "scripty.sol/contracts/scripty/ScriptyBuilder.sol";
import {ScriptyStorage} from "scripty.sol/contracts/scripty/ScriptyStorage.sol";

import "script/utils/Constants.sol";

contract Deploy is Script, Accounts {
    // Contracts
    AllowMint public allowMint;
    AllowMintIssuer public allowMintIssuer;
    Codex public codex;
    ConfigurationManager public configurationManager;
    ContentStore public contentStore;
    GenTk public genTk;
    Issuer public issuer;
    FxHashFactory public fxHashFactory;
    GenTkFactory public genTkFactory;
    IssuerFactory public issuerFactory;
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

    // mainnet + testnet deployment addresses
    address public splitMain = 0x2ed6c4B5dA6378c7897AC67Ba9e43102Feb694EE;
    address public splitWallet = 0xD94c0CE4f8eEfA4Ebf44bf6665688EdEEf213B33;
    address public deployedAddress;

    // State
    string[] names;
    address[] contracts;
    uint256 public deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
    address public deployer = vm.addr(deployerPrivateKey);

    function setUp() public virtual override {
        vm.rememberKey(deployerPrivateKey);
    }

    function run() public virtual {
        vm.startBroadcast(deployer);
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

        // Mint Ticket
        mintTicket = new MintTicket(address(randomizer));

        // Issuer
        issuer = new Issuer();

        // Token
        genTk = new GenTk();

        fxHashFactory = new FxHashFactory(address(configurationManager));
        genTkFactory = new GenTkFactory(address(fxHashFactory), address(genTk));
        issuerFactory = new IssuerFactory(address(fxHashFactory), address(issuer));
    }

    function configureContracts() public {
        names = new string[](11);
        contracts = new address[](11);

        names[0] = "treasury";
        contracts[0] = vm.envAddress("TREASURY_ADDRESS");
        names[1] = "mint_tickets";
        contracts[1] = address(mintTicket);
        names[2] = "randomizer";
        contracts[2] = address(randomizer);
        names[3] = "mod_team";
        contracts[3] = address(moderationTeam);
        names[4] = "al_mi";
        contracts[4] = address(allowMintIssuer);
        names[5] = "al_m";
        contracts[5] = address(allowMint);
        names[6] = "user_mod";
        contracts[6] = address(moderationUser);
        names[7] = "codex";
        contracts[7] = address(codex);
        names[8] = "priceMag";
        contracts[8] = address(pricingManager);
        names[9] = "resMag";
        contracts[9] = address(reserveManager);
        names[10] = "fxHashFactory";
        contracts[10] = address(fxHashFactory);

        // Authorize signer on Randomizer
        randomizer.grantAuthorizedCallerRole(vm.addr(vm.envUint("SIGNER_PRIVATE_KEY")));

        // Set pricing methods
        pricingManager.setPricingContract(1, address(pricingFixed), true);
        pricingManager.setPricingContract(2, address(pricingDA), true);

        // Set reserve methods
        reserveManager.setReserveMethod(
            1,
            ReserveMethod({reserveContract: IReserve(reserveWhitelist), enabled: true})
        );
        reserveManager.setReserveMethod(
            2,
            ReserveMethod({reserveContract: IReserve(reserveMintPass), enabled: true})
        );

        configurationManager.setContracts(names, contracts);

        configurationManager.setConfig(
            ConfigInfo({
                feeShare: ISSUER_FEES,
                referrerShare: ISSUER_REFERRAL_SHARE,
                lockTime: ISSUER_LOCK_TIME,
                defaultMetadata: ISSUER_VOID_METADATA
            })
        );

        fxHashFactory.setGenTkFactory(address(genTkFactory));
        fxHashFactory.setIssuerFactory(address(issuerFactory));
    }

    function mock0xSplits() internal {
        bytes memory splitMainBytecode = abi.encodePacked(SPLIT_MAIN_CREATION_CODE, abi.encode());
        address deployedAddress_;
        // original deployer + original nonce used at deployment
        vm.startPrank(0x9ebC8E61f87A301fF25a606d7C06150f856F24E2);
        vm.setNonce(0x9ebC8E61f87A301fF25a606d7C06150f856F24E2, 0);
        assembly {
            deployedAddress_ := create(0, add(splitMainBytecode, 32), mload(splitMainBytecode))
        }

        deployedAddress = deployedAddress_;
    }
}
