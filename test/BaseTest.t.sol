// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Deploy} from "script/Deploy.s.sol";
import {FxContractRegistry} from "src/registries/FxContractRegistry.sol";
import {FxGenArt721} from "src/tokens/FxGenArt721.sol";
import {FxIssuerFactory, ConfigInfo} from "src/factories/FxIssuerFactory.sol";
import {FxPseudoRandomizer} from "src/randomizers/FxPseudoRandomizer.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";
import {FxScriptyRenderer} from "src/renderers/FxScriptyRenderer.sol";
import {FxSplitsFactory} from "src/factories/FxSplitsFactory.sol";
import {
    HTMLRequest,
    HTMLTagType,
    HTMLTag
} from "scripty.sol/contracts/scripty/core/ScriptyStructs.sol";
import {
    IFxGenArt721,
    GenArtInfo,
    IssuerInfo,
    MetadataInfo,
    MintInfo,
    ProjectInfo,
    ReserveInfo
} from "src/interfaces/IFxGenArt721.sol";
import {ISeedConsumer} from "src/interfaces/ISeedConsumer.sol";
import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";
import {Test} from "forge-std/Test.sol";

import "script/utils/Constants.sol";
import "src/utils/Constants.sol";
import "test/utils/Constants.sol";

contract BaseTest is Deploy, Test {
    // Users
    address internal alice;
    address internal bob;
    address internal eve;
    address internal susan;

    address internal owner;
    uint96 internal projectId;

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
        createAccounts();
        _deployContracts();
    }

    function createAccounts() public virtual {
        admin = makeAddr("admin");
        creator = makeAddr("creator");
        tokenMod = makeAddr("tokenMod");
        userMod = makeAddr("userMod");
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        eve = makeAddr("eve");
        susan = makeAddr("susan");
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
