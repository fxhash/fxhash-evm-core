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
        _run();
        vm.stopBroadcast();
    }

    function _run() internal virtual {
        _deployContracts();
        _configureMinters();
        _registerContracts();
        _registerRoles();
        _createSplit();
        _createProject();
        _setContracts();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  CONFIGURATIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _configureInfo() internal virtual {
        configInfo.feeShare = CONFIG_FEE_SHARE;
        configInfo.lockTime = CONFIG_LOCK_TIME;
        configInfo.defaultMetadata = CONFIG_DEFAULT_METADATA;
    }

    function _configureProject() internal virtual {
        projectInfo.enabled = true;
        projectInfo.onchain = true;
        projectInfo.supply = MAX_SUPPLY;
        projectInfo.contractURI = CONTRACT_URI;
    }

    function _configureMetdata() internal virtual {
        metadataInfo.baseURI = BASE_URI;
        metadataInfo.imageURI = IMAGE_URI;
        metadataInfo.animation = animation;
    }

    function _configureMinters() internal virtual {
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

    function _configureRoyalties() internal virtual {
        royaltyReceivers.push(payable(admin));
        royaltyReceivers.push(payable(creator));
        royaltyReceivers.push(payable(tokenMod));
        royaltyReceivers.push(payable(userMod));
        basisPoints.push(ROYALTY_BPS);
        basisPoints.push(ROYALTY_BPS * 2);
        basisPoints.push(ROYALTY_BPS * 3);
        basisPoints.push(ROYALTY_BPS * 4);
    }

    function _configureScripty() internal virtual {
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

    function _configureSplits() internal virtual {
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

    function _configureState() internal virtual {
        price = 1 gwei;
        amount = 10;
        tokenId = 1;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    DEPLOYMENTS
    //////////////////////////////////////////////////////////////////////////*/

    function _deployContracts() internal virtual {
        bytes32 salt = keccak256("TEMP_SALT");
        bytes memory creationCode = type(FxContractRegistry).creationCode;
        bytes memory constructorArgs = abi.encode(admin);
        fxContractRegistry = FxContractRegistry(_deployCreate2(creationCode, constructorArgs, salt));

        creationCode = type(FxRoleRegistry).creationCode;
        constructorArgs = abi.encode(admin);
        fxRoleRegistry = FxRoleRegistry(_deployCreate2(creationCode, constructorArgs, salt));

        creationCode = type(FxSplitsFactory).creationCode;
        fxSplitsFactory = FxSplitsFactory(_deployCreate2(creationCode, salt));

        creationCode = type(FxPseudoRandomizer).creationCode;
        fxPseudoRandomizer = FxPseudoRandomizer(_deployCreate2(creationCode, salt));

        creationCode = type(FxTokenRenderer).creationCode;
        constructorArgs = abi.encode(ETHFS_FILE_STORAGE, SCRIPTY_STORAGE_V2, SCRIPTY_BUILDER_V2);
        fxTokenRenderer = FxTokenRenderer(_deployCreate2(creationCode, constructorArgs, salt));

        creationCode = type(FxGenArt721).creationCode;
        constructorArgs = abi.encode(address(fxContractRegistry), address(fxRoleRegistry));
        fxGenArt721 = FxGenArt721(_deployCreate2(creationCode, constructorArgs, salt));

        creationCode = type(FxIssuerFactory).creationCode;
        constructorArgs = abi.encode(address(fxGenArt721), configInfo);
        fxIssuerFactory = FxIssuerFactory(_deployCreate2(creationCode, constructorArgs, salt));

        creationCode = type(FixedPrice).creationCode;
        fixedPrice = FixedPrice(_deployCreate2(creationCode, salt));

        vm.label(address(fxContractRegistry), "FxContractRegistry");
        vm.label(address(fxRoleRegistry), "FxRoleRegistry");
        vm.label(address(fxSplitsFactory), "FxSplitsFactory");
        vm.label(address(fxPseudoRandomizer), "FxPseudoRandomizer");
        vm.label(address(fxTokenRenderer), "FxTokenRenderer");
        vm.label(address(fxGenArt721), "FxGenArt721");
        vm.label(address(fxIssuerFactory), "FxIssuerFactory");
        vm.label(address(fixedPrice), "FixedPrice");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CREATE
    //////////////////////////////////////////////////////////////////////////*/

    function _createAccounts() internal virtual {
        admin = msg.sender;
        creator = makeAddr("creator");
        tokenMod = makeAddr("tokenMod");
        userMod = makeAddr("userMod");
    }

    function _createProject() internal virtual {
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

    function _createSplit() internal virtual {
        primaryReceiver = fxSplitsFactory.createSplit(accounts, allocations);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    SETTERS
    //////////////////////////////////////////////////////////////////////////*/

    function _registerContracts() internal virtual {
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

    function _registerRoles() internal virtual {
        fxRoleRegistry.grantRole(MINTER_ROLE, address(fixedPrice));
        fxRoleRegistry.grantRole(TOKEN_MODERATOR_ROLE, tokenMod);
        fxRoleRegistry.grantRole(USER_MODERATOR_ROLE, userMod);
    }

    function _setContracts() internal virtual {
        FxGenArt721(fxGenArtProxy).setRandomizer(address(fxPseudoRandomizer));
        FxGenArt721(fxGenArtProxy).setRenderer(address(fxTokenRenderer));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _deployCreate2(bytes memory creationCode, bytes memory constructorArgs, bytes32 salt)
        internal
        returns (address deployedAddress)
    {
        (bool success, bytes memory response) =
            CREATE2_FACTORY.call(bytes.concat(salt, creationCode, constructorArgs));
        deployedAddress = address(bytes20(response));
        require(success, "deployment failed");
    }

    function _deployCreate2(bytes memory creationCode, bytes32 salt)
        internal
        returns (address deployedAddress)
    {
        deployedAddress = _deployCreate2(creationCode, "", salt);
    }

    function _computeCreate2Address(
        bytes memory creationCode,
        bytes memory constructorArgs,
        bytes32 salt
    ) internal pure {
        computeCreate2Address(salt, hashInitCode(creationCode, constructorArgs));
    }

    function _initCode(bytes memory creationCode, bytes memory constructorArgs)
        internal
        pure
        returns (bytes memory)
    {
        return bytes.concat(creationCode, constructorArgs);
    }
}
