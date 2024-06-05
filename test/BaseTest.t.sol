// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Test.sol";
import "script/Deploy.s.sol";

import {Allowlist} from "src/minters/extensions/Allowlist.sol";
import {Base64} from "openzeppelin/contracts/utils/Base64.sol";
import {MintPass} from "src/minters/extensions/MintPass.sol";
import {MockMinter} from "test/mocks/MockMinter.sol";
import {MockToken} from "test/mocks/MockToken.sol";
import {RegistryLib} from "test/lib/helpers/RegistryLib.sol";
import {SSTORE2} from "sstore2/contracts/SSTORE2.sol";
import {StandardMerkleTree} from "test/utils/StandardMerkleTree.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";
import {TicketLib} from "test/lib/helpers/TicketLib.sol";
import {TokenLib} from "test/lib/helpers/TokenLib.sol";

import {IDutchAuction, AuctionInfo} from "src/interfaces/IDutchAuction.sol";
import {IFarcasterFrame} from "src/interfaces/IFarcasterFrame.sol";
import {IFixedPrice} from "src/interfaces/IFixedPrice.sol";
import {IFixedPriceParams} from "src/interfaces/IFixedPriceParams.sol";
import {IFxContractRegistry} from "src/interfaces/IFxContractRegistry.sol";
import {IFxGenArt721, GenArtInfo, InitInfo, IssuerInfo, MetadataInfo, MintInfo, ProjectInfo, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IFxIssuerFactory} from "src/interfaces/IFxIssuerFactory.sol";
import {IFxMintTicket721, TaxInfo} from "src/interfaces/IFxMintTicket721.sol";
import {IFxTicketFactory} from "src/interfaces/IFxTicketFactory.sol";
import {IRoyaltyManager} from "src/interfaces/IRoyaltyManager.sol";
import {ISeedConsumer} from "src/interfaces/ISeedConsumer.sol";
import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";
import {ITicketRedeemer} from "src/interfaces/ITicketRedeemer.sol";

contract BaseTest is Deploy, Test {
    // Accounts
    address internal deployer;
    address internal moderator;
    address internal minter;
    address internal alice;
    address internal bob;
    address internal eve;
    address internal susan;

    // Allowlist
    uint8 internal v;
    bytes32 internal r;
    bytes32 internal s;
    bytes32 internal digest;
    bytes32 internal merkleRoot;
    address internal signerAddr;
    uint256 internal signerPk;
    bytes internal signature;

    // Config
    address internal feeReceiver;
    string internal defaultMetadataURI;
    string internal externalURI;
    uint32 internal secondaryFeeAllocation;
    uint32 internal primaryFeeAllocation;
    uint64 internal lockTime;
    uint64 internal referrerShare;

    // Metadata
    bytes internal baseURI;
    string internal contractURI;
    string internal tokenURI;
    bytes internal fxParams;
    bytes internal onchainData;
    bytes32 internal seed;
    uint120 internal inputSize;

    // Project
    uint96 internal projectId;
    uint256[] internal tagIds;

    // Royalties
    address[] internal royaltyReceivers;
    uint32[] internal allocations;
    uint96 internal basisPoints;

    // Splits
    address internal primaryReceiver;
    address[] internal accounts;
    address[] internal primaryReceivers;
    uint32[] internal primaryAllocations;

    // Structs
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
    uint256 internal quantity;
    uint256 internal tokenId;

    // Modifiers
    modifier prank(address _caller) {
        vm.startPrank(_caller);
        _;
        vm.stopPrank();
    }

    // Callbacks
    receive() external payable {}

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _initializeAccounts();
        _mockSplits();
        _deployContracts();
        _grantRoles();
        vm.prank(fxIssuerFactory.owner());
        fxIssuerFactory.unpause();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    ACCOUNTS
    //////////////////////////////////////////////////////////////////////////*/

    function _createAccounts() internal virtual override {
        deployer = address(this);
        admin = makeAddr("admin");
        creator = makeAddr("creator");
        moderator = makeAddr("moderator");
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        eve = makeAddr("eve");
        susan = makeAddr("susan");

        vm.label(deployer, "Deployer");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INITIALIZATIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _initializeAccounts() internal virtual {
        vm.deal(admin, INITIAL_BALANCE);
        vm.deal(creator, INITIAL_BALANCE);
        vm.deal(deployer, INITIAL_BALANCE);
        vm.deal(moderator, INITIAL_BALANCE);
        vm.deal(alice, INITIAL_BALANCE);
        vm.deal(bob, INITIAL_BALANCE);
        vm.deal(eve, INITIAL_BALANCE);
        vm.deal(susan, INITIAL_BALANCE);
        vm.deal(CONTROLLER, INITIAL_BALANCE);
    }

    function _initializeState() internal virtual {
        delete primaryReceivers;
        delete primaryAllocations;
        primaryReceivers.push(payable(creator));
        primaryReceivers.push(payable(admin));
        primaryAllocations.push(MAX_ALLOCATION - PRIMARY_FEE_ALLOCATION);
        primaryAllocations.push(PRIMARY_FEE_ALLOCATION);
        primaryReceiver = ISplitsMain(SPLITS_MAIN).predictImmutableSplitAddress(
            primaryReceivers,
            primaryAllocations,
            0
        );
        amount = AMOUNT;
        price = PRICE;
        quantity = QUANTITY;
        tokenId = TOKEN_ID;
        tagIds.push(TAG_ID);
        vm.warp(RESERVE_START_TIME);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     MOCKS
    //////////////////////////////////////////////////////////////////////////*/

    function _mockMinter(address _admin) internal prank(_admin) {
        minter = address(new MockMinter());
    }

    /*//////////////////////////////////////////////////////////////////////////
                                CONFIGURATIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _configureRoyalties() internal virtual {
        delete royaltyReceivers;
        delete allocations;
        royaltyReceivers.push(payable(creator));
        royaltyReceivers.push(payable(admin));
        allocations.push(ROYALTY_ALLOCATION);
        allocations.push(SECONDARY_FEE_ALLOCATION);
        basisPoints = uint96(500);
    }

    function _configureProject(bool _mintEnabled, uint120 _maxSupply) internal virtual {
        projectInfo.mintEnabled = _mintEnabled;
        projectInfo.maxSupply = _maxSupply;
    }

    function _configureInit(
        string memory _name,
        string memory _symbol,
        address _randomizer,
        address _renderer,
        uint256[] memory _tagIds
    ) internal virtual {
        initInfo.name = _name;
        initInfo.symbol = _symbol;
        initInfo.primaryReceivers = primaryReceivers;
        initInfo.allocations = primaryAllocations;
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
                reserveInfo: ReserveInfo({startTime: _startTime, endTime: _endTime, allocation: _allocation}),
                params: _params
            })
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    SETTERS
    //////////////////////////////////////////////////////////////////////////*/

    function _grantRoles() internal virtual override {
        RegistryLib.grantRole(admin, fxRoleRegistry, CREATOR_ROLE, creator);
        RegistryLib.grantRole(admin, fxRoleRegistry, MODERATOR_ROLE, moderator);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CREATE
    //////////////////////////////////////////////////////////////////////////*/

    function _createProject() internal virtual {
        fxGenArtProxy = fxIssuerFactory.createProjectWithParams(
            creator,
            initInfo,
            projectInfo,
            metadataInfo,
            mintInfo,
            royaltyReceivers,
            allocations,
            basisPoints
        );
        vm.label(fxGenArtProxy, "FxGenArtProxy");
    }

    function _createTicket() internal {
        fxMintTicketProxy = fxTicketFactory.createTicket(
            creator,
            fxGenArtProxy,
            address(ticketRedeemer),
            address(ipfsRenderer),
            uint48(ONE_DAY),
            mintInfo
        );
        vm.label(fxMintTicketProxy, "FxMintTicketProxy");
    }
}
