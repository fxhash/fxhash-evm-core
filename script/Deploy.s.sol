// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {FixedPrice} from "src/minters/FixedPrice.sol";
import {FxContractRegistry} from "src/registries/FxContractRegistry.sol";
import {
    FxGenArt721,
    GenArtInfo,
    IssuerInfo,
    MetadataInfo,
    MintInfo,
    ProjectInfo,
    ReserveInfo
} from "src/tokens/FxGenArt721.sol";
import {FxIssuerFactory, ConfigInfo} from "src/factories/FxIssuerFactory.sol";
import {FxPseudoRandomizer} from "src/randomizers/FxPseudoRandomizer.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";
import {FxSplitsFactory} from "src/factories/FxSplitsFactory.sol";
import {FxTokenRenderer} from "src/renderers/FxTokenRenderer.sol";
import {
    HTMLRequest,
    HTMLTagType,
    HTMLTag
} from "scripty.sol/contracts/scripty/core/ScriptyStructs.sol";
import {Script} from "forge-std/Script.sol";

import "script/utils/Constants.sol";
import "src/utils/Constants.sol";
import "test/utils/Constants.sol";

contract Deploy is Script {
    // Contracts
    FxContractRegistry internal fxContractRegistry;
    FxGenArt721 internal fxGenArt721;
    FxIssuerFactory internal fxIssuerFactory;
    FxPseudoRandomizer internal fxPseudoRandomizer;
    FxRoleRegistry internal fxRoleRegistry;
    FxSplitsFactory internal fxSplitsFactory;
    FxTokenRenderer internal fxTokenRenderer;
    FixedPrice internal fixedPrice;

    // Accounts
    address internal admin;
    address internal creator;
    address internal minter;
    address internal tokenMod;
    address internal userMod;

    // Structs
    ConfigInfo internal configInfo;
    IssuerInfo internal issuerInfo;
    GenArtInfo internal genArtInfo;
    MetadataInfo internal metadataInfo;
    MintInfo[] internal mintInfo;
    ProjectInfo internal projectInfo;
    ReserveInfo internal reserveInfo;

    // Project
    address internal fxGenArtProxy;
    address internal primaryReceiver;
    string internal contractURI;

    // Token
    uint256 internal amount;
    uint256 internal tokenId;
    bytes32 internal seed;
    bytes internal fxParams;
    uint256 internal price;

    // Metadata
    string internal baseURI;
    string internal imageURI;
    HTMLRequest internal animation;
    HTMLTag[] internal headTags;
    HTMLTag[] internal bodyTags;

    // Registries
    bytes32[] internal names;
    address[] internal contracts;

    // Royalties
    address payable[] internal royaltyReceivers;
    uint96[] internal basisPoints;

    // Splits
    address[] internal accounts;
    uint32[] internal allocations;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        _createAccounts();
        _configureState();
        _configureInfo();
        _configureProject();
        _configureSplits();
        _configureRoyalties();
        _configureScripty();
        _configureMetdata();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      RUN
    //////////////////////////////////////////////////////////////////////////*/

    function run() public virtual {
        vm.startBroadcast();
        _deployContracts();
        _configureMinters();
        _registerContracts();
        _registerRoles();
        _createSplit();
        _createProject();
        _setContracts();
        vm.stopBroadcast();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  CONFIGURATIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _configureInfo() internal {
        configInfo.feeShare = CONFIG_FEE_SHARE;
        configInfo.lockTime = CONFIG_LOCK_TIME;
        configInfo.defaultMetadata = CONFIG_DEFAULT_METADATA;
    }

    function _configureProject() internal {
        projectInfo.enabled = true;
        projectInfo.onchain = true;
        projectInfo.supply = MAX_SUPPLY;
        projectInfo.contractURI = CONTRACT_URI;
    }

    function _configureMetdata() internal {
        metadataInfo.baseURI = BASE_URI;
        metadataInfo.imageURI = IMAGE_URI;
        metadataInfo.animation = animation;
    }

    function _configureMinters() internal {
        mintInfo.push(
            MintInfo({
                minter: address(fixedPrice),
                reserveInfo: ReserveInfo({
                    startTime: RESERVE_START_TIME,
                    endTime: RESERVE_END_TIME,
                    allocation: RESERVE_ADMIN_ALLOCATION
                }),
                params: abi.encode(price)
            })
        );
    }

    function _configureRoyalties() internal {
        royaltyReceivers.push(payable(admin));
        royaltyReceivers.push(payable(creator));
        royaltyReceivers.push(payable(tokenMod));
        royaltyReceivers.push(payable(userMod));
        basisPoints.push(ROYALTY_BPS);
        basisPoints.push(ROYALTY_BPS * 2);
        basisPoints.push(ROYALTY_BPS * 3);
        basisPoints.push(ROYALTY_BPS * 4);
    }

    function _configureScripty() internal {
        headTags.push(
            HTMLTag({
                name: CSS_CANVAS_SCRIPT,
                contractAddress: ETHFS_FILE_STORAGE,
                contractData: bytes(""),
                tagType: HTMLTagType.useTagOpenAndClose,
                tagOpen: TAG_OPEN,
                tagClose: TAG_CLOSE,
                tagContent: bytes("")
            })
        );

        bodyTags.push(
            HTMLTag({
                name: P5_JS_SCRIPT,
                contractAddress: ETHFS_FILE_STORAGE,
                contractData: bytes(""),
                tagType: HTMLTagType.scriptGZIPBase64DataURI,
                tagOpen: bytes(""),
                tagClose: bytes(""),
                tagContent: bytes("")
            })
        );

        bodyTags.push(
            HTMLTag({
                name: GUNZIP_JS_SCRIPT,
                contractAddress: ETHFS_FILE_STORAGE,
                contractData: bytes(""),
                tagType: HTMLTagType.scriptBase64DataURI,
                tagOpen: bytes(""),
                tagClose: bytes(""),
                tagContent: bytes("")
            })
        );

        bodyTags.push(
            HTMLTag({
                name: POINTS_AND_LINES_SCRIPT,
                contractAddress: SCRIPTY_STORAGE_V2,
                contractData: bytes(""),
                tagType: HTMLTagType.script,
                tagOpen: bytes(""),
                tagClose: bytes(""),
                tagContent: bytes("")
            })
        );

        animation.headTags = headTags;
        animation.bodyTags = bodyTags;
    }

    function _configureSplits() internal {
        if (creator < admin) {
            accounts.push(creator);
            accounts.push(admin);
            allocations.push(SPLITS_CREATOR_ALLOCATION);
            allocations.push(SPLITS_ADMIN_ALLOCATION);
        } else {
            accounts.push(admin);
            accounts.push(creator);
            allocations.push(SPLITS_ADMIN_ALLOCATION);
            allocations.push(SPLITS_CREATOR_ALLOCATION);
        }
    }

    function _configureState() internal {
        price = 1 gwei;
        amount = 10;
        tokenId = 1;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    DEPLOYMENTS
    //////////////////////////////////////////////////////////////////////////*/

    function _deployContracts() internal {
        fxContractRegistry = new FxContractRegistry();
        fxRoleRegistry = new FxRoleRegistry();
        fxSplitsFactory = new FxSplitsFactory();
        fxPseudoRandomizer = new FxPseudoRandomizer();
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
        fixedPrice = new FixedPrice();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CREATE
    //////////////////////////////////////////////////////////////////////////*/

    function _createAccounts() internal {
        admin = msg.sender;
        creator = _createUser("creator");
        minter = _createUser("minter");
        tokenMod = _createUser("tokenMod");
        userMod = _createUser("userMod");
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

    function _createSplit() internal {
        primaryReceiver = fxSplitsFactory.createSplit(accounts, allocations);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    SETTERS
    //////////////////////////////////////////////////////////////////////////*/

    function _registerContracts() internal {
        names.push(FX_CONTRACT_REGISTRY);
        names.push(FX_GEN_ART_721);
        names.push(FX_ISSUER_FACTORY);
        names.push(FX_PSEUDO_RANDOMIZER);
        names.push(FX_ROLE_REGISTRY);
        names.push(FX_SPLITS_FACTORY);
        names.push(FX_TOKEN_RENDERER);

        contracts.push(address(fxContractRegistry));
        contracts.push(address(fxGenArt721));
        contracts.push(address(fxIssuerFactory));
        contracts.push(address(fxPseudoRandomizer));
        contracts.push(address(fxRoleRegistry));
        contracts.push(address(fxSplitsFactory));
        contracts.push(address(fxTokenRenderer));

        fxContractRegistry.register(names, contracts);
    }

    function _registerRoles() internal {
        fxRoleRegistry.grantRole(MINTER_ROLE, address(fixedPrice));
        fxRoleRegistry.grantRole(TOKEN_MODERATOR_ROLE, tokenMod);
        fxRoleRegistry.grantRole(USER_MODERATOR_ROLE, userMod);
    }

    function _setContracts() internal {
        FxGenArt721(fxGenArtProxy).setRandomizer(address(fxPseudoRandomizer));
        FxGenArt721(fxGenArtProxy).setRenderer(address(fxTokenRenderer));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _createUser(string memory _user) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(_user)))));
    }
}
