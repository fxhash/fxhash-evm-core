// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ConfigManager, ConfigInfo} from "contracts/admin/config/ConfigManager.sol";
import {FxIssuerFactory} from "contracts/factories/FxIssuerFactory.sol";
import {FxGenArt721, IssuerInfo, ProjectInfo} from "contracts/tokens/FxGenArt721.sol";
import {Script} from "forge-std/Script.sol";

import "contracts/utils/Constants.sol";

contract Deploy is Script {
    // Contracts
    ConfigManager public configManager;
    FxIssuerFactory public fxIssuerFactory;
    FxGenArt721 public fxGenArt721;

    // Storage
    address public implementation;
    address public primaryReceiver;
    ProjectInfo public projectInfo;
    address payable[] public royaltyReceivers;
    uint96[] public basisPoints;
    address[] public minters;

    function setUp() public virtual {}

    function run() public virtual {
        vm.startBroadcast();
        deploy();
        configure();
        vm.stopBroadcast();
    }

    function deploy() public {
        configManager = new ConfigManager();
        fxIssuerFactory = new FxIssuerFactory(address(configManager));
        fxGenArt721 = new FxGenArt721();
    }

    function configure() public {
        fxIssuerFactory.setImplementation(address(fxGenArt721));
        implementation = fxIssuerFactory.createProject(
            msg.sender,
            primaryReceiver,
            projectInfo,
            royaltyReceivers,
            basisPoints,
            minters
        );
    }
}
