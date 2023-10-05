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

import {IFxContractRegistry} from "src/interfaces/IFxContractRegistry.sol";
import {IFxSplitsFactory} from "src/interfaces/IFxSplitsFactory.sol";
import {IFxTicketFactory} from "src/interfaces/IFxTicketFactory.sol";
import {IFixedPrice} from "src/interfaces/IFixedPrice.sol";
import {IRoyaltyManager} from "src/interfaces/IRoyaltyManager.sol";
import {ISeedConsumer} from "src/interfaces/ISeedConsumer.sol";
import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";

contract BaseTest is Deploy, Test {
    // Mocks
    MockAllowlist internal allowlist;
    MockMintPass internal mintPass;
    MockRoyaltyManager internal royaltyManager;

    // Accounts
    address internal alice;
    address internal bob;
    address internal eve;
    address internal susan;

    // State
    address internal minter;
    address internal owner;
    bytes internal fxParams;
    bytes32 internal seed;
    uint96 internal projectId;

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
        _deployContracts();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    ACCOUNTS
    //////////////////////////////////////////////////////////////////////////*/

    function _createAccounts() internal virtual override {
        super._createAccounts();
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
    }

    function _initializeState() internal virtual {
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

    function _mockSplits(address _deployer) internal prank(_deployer) {
        bytes memory splitMainBytecode = abi.encodePacked(SPLITS_MAIN_CREATION_CODE, abi.encode());
        address deployedAddress;
        vm.setNonce(SPLITS_DEPLOYER, 0);
        assembly {
            deployedAddress := create(0, add(splitMainBytecode, 32), mload(splitMainBytecode))
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     SETTERS
    //////////////////////////////////////////////////////////////////////////*/

    function _grantRole(address _admin, bytes32 _role, address _account) internal prank(_admin) {
        fxRoleRegistry.grantRole(_role, _account);
    }

    function _registerContracts(address _admin) internal virtual override prank(_admin) {
        super._registerContracts(_admin);
    }

    function _setRandomizer(address _admin, address _randomizer) internal prank(_admin) {
        FxGenArt721(fxGenArtProxy).setRandomizer(_randomizer);
    }

    function _setRenderer(address _admin, address _renderer) internal prank(_admin) {
        FxGenArt721(fxGenArtProxy).setRenderer(_renderer);
    }
}
