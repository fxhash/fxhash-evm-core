// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {FxContractRegistry} from "contracts/registries/FxContractRegistry.sol";
import {
    FxGenArt721, IssuerInfo, MintInfo, ProjectInfo, ReserveInfo
} from "contracts/FxGenArt721.sol";
import {FxIssuerFactory} from "contracts/factories/FxIssuerFactory.sol";
import {FxRoleRegistry} from "contracts/registries/FxRoleRegistry.sol";
import {FxTokenRenderer} from "contracts/FxTokenRenderer.sol";
import {Script} from "forge-std/Script.sol";

import "contracts/utils/Constants.sol";
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
    address public primaryReceiver;
    IssuerInfo public isserInfo;
    ProjectInfo public projectInfo;
    MintInfo[] public mintInfo;
    ReserveInfo[] public reserveInfo;
    address payable[] public royaltyReceivers;
    uint96[] public basisPoints;

    function setUp() public virtual {}

    function run() public virtual {
        vm.startBroadcast();
        deployContracts();
        configureSettings();
        vm.stopBroadcast();
    }

    function deployContracts() public {
        fxContractRegistry = new FxContractRegistry();
        fxRoleRegistry = new FxRoleRegistry();
        fxGenArt721 = new FxGenArt721(address(fxContractRegistry), address(fxRoleRegistry));
        fxIssuerFactory = new FxIssuerFactory(address(fxGenArt721));
        fxTokenRenderer =
            new FxTokenRenderer(ETHFS_FILE_STORAGE, SCRIPTY_STORAGE_V2, SCRIPTY_BUILDER_V2);
    }

    function configureSettings() public {
        fxGenArtProxy = fxIssuerFactory.createProject(
            msg.sender, primaryReceiver, projectInfo, mintInfo, royaltyReceivers, basisPoints
        );
        FxGenArt721(fxGenArtProxy).setRenderer(address(fxTokenRenderer));
    }
}
