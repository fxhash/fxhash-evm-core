// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Test.sol";
import "script/Deploy.s.sol";

import {Allowlist} from "src/minters/extensions/Allowlist.sol";
import {MintPass} from "src/minters/extensions/MintPass.sol";
import {MockMinter} from "test/mocks/MockMinter.sol";
import {MockSplitsController} from "test/mocks/MockSplitsController.sol";
import {RegistryLib} from "test/lib/helpers/RegistryLib.sol";
import {StandardMerkleTree} from "test/utils/StandardMerkleTree.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";
import {TicketLib} from "test/lib/helpers/TicketLib.sol";
import {TokenLib} from "test/lib/helpers/TokenLib.sol";

import {IDutchAuction, AuctionInfo} from "src/interfaces/IDutchAuction.sol";
import {IFixedPrice} from "src/interfaces/IFixedPrice.sol";
import {IFxContractRegistry} from "src/interfaces/IFxContractRegistry.sol";
import {IFxGenArt721, GenArtInfo, InitInfo, IssuerInfo, MetadataInfo, MintInfo, ProjectInfo, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IFxIssuerFactory} from "src/interfaces/IFxIssuerFactory.sol";
import {IFxMintTicket721, TaxInfo} from "src/interfaces/IFxMintTicket721.sol";
import {IFxTicketFactory} from "src/interfaces/IFxTicketFactory.sol";
import {IRoyaltyManager} from "src/interfaces/IRoyaltyManager.sol";
import {ISeedConsumer} from "src/interfaces/ISeedConsumer.sol";
import {ISplitsFactory} from "src/interfaces/ISplitsFactory.sol";
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

    // Metadata
    bytes internal baseURI;
    bytes internal fxParams;
    bytes internal onchainData;
    bytes32 internal seed;
    uint120 internal inputSize;

    // Project
    string internal contractURI;
    string internal defaultMetadataURI;
    uint96 internal projectId;
    uint128 internal lockTime;
    uint128 internal referrerShare;
    uint256[] internal tagIds;

    // Royalties
    address payable[] internal royaltyReceivers;
    uint96[] internal basisPoints;

    // Splits
    address internal primaryReceiver;
    address[] internal accounts;
    uint32[] internal allocations;

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
    bytes internal mintParams;
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
    }

    function _initializeState() internal virtual {
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

    function _configureSplits() internal virtual {
        accounts.push(creator);
        accounts.push(admin);
        allocations.push(CREATOR_ALLOCATION);
        allocations.push(ADMIN_ALLOCATION);
    }

    function _configureRoyalties() internal virtual {
        royaltyReceivers.push(payable(admin));
        royaltyReceivers.push(payable(creator));
        basisPoints.push(ROYALTY_BPS);
        basisPoints.push(ROYALTY_BPS * 2);
    }

    function _configureProject(bool _mintEnabled, uint120 _maxSupply) internal virtual {
        projectInfo.mintEnabled = _mintEnabled;
        projectInfo.maxSupply = _maxSupply;
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
            address(ipfsRenderer),
            uint48(ONE_DAY),
            mintInfo
        );
        vm.label(fxMintTicketProxy, "FxMintTicketProxy");
    }
}
