// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "script/Deploy.s.sol";

import {ISeedConsumer} from "src/interfaces/ISeedConsumer.sol";
import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";
import {MockMinter} from "test/mocks/MockMinter.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

contract BaseTest is Deploy, Test {
    // Users
    address internal alice;
    address internal bob;
    address internal eve;
    address internal susan;

    // State
    address internal owner;
    uint96 internal projectId;
    uint96 internal ticketId;

    // Metadata
    HTMLRequest internal attributes;

    // Modifiers
    modifier prank(address _caller) {
        vm.startPrank(_caller);
        _;
        vm.stopPrank();
    }

    receive() external payable {}

    function setUp() public virtual override {
        vm.pauseGasMetering();
        _createAccounts();
        _initializeAccounts();
        _deployContracts();
        vm.warp(RESERVE_START_TIME);
    }

    function _createAccounts() internal virtual override {
        admin = makeAddr("admin");
        creator = makeAddr("creator");
        tokenMod = makeAddr("tokenMod");
        userMod = makeAddr("userMod");
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        eve = makeAddr("eve");
        susan = makeAddr("susan");
    }

    function _initializeAccounts() internal virtual {
        vm.deal(admin, INITIAL_BALANCE);
        vm.deal(creator, INITIAL_BALANCE);
        vm.deal(tokenMod, INITIAL_BALANCE);
        vm.deal(userMod, INITIAL_BALANCE);
        vm.deal(alice, INITIAL_BALANCE);
        vm.deal(bob, INITIAL_BALANCE);
        vm.deal(eve, INITIAL_BALANCE);
        vm.deal(susan, INITIAL_BALANCE);
    }

    function _mock0xSplits() internal {
        bytes memory splitMainBytecode = abi.encodePacked(SPLITS_MAIN_CREATION_CODE, abi.encode());
        address deployedAddress_;
        vm.prank(SPLITS_DEPLOYER);
        vm.setNonce(SPLITS_DEPLOYER, SPLITS_DEPLOYER_NONCE);
        assembly {
            deployedAddress_ := create(0, add(splitMainBytecode, 32), mload(splitMainBytecode))
        }
    }

    function _setRandomizer(address _admin, address _randomizer) internal prank(_admin) {
        FxGenArt721(fxGenArtProxy).setRandomizer(_randomizer);
    }

    function _setRenderer(address _admin, address _renderer) internal prank(_admin) {
        FxGenArt721(fxGenArtProxy).setRenderer(_renderer);
    }

    function _registerMinter(address _admin, address _minter) internal prank(_admin) {
        fxRoleRegistry.grantRole(MINTER_ROLE, _minter);
    }
}
