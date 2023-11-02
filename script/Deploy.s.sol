// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import "script/utils/Constants.sol";
import "src/utils/Constants.sol";
import "test/utils/Constants.sol";

import {FxContractRegistry} from "src/registries/FxContractRegistry.sol";
import {FxGenArt721} from "src/tokens/FxGenArt721.sol";
import {FxIssuerFactory} from "src/factories/FxIssuerFactory.sol";
import {FxMintTicket721} from "src/tokens/FxMintTicket721.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";
import {FxTicketFactory} from "src/factories/FxTicketFactory.sol";

import {BitFlagsLib} from "src/lib/BitFlagsLib.sol";
import {DutchAuction} from "src/minters/DutchAuction.sol";
import {FixedPrice} from "src/minters/FixedPrice.sol";
import {PseudoRandomizer} from "src/randomizers/PseudoRandomizer.sol";
import {ScriptyRenderer} from "src/renderers/ScriptyRenderer.sol";
import {SplitsController} from "src/splits/SplitsController.sol";
import {SplitsFactory} from "src/splits/SplitsFactory.sol";
import {TicketRedeemer} from "src/minters/TicketRedeemer.sol";

import {Clones} from "openzeppelin-contracts/contracts/proxy/Clones.sol";
import {HTMLRequest, HTMLTagType, HTMLTag} from "scripty.sol/contracts/scripty/core/ScriptyStructs.sol";
import {IFxContractRegistry, ConfigInfo} from "src/interfaces/IFxContractRegistry.sol";
import {IFxGenArt721, GenArtInfo, InitInfo, IssuerInfo, MetadataInfo, MintInfo, ProjectInfo, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IFxMintTicket721, TaxInfo} from "src/interfaces/IFxMintTicket721.sol";

contract Deploy is Script {
    // Core
    FxContractRegistry internal fxContractRegistry;
    FxGenArt721 internal fxGenArt721;
    FxIssuerFactory internal fxIssuerFactory;
    FxMintTicket721 internal fxMintTicket721;
    FxRoleRegistry internal fxRoleRegistry;
    FxTicketFactory internal fxTicketFactory;

    // Periphery
    DutchAuction internal dutchAuction;
    FixedPrice internal fixedPrice;
    PseudoRandomizer internal pseudoRandomizer;
    ScriptyRenderer internal scriptyRenderer;
    SplitsController internal splitsController;
    SplitsFactory internal splitsFactory;
    TicketRedeemer internal ticketRedeemer;

    // Accounts
    address internal admin;
    address internal creator;

    // Project
    string internal contractURI;
    string internal defaultMetadata;
    uint128 internal lockTime;
    uint128 internal referrerShare;
    uint256[] internal tagIds;

    // Metadata
    string internal baseURI;
    string internal imageURI;
    bytes internal onchainData;
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
    GenArtInfo internal genArtInfo;
    InitInfo internal initInfo;
    IssuerInfo internal issuerInfo;
    MetadataInfo internal metadataInfo;
    MintInfo[] internal mintInfo;
    ProjectInfo internal projectInfo;
    ReserveInfo internal reserveInfo;

    // Ticket
    address internal fxMintTicketProxy;
    uint48 internal ticketId;

    // Token
    address internal fxGenArtProxy;
    uint256 internal amount;
    uint256 internal price;
    bytes32 internal merkleRoot;
    uint256 internal mintPassSignerPk;
    address internal mintPassSigner;
    uint256 internal quantity;
    uint256 internal tokenId;
    uint16 internal flags;

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
        _configureState(AMOUNT, PRICE, QUANTITY, TOKEN_ID);
        _configureInfo(LOCK_TIME, REFERRER_SHARE, DEFAULT_METADATA);
        _configureProject(ONCHAIN, MINT_ENABLED, MAX_SUPPLY, CONTRACT_URI);
        _configureMetdata(BASE_URI, IMAGE_URI, onchainData);
        _configureAllowlist(merkleRoot, mintPassSigner);
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
            abi.encode(PRICE, merkleRoot, mintPassSigner)
        );
        _configureMinter(
            address(ticketRedeemer),
            uint64(block.timestamp) + RESERVE_START_TIME,
            uint64(block.timestamp) + RESERVE_END_TIME,
            REDEEMER_ALLOCATION,
            abi.encode(_computeTicketAddr(admin))
        );
        _registerContracts();
        _grantRoles();
        _createSplit();
        _configureInit(NAME, SYMBOL, primaryReceiver, address(pseudoRandomizer), address(scriptyRenderer), tagIds);
        _createProject();
        delete mintInfo;
        _configureMinter(
            address(fixedPrice),
            uint64(block.timestamp) + RESERVE_START_TIME,
            uint64(block.timestamp) + RESERVE_END_TIME,
            MINTER_ALLOCATION,
            abi.encode(PRICE, merkleRoot, mintPassSigner)
        );
        _createTicket();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    ACCOUNTS
    //////////////////////////////////////////////////////////////////////////*/

    function _createAccounts() internal virtual {
        admin = msg.sender;
        creator = makeAddr("creator");
        tagIds.push(TAG_ID);
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
        onchainData = abi.encode(animation);
    }

    function _configureState(uint256 _amount, uint256 _price, uint256 _quantity, uint256 _tokenId) internal virtual {
        amount = _amount;
        price = _price;
        quantity = _quantity;
        tokenId = _tokenId;
    }

    function _configureInfo(
        uint128 _lockTime,
        uint128 _referrerShare,
        string memory _defaultMetadata
    ) internal virtual {
        configInfo.lockTime = _lockTime;
        configInfo.referrerShare = _referrerShare;
        configInfo.defaultMetadata = _defaultMetadata;
    }

    function _configureProject(
        bool _onchain,
        bool _mintEnabled,
        uint120 _maxSupply,
        string memory _contractURI
    ) internal virtual {
        projectInfo.onchain = _onchain;
        projectInfo.mintEnabled = _mintEnabled;
        projectInfo.maxSupply = _maxSupply;
        projectInfo.contractURI = _contractURI;
    }

    function _configureMetdata(
        string memory _baseURI,
        string memory _imageURI,
        bytes memory _onchainData
    ) internal virtual {
        metadataInfo.baseURI = _baseURI;
        metadataInfo.imageURI = _imageURI;
        metadataInfo.onchainData = _onchainData;
    }

    function _configureAllowlist(bytes32 _merkleRoot, address _mintPassSigner) internal virtual {
        merkleRoot = _merkleRoot;
        mintPassSigner = _mintPassSigner;
    }

    function _configureInit(
        string memory _name,
        string memory _symbol,
        address _primaryReceiver,
        address _randomizer,
        address _renderer,
        uint256[] memory _tagIds
    ) internal virtual {
        initInfo.name = _name;
        initInfo.symbol = _symbol;
        initInfo.primaryReceiver = _primaryReceiver;
        initInfo.randomizer = _randomizer;
        initInfo.renderer = _renderer;
        initInfo.tagIds = _tagIds;
    }

    function _configureMinter(
        address _minter,
        uint64 _startTime,
        uint64 _endTime,
        uint64 _allocation,
        bytes memory _params
    ) internal virtual {
        mintInfo.push(
            MintInfo({
                minter: _minter,
                reserveInfo: ReserveInfo({
                    startTime: _startTime,
                    endTime: _endTime,
                    allocation: _allocation,
                    flags: flags
                }),
                params: _params
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
        bytes memory constructorArgs = abi.encode(admin, configInfo);
        fxContractRegistry = FxContractRegistry(_deployCreate2(creationCode, constructorArgs, salt));

        // FxRoleRegistry
        creationCode = type(FxRoleRegistry).creationCode;
        constructorArgs = abi.encode(admin);
        fxRoleRegistry = FxRoleRegistry(_deployCreate2(creationCode, constructorArgs, salt));

        // FxGenArt721
        creationCode = type(FxGenArt721).creationCode;
        constructorArgs = abi.encode(address(fxContractRegistry), address(fxRoleRegistry));
        fxGenArt721 = FxGenArt721(_deployCreate2(creationCode, constructorArgs, salt));

        // FxIssuerFactory
        creationCode = type(FxIssuerFactory).creationCode;
        constructorArgs = abi.encode(admin, address(fxRoleRegistry), address(fxGenArt721));
        fxIssuerFactory = FxIssuerFactory(_deployCreate2(creationCode, constructorArgs, salt));

        // FxMintTicket721
        creationCode = type(FxMintTicket721).creationCode;
        constructorArgs = abi.encode(address(fxContractRegistry), address(fxRoleRegistry));
        fxMintTicket721 = FxMintTicket721(_deployCreate2(creationCode, constructorArgs, salt));

        // FxTicketFactory
        creationCode = type(FxTicketFactory).creationCode;
        constructorArgs = abi.encode(admin, address(fxMintTicket721), ONE_DAY);
        fxTicketFactory = FxTicketFactory(_deployCreate2(creationCode, constructorArgs, salt));

        vm.label(address(fxContractRegistry), "FxContractRegistry");
        vm.label(address(fxGenArt721), "FxGenArt721");
        vm.label(address(fxIssuerFactory), "FxIssuerFactory");
        vm.label(address(fxMintTicket721), "FxMintTicket721");
        vm.label(address(fxRoleRegistry), "FxRoleRegistry");
        vm.label(address(fxTicketFactory), "FxTicketFactory");

        // SplitsFactory
        splitsMain = (block.chainid == SEPOLIA) ? SEPOLIA_SPLITS_MAIN : SPLITS_MAIN;
        creationCode = type(SplitsFactory).creationCode;
        constructorArgs = abi.encode(admin, splitsMain);
        splitsFactory = SplitsFactory(_deployCreate2(creationCode, constructorArgs, salt));

        creationCode = type(SplitsFactory).creationCode;
        constructorArgs = abi.encode(splitsMain, splitsFactory, admin);
        splitsController = SplitsController(_deployCreate2(creationCode, constructorArgs, salt));

        // PseudoRandomizer
        creationCode = type(PseudoRandomizer).creationCode;
        pseudoRandomizer = PseudoRandomizer(_deployCreate2(creationCode, salt));

        // ScriptyRenderer
        creationCode = type(ScriptyRenderer).creationCode;
        constructorArgs = abi.encode(ethFSFileStorage, scriptyStorageV2, scriptyBuilderV2);
        scriptyRenderer = ScriptyRenderer(_deployCreate2(creationCode, constructorArgs, salt));

        // DutchAuction
        creationCode = type(DutchAuction).creationCode;
        dutchAuction = DutchAuction(_deployCreate2(creationCode, salt));

        // FixedPrice
        creationCode = type(FixedPrice).creationCode;
        fixedPrice = FixedPrice(_deployCreate2(creationCode, salt));

        // TicketRedeemer
        creationCode = type(TicketRedeemer).creationCode;
        ticketRedeemer = TicketRedeemer(_deployCreate2(creationCode, salt));

        vm.label(address(dutchAuction), "DutchAuction");
        vm.label(address(fixedPrice), "FixedPrice");
        vm.label(address(pseudoRandomizer), "PseudoRandomizer");
        vm.label(address(scriptyRenderer), "ScriptyRenderer");
        vm.label(address(splitsController), "splitsController");
        vm.label(address(splitsFactory), "SplitsFactory");
        vm.label(address(ticketRedeemer), "TicketRedeemer");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CREATE
    //////////////////////////////////////////////////////////////////////////*/

    function _createSplit() internal virtual {
        primaryReceiver = splitsFactory.createImmutableSplit(accounts, allocations);
        vm.label(primaryReceiver, "PrimaryReceiver");
    }

    function _createProject() internal virtual {
        fxGenArtProxy = fxIssuerFactory.createProject(
            creator,
            initInfo,
            projectInfo,
            metadataInfo,
            mintInfo,
            royaltyReceivers,
            basisPoints
        );

        vm.label(fxGenArtProxy, "FxGenArtProxy");
    }

    function _createTicket() internal {
        fxMintTicketProxy = fxTicketFactory.createTicket(
            creator,
            fxGenArtProxy,
            address(ticketRedeemer),
            uint48(ONE_DAY),
            BASE_URI,
            mintInfo
        );

        vm.label(fxMintTicketProxy, "FxMintTicketProxy");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    SETTERS
    //////////////////////////////////////////////////////////////////////////*/

    function _grantRoles() internal virtual {
        fxRoleRegistry.grantRole(MINTER_ROLE, address(dutchAuction));
        fxRoleRegistry.grantRole(MINTER_ROLE, address(fixedPrice));
        fxRoleRegistry.grantRole(MINTER_ROLE, address(ticketRedeemer));
        fxRoleRegistry.grantRole(VERIFIED_USER_ROLE, creator);
    }

    function _registerContracts() internal virtual {
        names.push(FX_CONTRACT_REGISTRY);
        names.push(FX_GEN_ART_721);
        names.push(FX_ISSUER_FACTORY);
        names.push(FX_MINT_TICKET_721);
        names.push(FX_ROLE_REGISTRY);
        names.push(FX_TICKET_FACTORY);
        names.push(DUTCH_AUCTION);
        names.push(FIXED_PRICE);
        names.push(PSEUDO_RANDOMIZER);
        names.push(SCRIPTY_RENDERER);
        names.push(SPLITS_FACTORY);
        names.push(TICKET_REDEEMER);

        contracts.push(address(fxContractRegistry));
        contracts.push(address(fxGenArt721));
        contracts.push(address(fxIssuerFactory));
        contracts.push(address(fxMintTicket721));
        contracts.push(address(fxRoleRegistry));
        contracts.push(address(fxTicketFactory));
        contracts.push(address(dutchAuction));
        contracts.push(address(fixedPrice));
        contracts.push(address(pseudoRandomizer));
        contracts.push(address(scriptyRenderer));
        contracts.push(address(splitsFactory));
        contracts.push(address(ticketRedeemer));

        fxContractRegistry.register(names, contracts);
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

    function _computeTicketAddr(address _deployer) internal view returns (address) {
        uint256 nonce = fxTicketFactory.nonces(_deployer);
        bytes32 salt = keccak256(abi.encode(_deployer, nonce));
        return Clones.predictDeterministicAddress(address(fxMintTicket721), salt, address(fxTicketFactory));
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
