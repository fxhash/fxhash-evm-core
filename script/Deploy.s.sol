// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {FxContractRegistry} from "src/registries/FxContractRegistry.sol";
import {FxGenArt721, GenArtInfo, IssuerInfo, MetadataInfo, MintInfo, ProjectInfo, ReserveInfo} from "src/tokens/FxGenArt721.sol";
import {FxIssuerFactory, ConfigInfo} from "src/factories/FxIssuerFactory.sol";
import {FxPsuedoRandomizer} from "src/randomizers/FxPsuedoRandomizer.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";
import {FxSplitsFactory} from "src/factories/FxSplitsFactory.sol";
import {FxTokenRenderer} from "src/renderers/FxTokenRenderer.sol";
import {HTMLRequest} from "scripty.sol/contracts/scripty/core/ScriptyStructs.sol";
import {Script} from "forge-std/Script.sol";

import "script/utils/Constants.sol";
import "src/utils/Constants.sol";
import "test/utils/Constants.sol";

contract Deploy is Script {
    // Contracts
    FxContractRegistry internal fxContractRegistry;
    FxGenArt721 internal fxGenArt721;
    FxIssuerFactory internal fxIssuerFactory;
    FxPsuedoRandomizer internal fxPseudoRandomizer;
    FxRoleRegistry internal fxRoleRegistry;
    FxSplitsFactory internal fxSplitsFactory;
    FxTokenRenderer internal fxTokenRenderer;

    // Accounts
    address internal admin;
    address internal creator;
    address internal minter;
    address internal tokenMod;
    address internal userMod;

    // Structs
    ConfigInfo internal configInfo;
    IssuerInfo internal isserInfo;
    GenArtInfo internal genArtInfo;
    MetadataInfo internal metadataInfo;
    MintInfo[] internal mintInfo;
    ProjectInfo internal projectInfo;
    ReserveInfo internal reserveInfo;

    // Project
    address internal fxGenArtProxy;
    address internal owner;
    address internal primaryReceiver;
    uint96 internal projectId;
    string internal contractURI;

    // Token
    uint256 internal tokenId;
    bytes32 internal seed;
    bytes internal fxParams;

    // Metadata
    string internal baseURI;
    string internal imageURI;
    HTMLRequest internal animation;
    HTMLRequest internal attributes;

    // Registries
    bytes32[] names;
    address[] contracts;

    // Royalties
    address payable[] internal royaltyReceivers;
    uint96[] internal basisPoints;

    // Splits
    address[] internal accounts;
    uint32[] internal allocations;

    function setUp() public virtual {
        _createAccounts();
    }

    function run() public virtual {
        vm.startBroadcast();
        _deployContracts();
        _createSplit();
        _registerMinter(minter);
        _createProject();
        _configureSettings();
        vm.stopBroadcast();
    }

    function _createAccounts() internal {
        admin = msg.sender;
        creator = _createUser("creator");
        minter = _createUser("minter");
        tokenMod = _createUser("tokenMod");
        userMod = _createUser("userMod");
    }

    function _deployContracts() internal {
        fxContractRegistry = new FxContractRegistry();
        fxRoleRegistry = new FxRoleRegistry();
        fxSplitsFactory = new FxSplitsFactory();
        fxPseudoRandomizer = new FxPsuedoRandomizer();
        fxTokenRenderer = new FxTokenRenderer(
            ETHFS_FILE_STORAGE,
            SCRIPTY_STORAGE_V2,
            SCRIPTY_BUILDER_V2
        );
        fxGenArt721 = new FxGenArt721(
            address(fxContractRegistry),
            address(fxRoleRegistry)
        );
        fxIssuerFactory = new FxIssuerFactory(address(fxGenArt721), configInfo);
    }

    function _registerContracts() internal {
        names[0] = FX_CONTRACT_REGISTRY;
        names[1] = FX_GEN_ART_721;
        names[2] = FX_ISSUER_FACTORY;
        names[3] = FX_PSUEDO_RANDOMIZER;
        names[4] = FX_ROLE_REGISTRY;
        names[5] = FX_SPLITS_FACTORY;
        names[6] = FX_TOKEN_RENDERER;

        contracts[0] = address(fxContractRegistry);
        contracts[1] = address(fxGenArt721);
        contracts[2] = address(fxIssuerFactory);
        contracts[3] = address(fxPseudoRandomizer);
        contracts[4] = address(fxRoleRegistry);
        contracts[5] = address(fxSplitsFactory);
        contracts[6] = address(fxTokenRenderer);

        fxContractRegistry.setContracts(names, contracts);
    }

    function _createSplit() internal {
        accounts.push(creator);
        accounts.push(admin);
        allocations.push(SPLITS_CREATOR_ALLOCATION);
        allocations.push(SPLITS_ADMIN_ALLOCATION);
        primaryReceiver = fxSplitsFactory.createSplit(accounts, allocations);
    }

    function _createProject() internal {
        fxGenArtProxy = fxIssuerFactory.createProject(
            creator,
            primaryReceiver,
            projectInfo,
            metadataInfo,
            mintInfo,
            royaltyReceivers,
            basisPoints
        );
    }

    function _registerMinter(address _minter) internal {
        fxRoleRegistry.grantRole(MINTER_ROLE, _minter);
    }

    function _configureSettings() internal {
        configInfo.feeShare = CONFIG_FEE_SHARE;
        configInfo.lockTime = CONFIG_LOCK_TIME;
        configInfo.defaultMetadata = CONFIG_DEFAULT_METADATA;
        fxIssuerFactory.setConfig(configInfo);

        FxGenArt721(fxGenArtProxy).setRandomizer(address(fxPseudoRandomizer));
        FxGenArt721(fxGenArtProxy).setRenderer(address(fxTokenRenderer));
    }

    function _createUser(string memory _user) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(_user)))));
    }
}
