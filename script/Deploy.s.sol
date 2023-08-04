// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ConfigManager, ConfigInfo} from "contracts/admin/config/ConfigManager.sol";
import {FxIssuerFactory} from "contracts/factories/FxIssuerFactory.sol";
import {FxGenArt721, IssuerInfo, ProjectInfo} from "contracts/tokens/FxGenArt721.sol";
import {FxMetadata} from "contracts/metadata/FxMetadata.sol";
import {Script} from "forge-std/Script.sol";

import "contracts/utils/Constants.sol";

contract Deploy is Script {
    // Contracts
    ConfigManager public configManager;
    FxIssuerFactory public fxIssuerFactory;
    FxGenArt721 public fxGenArt721;
    FxMetadata public fxMetadata;

    // Storage
    address public fxGenArtProxy;
    address public primaryReceiver;
    ProjectInfo public projectInfo;
    address payable[] public royaltyReceivers;
    uint96[] public basisPoints;
    address[] public minters;

    // Goerli
    address public constant ETHFS_FILE_STORAGE = 0x70a78d91A434C1073D47b2deBe31C184aA8CA9Fa;
    address public constant SCRIPTY_STORAGE_V2 = 0x4e2f40eef8DFBF200f3f744a9733Afe2E9F83D28;
    address public constant SCRIPTY_BUILDER_V2 = 0xccd7E419f1EEc86fa748c9079584e3a89312f11C;

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
        fxMetadata = new FxMetadata(ETHFS_FILE_STORAGE, SCRIPTY_STORAGE_V2, SCRIPTY_BUILDER_V2);
    }

    function configure() public {
        fxIssuerFactory.setImplementation(address(fxGenArt721));
        fxGenArtProxy = fxIssuerFactory.createProject(
            msg.sender,
            primaryReceiver,
            projectInfo,
            royaltyReceivers,
            basisPoints,
            minters
        );
        FxGenArt721(fxGenArtProxy).setMetadata(address(fxMetadata));
    }
}
