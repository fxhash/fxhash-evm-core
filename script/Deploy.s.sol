// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import "script/utils/Constants.sol";
import "src/utils/Constants.sol";
import "test/utils/Constants.sol";

import {FixedPrice} from "src/minters/FixedPrice.sol";
import {FxContractRegistry} from "src/registries/FxContractRegistry.sol";
import {FxGenArt721} from "src/tokens/FxGenArt721.sol";
import {FxIssuerFactory} from "src/factories/FxIssuerFactory.sol";
import {FxMintTicket721} from "src/tokens/FxMintTicket721.sol";
import {FxPseudoRandomizer} from "src/randomizers/FxPseudoRandomizer.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";
import {FxScriptyRenderer} from "src/renderers/FxScriptyRenderer.sol";
import {FxSplitsFactory} from "src/factories/FxSplitsFactory.sol";
import {FxTicketFactory} from "src/factories/FxTicketFactory.sol";
import {FxTokenRedeemer} from "src/redeemers/FxTokenRedeemer.sol";

import {HTMLRequest, HTMLTagType, HTMLTag} from "scripty.sol/contracts/scripty/core/ScriptyStructs.sol";
import {IFxGenArt721, GenArtInfo, IssuerInfo, MetadataInfo, MintInfo, ProjectInfo, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IFxIssuerFactory, ConfigInfo} from "src/interfaces/IFxIssuerFactory.sol";
import {IFxMintTicket721, TaxInfo} from "src/interfaces/IFxMintTicket721.sol";

contract Deploy is Script {
    // Contracts
    FxContractRegistry internal fxContractRegistry;
    FxGenArt721 internal fxGenArt721;
    FxIssuerFactory internal fxIssuerFactory;
    FxMintTicket721 internal fxMintTicket721;
    FxPseudoRandomizer internal fxPseudoRandomizer;
    FxRoleRegistry internal fxRoleRegistry;
    FxScriptyRenderer internal fxScriptyRenderer;
    FxSplitsFactory internal fxSplitsFactory;
    FxTicketFactory internal fxTicketFactory;
    FxTokenRedeemer internal fxTokenRedeemer;
    FixedPrice internal fixedPrice;

    // Accounts
    address internal admin;
    address internal creator;

    // Project
    string internal contractURI;
    string internal defaultMetadata;
    uint256 internal lockTime;

    // Metadata
    string internal baseURI;
    string internal imageURI;
    HTMLRequest internal animation;
    HTMLRequest internal attributes;
    HTMLTag[] internal headTags;
    HTMLTag[] internal bodyTags;

    // Registries
    address[] internal contracts;
    string[] internal names;

    // Royalties
    address payable[] internal royaltyReceivers;
    uint96[] internal basisPoints;

    // Splits
    address internal splitsMain;
    address internal primaryReceiver;
    address[] internal accounts;
    uint32[] internal allocations;

    // Scripty
    address internal ethFSFileStorage;
    address internal scriptyBuilderV2;
    address internal scriptyStorageV2;

    // Structs
    ConfigInfo internal configInfo;
    IssuerInfo internal issuerInfo;
    GenArtInfo internal genArtInfo;
    MetadataInfo internal metadataInfo;
    MintInfo[] internal mintInfo;
    ProjectInfo internal projectInfo;
    ReserveInfo internal reserveInfo;

    // Ticket
    address internal fxMintTicketProxy;
    uint96 internal ticketId;

    // Token
    address internal fxGenArtProxy;
    uint256 internal amount;
    uint256 internal price;
    uint256 internal tokenId;

    /*//////////////////////////////////////////////////////////////////////////
                                     MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    modifier onlyLocalForge() {
        try vm.activeFork() returns (uint256) {
            return;
        } catch {
            _;
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        _createAccounts();
        _configureSplits();
        _configureRoyalties();
        _configureScripty();
        _configureState(AMOUNT, PRICE, TOKEN_ID);
        _configureInfo(LOCK_TIME, DEFAULT_METADATA);
        _configureProject(ENABLED, ONCHAIN, MAX_SUPPLY, CONTRACT_URI);
        _configureMetdata(BASE_URI, IMAGE_URI, animation);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      RUN
    //////////////////////////////////////////////////////////////////////////*/
    function run() public virtual {
        _mockSplits();
        vm.startBroadcast();
        _run();
        vm.stopBroadcast();
    }

    function _run() internal virtual {
        _deployContracts();
        _configureMinter(
            address(fixedPrice),
            uint64(block.timestamp) + RESERVE_START_TIME,
            uint64(block.timestamp) + RESERVE_END_TIME,
            MINTER_ALLOCATION,
            PRICE
        );
        _registerContracts();
        _grantRoles();
        _createSplit();
        _createProject();
        _createTicket();
        _setContracts();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    ACCOUNTS
    //////////////////////////////////////////////////////////////////////////*/

    function _createAccounts() internal virtual {
        admin = msg.sender;
        creator = makeAddr("creator");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                CONFIGURATIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _configureSplits() internal virtual {
        if (creator < admin) {
            accounts.push(creator);
            accounts.push(admin);
            allocations.push(CREATOR_ALLOCATION);
            allocations.push(ADMIN_ALLOCATION);
        } else {
            accounts.push(admin);
            accounts.push(creator);
            allocations.push(ADMIN_ALLOCATION);
            allocations.push(CREATOR_ALLOCATION);
        }
    }

    function _configureRoyalties() internal virtual {
        royaltyReceivers.push(payable(admin));
        royaltyReceivers.push(payable(creator));
        basisPoints.push(ROYALTY_BPS);
        basisPoints.push(ROYALTY_BPS * 2);
    }

    function _configureScripty() internal virtual {
        if (block.chainid == SEPOLIA) {
            ethFSFileStorage = SEPOLIA_ETHFS_FILE_STORAGE;
            scriptyBuilderV2 = SEPOLIA_SCRIPTY_BUILDER_V2;
            scriptyStorageV2 = SEPOLIA_SCRIPTY_STORAGE_V2;
        } else {
            ethFSFileStorage = GOERLI_ETHFS_FILE_STORAGE;
            scriptyBuilderV2 = GOERLI_SCRIPTY_BUILDER_V2;
            scriptyStorageV2 = GOERLI_SCRIPTY_STORAGE_V2;
        }

        headTags.push(
            HTMLTag({
                name: CSS_CANVAS_SCRIPT,
                contractAddress: ethFSFileStorage,
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
                contractAddress: ethFSFileStorage,
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
                contractAddress: ethFSFileStorage,
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
                contractAddress: scriptyStorageV2,
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

    function _configureState(uint256 _amount, uint256 _price, uint256 _tokenId) internal virtual {
        amount = _amount;
        price = _price;
        tokenId = _tokenId;
    }

    function _configureInfo(uint256 _lockTime, string memory _defaultMetadata) internal virtual {
        configInfo.lockTime = _lockTime;
        configInfo.defaultMetadata = _defaultMetadata;
    }

    function _configureProject(
        bool _enabled,
        bool _onchain,
        uint240 _supply,
        string memory _contractURI
    ) internal virtual {
        projectInfo.enabled = _enabled;
        projectInfo.onchain = _onchain;
        projectInfo.supply = _supply;
        projectInfo.contractURI = _contractURI;
    }

    function _configureMetdata(
        string memory _baseURI,
        string memory _imageURI,
        HTMLRequest storage _animation
    ) internal virtual {
        metadataInfo.baseURI = _baseURI;
        metadataInfo.imageURI = _imageURI;
        metadataInfo.animation = _animation;
    }

    function _configureMinter(
        address _minter,
        uint64 _startTime,
        uint64 _endTime,
        uint64 _allocation,
        uint256 _price
    ) internal virtual {
        mintInfo.push(
            MintInfo({
                minter: _minter,
                reserveInfo: ReserveInfo({startTime: _startTime, endTime: _endTime, allocation: _allocation}),
                params: abi.encode(_price)
            })
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    DEPLOYMENTS
    //////////////////////////////////////////////////////////////////////////*/

    function _deployContracts() internal virtual {
        bytes32 salt = keccak256(abi.encode(vm.getNonce(msg.sender)));

        // FxContractRegistry
        bytes memory creationCode = type(FxContractRegistry).creationCode;
        bytes memory constructorArgs = abi.encode(admin);
        fxContractRegistry = FxContractRegistry(_deployCreate2(creationCode, constructorArgs, salt));

        // FxRoleRegistry
        creationCode = type(FxRoleRegistry).creationCode;
        constructorArgs = abi.encode(admin);
        fxRoleRegistry = FxRoleRegistry(_deployCreate2(creationCode, constructorArgs, salt));

        // FxSplitsFactory
        splitsMain = (block.chainid == SEPOLIA) ? SEPOLIA_SPLITS_MAIN : SPLITS_MAIN;
        creationCode = type(FxSplitsFactory).creationCode;
        constructorArgs = abi.encode(admin, splitsMain);
        fxSplitsFactory = FxSplitsFactory(_deployCreate2(creationCode, constructorArgs, salt));

        // FxGenArt721
        creationCode = type(FxGenArt721).creationCode;
        constructorArgs = abi.encode(address(fxContractRegistry), address(fxRoleRegistry));
        fxGenArt721 = FxGenArt721(_deployCreate2(creationCode, constructorArgs, salt));

        // FxIssuerFactory
        creationCode = type(FxIssuerFactory).creationCode;
        constructorArgs = abi.encode(address(fxRoleRegistry), address(fxGenArt721), configInfo);
        fxIssuerFactory = FxIssuerFactory(_deployCreate2(creationCode, constructorArgs, salt));

        // FxMintTicket721
        creationCode = type(FxMintTicket721).creationCode;
        fxMintTicket721 = FxMintTicket721(_deployCreate2(creationCode, salt));

        // FxTicketFactory
        creationCode = type(FxTicketFactory).creationCode;
        constructorArgs = abi.encode(address(fxMintTicket721));
        fxTicketFactory = FxTicketFactory(_deployCreate2(creationCode, constructorArgs, salt));

        // FxTokenRedeemer
        creationCode = type(FxTokenRedeemer).creationCode;
        fxTokenRedeemer = FxTokenRedeemer(_deployCreate2(creationCode, salt));

        // FxPseudoRandomizer
        creationCode = type(FxPseudoRandomizer).creationCode;
        fxPseudoRandomizer = FxPseudoRandomizer(_deployCreate2(creationCode, salt));

        // FxScriptyRenderer
        creationCode = type(FxScriptyRenderer).creationCode;
        constructorArgs = abi.encode(ethFSFileStorage, scriptyStorageV2, scriptyBuilderV2);
        fxScriptyRenderer = FxScriptyRenderer(_deployCreate2(creationCode, constructorArgs, salt));

        // FixedPrice
        creationCode = type(FixedPrice).creationCode;
        fixedPrice = FixedPrice(_deployCreate2(creationCode, salt));

        vm.label(address(fxContractRegistry), "FxContractRegistry");
        vm.label(address(fxGenArt721), "FxGenArt721");
        vm.label(address(fxIssuerFactory), "FxIssuerFactory");
        vm.label(address(fxMintTicket721), "FxMintTicket721");
        vm.label(address(fxPseudoRandomizer), "FxPseudoRandomizer");
        vm.label(address(fxRoleRegistry), "FxRoleRegistry");
        vm.label(address(fxScriptyRenderer), "FxScriptyRenderer");
        vm.label(address(fxSplitsFactory), "FxSplitsFactory");
        vm.label(address(fxTicketFactory), "FxTicketFactory");
        vm.label(address(fxTokenRedeemer), "FxTokenRedeemer");
        vm.label(address(fixedPrice), "FixedPrice");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CREATE
    //////////////////////////////////////////////////////////////////////////*/

    function _createSplit() internal virtual {
        primaryReceiver = fxSplitsFactory.createImmutableSplit(accounts, allocations);
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

    function _createTicket() internal {
        fxMintTicketProxy = fxTicketFactory.createTicket(creator, fxGenArtProxy, uint48(ONE_DAY), BASE_URI);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    SETTERS
    //////////////////////////////////////////////////////////////////////////*/

    function _grantRoles() internal virtual {
        fxRoleRegistry.grantRole(MINTER_ROLE, address(fixedPrice));
        fxRoleRegistry.grantRole(REDEEMER_ROLE, address(fxTokenRedeemer));
        fxRoleRegistry.grantRole(VERIFIED_USER_ROLE, creator);
    }

    function _registerContracts() internal virtual {
        names.push(FX_CONTRACT_REGISTRY);
        names.push(FX_GEN_ART_721);
        names.push(FX_ISSUER_FACTORY);
        names.push(FX_MINT_TICKET_721);
        names.push(FX_PSEUDO_RANDOMIZER);
        names.push(FX_ROLE_REGISTRY);
        names.push(FX_SCRIPTY_RENDERER);
        names.push(FX_SPLITS_FACTORY);
        names.push(FX_TICKET_FACTORY);
        names.push(FX_TOKEN_REDEEMER);
        names.push(FIXED_PRICE);

        contracts.push(address(fxContractRegistry));
        contracts.push(address(fxGenArt721));
        contracts.push(address(fxIssuerFactory));
        contracts.push(address(fxMintTicket721));
        contracts.push(address(fxPseudoRandomizer));
        contracts.push(address(fxRoleRegistry));
        contracts.push(address(fxScriptyRenderer));
        contracts.push(address(fxSplitsFactory));
        contracts.push(address(fxTicketFactory));
        contracts.push(address(fxTokenRedeemer));
        contracts.push(address(fixedPrice));

        fxContractRegistry.register(names, contracts);
    }

    function _setContracts() internal virtual {
        FxGenArt721(fxGenArtProxy).setRandomizer(address(fxPseudoRandomizer));
        FxGenArt721(fxGenArtProxy).setRenderer(address(fxScriptyRenderer));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CREATE2
    //////////////////////////////////////////////////////////////////////////*/

    function _deployCreate2(
        bytes memory _creationCode,
        bytes memory _constructorArgs,
        bytes32 _salt
    ) internal returns (address deployedAddr) {
        (bool success, bytes memory response) = CREATE2_FACTORY.call(
            bytes.concat(_salt, _creationCode, _constructorArgs)
        );
        deployedAddr = address(bytes20(response));
        require(success, "deployment failed");
    }

    function _deployCreate2(bytes memory _creationCode, bytes32 _salt) internal returns (address deployedAddr) {
        deployedAddr = _deployCreate2(_creationCode, "", _salt);
    }

    function _mockSplits() internal onlyLocalForge {
        bytes memory splitMainBytecode = abi.encodePacked(SPLITS_MAIN_CREATION_CODE, abi.encode());
        address deployedAddr;
        vm.setNonce(SPLITS_DEPLOYER, 0);
        vm.prank(SPLITS_DEPLOYER);
        assembly {
            deployedAddr := create(0, add(splitMainBytecode, 32), mload(splitMainBytecode))
        }
    }

    function _computeCreate2Addr(
        bytes memory _creationCode,
        bytes memory _constructorArgs,
        bytes32 _salt
    ) internal pure {
        computeCreate2Address(_salt, hashInitCode(_creationCode, _constructorArgs));
    }

    function _initCode(bytes memory _creationCode, bytes memory _constructorArgs) internal pure returns (bytes memory) {
        return bytes.concat(_creationCode, _constructorArgs);
    }
}
