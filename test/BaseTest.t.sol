// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "script/Deploy.s.sol";

import {Allowlist} from "src/minters/extensions/Allowlist.sol";
import {ECDSA} from "openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MintPass} from "src/minters/extensions/MintPass.sol";
import {RoyaltyManager} from "src/tokens/extensions/RoyaltyManager.sol";
import {StandardMerkleTree} from "test/utils/StandardMerkleTree.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

import {MockAllowlist} from "test/mocks/MockAllowlist.sol";
import {MockMinter} from "test/mocks/MockMinter.sol";
import {MockMintPass} from "test/mocks/MockMintPass.sol";
import {MockRoyaltyManager} from "test/mocks/MockRoyaltyManager.sol";
import {MockSplitsController} from "test/mocks/MockSplitsController.sol";

import {IDutchAuction, AuctionInfo} from "src/interfaces/IDutchAuction.sol";
import {IFixedPrice} from "src/interfaces/IFixedPrice.sol";
import {IFxIssuerFactory} from "src/interfaces/IFxIssuerFactory.sol";
import {IFxTicketFactory} from "src/interfaces/IFxTicketFactory.sol";
import {IRoyaltyManager} from "src/interfaces/IRoyaltyManager.sol";
import {ISeedConsumer} from "src/interfaces/ISeedConsumer.sol";
import {ISplitsFactory} from "src/interfaces/ISplitsFactory.sol";
import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";
import {ITicketRedeemer} from "src/interfaces/ITicketRedeemer.sol";

import {RegistryLib} from "test/lib/helpers/RegistryLib.sol";
import {TicketLib} from "test/lib/helpers/TicketLib.sol";
import {TokenLib} from "test/lib/helpers/TokenLib.sol";

contract BaseTest is Deploy, Test {
    // Mocks
    MockAllowlist internal allowlist;
    MockMintPass internal mintPass;
    MockRoyaltyManager internal royaltyManager;

    // Accounts
    address internal creator;
    address internal deployer;
    address internal minter;
    address internal owner;
    address internal alice;
    address internal bob;
    address internal eve;
    address internal susan;

    // Allowlist
    bytes32 internal merkleRoot;
    uint256 internal mintPassSignerPk;

    // Metadata
    bytes internal fxParams;
    bytes internal onchainData;
    bytes32 internal seed;
    string internal baseURI;
    string internal imageURI;
    uint120 internal inputSize;
    HTMLRequest internal animation;
    HTMLRequest internal attributes;
    HTMLTag[] internal headTags;
    HTMLTag[] internal bodyTags;

    // Project
    string internal contractURI;
    string internal defaultMetadata;
    uint96 internal projectId;
    uint128 internal lockTime;
    uint128 internal referrerShare;
    uint256[] internal tagIds;

    // Registries
    address[] internal contracts;
    string[] internal names;

    // Royalties
    address payable[] internal royaltyReceivers;
    uint96[] internal basisPoints;

    // Scripty
    address internal ethFSFileStorage;
    address internal scriptyBuilderV2;
    address internal scriptyStorageV2;

    // Splits
    address internal splitsMain;
    address internal primaryReceiver;
    address[] internal accounts;
    uint32[] internal allocations;

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
        _createAccounts();
        _initializeAccounts();
        _mockSplits();
        _deployContracts();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    ACCOUNTS
    //////////////////////////////////////////////////////////////////////////*/

    function _createAccounts() internal virtual override {
        super._createAccounts();
        admin = address(this);
        creator = makeAddr("creator");
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        eve = makeAddr("eve");
        susan = makeAddr("susan");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INITIALIZATIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _initializeAccounts() internal virtual {
        vm.deal(admin, INITIAL_BALANCE);
        vm.deal(creator, INITIAL_BALANCE);
        vm.deal(alice, INITIAL_BALANCE);
        vm.deal(bob, INITIAL_BALANCE);
        vm.deal(eve, INITIAL_BALANCE);
        vm.deal(susan, INITIAL_BALANCE);
        vm.deal(address(this), INITIAL_BALANCE);
    }

    function _initializeState() internal virtual {
        tagIds.push(TAG_ID);
        deployer = address(this);
        vm.label(deployer, "Deployer");
        vm.warp(RESERVE_START_TIME);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     MOCKS
    //////////////////////////////////////////////////////////////////////////*/

    function _mockAllowlist(address _admin) internal prank(_admin) {
        allowlist = new MockAllowlist();
    }

    function _mockMinter(address _admin) internal prank(_admin) {
        minter = address(new MockMinter());
    }

    function _mockMintPass(address _admin, address _signer) internal prank(_admin) {
        mintPass = new MockMintPass(_signer);
    }

    function _mockRoyaltyManager(address _admin) internal prank(_admin) {
        royaltyManager = new MockRoyaltyManager();
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
}
