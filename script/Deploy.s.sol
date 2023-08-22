// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {FxContractRegistry} from "src/registries/FxContractRegistry.sol";
import {FxGenArt721, IssuerInfo, MintInfo, ProjectInfo, ReserveInfo} from "src/FxGenArt721.sol";
import {FxIssuerFactory} from "src/factories/FxIssuerFactory.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";
import {FxTokenRenderer} from "src/FxTokenRenderer.sol";
import {Script} from "forge-std/Script.sol";

import "src/utils/Constants.sol";
import "script/utils/Constants.sol";

contract Deploy is Script {
    // Contracts
    FxContractRegistry public fxContractRegistry;
    FxIssuerFactory public fxIssuerFactory;
    FxGenArt721 public fxGenArt721;
    FxRoleRegistry public fxRoleRegistry;
    FxTokenRenderer public fxTokenRenderer;

    // State
    address public fxGenArtProxy;
    address public owner;
    address public primaryReceiver;
    IssuerInfo public isserInfo;
    ProjectInfo public projectInfo;
    MintInfo[] public mintInfo;
    ReserveInfo[] public reserveInfo;
    address payable[] public royaltyReceivers;
    uint96[] public basisPoints;

    function setUp() public virtual {
        owner = msg.sender;
        _mock0xSplits();
    }

    function run() public virtual {
        vm.startBroadcast();
        _deployContracts();
        _configureSettings();
        vm.stopBroadcast();
    }

    function _deployContracts() internal {
        fxContractRegistry = new FxContractRegistry();
        fxRoleRegistry = new FxRoleRegistry();
        fxGenArt721 = new FxGenArt721(
            address(fxContractRegistry),
            address(fxRoleRegistry)
        );
        fxIssuerFactory = new FxIssuerFactory(address(fxGenArt721));
        fxTokenRenderer = new FxTokenRenderer(
            ETHFS_FILE_STORAGE,
            SCRIPTY_STORAGE_V2,
            SCRIPTY_BUILDER_V2
        );
    }

    function _configureSettings() internal {
        fxGenArtProxy = fxIssuerFactory.createProject(
            owner, primaryReceiver, projectInfo, mintInfo, royaltyReceivers, basisPoints
        );
        FxGenArt721(fxGenArtProxy).setRenderer(address(fxTokenRenderer));
    }

    function _mock0xSplits() internal {
        bytes memory splitsMainBytecode = abi.encodePacked(SPLITS_MAIN_CREATION_CODE, abi.encode());
        address deployedAddress_;
        vm.prank(SPLITS_DEPLOYER);
        vm.setNonce(SPLITS_DEPLOYER, SPLITS_DEPLOYER_NONCE);
        assembly {
            deployedAddress_ := create(0, add(splitsMainBytecode, 32), mload(splitsMainBytecode))
        }
        primaryReceiver = deployedAddress_;
    }
}
