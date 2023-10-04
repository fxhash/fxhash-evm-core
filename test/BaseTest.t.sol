// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "script/Deploy.s.sol";

import {ISeedConsumer} from "src/interfaces/ISeedConsumer.sol";
import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";
import {MockMinter} from "test/mocks/MockMinter.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

contract BaseTest is Deploy, Test {
    // Accounts
    address internal alice;
    address internal bob;
    address internal eve;
    address internal susan;

    // State
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
                                     HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _createAccounts() internal virtual override {
        admin = makeAddr("admin");
        creator = makeAddr("creator");
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        eve = makeAddr("eve");
        susan = makeAddr("susan");
    }

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

    function _mockMinter(address _admin) internal prank(_admin) {
        minter = address(new MockMinter());
    }

    function _mockSplits(address _deployer) internal prank(_deployer) {
        bytes memory splitMainBytecode = abi.encodePacked(SPLITS_MAIN_CREATION_CODE, abi.encode());
        address deployedAddress;
        vm.setNonce(SPLITS_DEPLOYER, SPLITS_DEPLOYER_NONCE);
        assembly {
            deployedAddress := create(0, add(splitMainBytecode, 32), mload(splitMainBytecode))
        }
    }

    function _grantRole(address _admin, bytes32 _role, address _user) internal prank(_admin) {
        fxRoleRegistry.grantRole(_role, _user);
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
