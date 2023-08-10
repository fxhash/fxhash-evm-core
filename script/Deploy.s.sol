// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ContractRegistry} from "contracts/registries/ContractRegistry.sol";
import {FxGenArt721, IssuerInfo, MintInfo, ProjectInfo, ReserveInfo} from "contracts/FxGenArt721.sol";
import {FxIssuerFactory} from "contracts/FxIssuerFactory.sol";
import {FxMetadata} from "contracts/FxMetadata.sol";
import {RoleRegistry} from "contracts/registries/RoleRegistry.sol";
import {Script} from "forge-std/Script.sol";

import "contracts/utils/Constants.sol";
import "script/utils/Constants.sol";

contract Deploy is Script {
    // Contracts
    ContractRegistry public contractRegistry;
    FxIssuerFactory public fxIssuerFactory;
    FxGenArt721 public fxGenArt721;
    FxMetadata public fxMetadata;
    RoleRegistry public roleRegistry;

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
        contractRegistry = new ContractRegistry();
        roleRegistry = new RoleRegistry();
        fxGenArt721 = new FxGenArt721(address(contractRegistry), address(roleRegistry));
        fxIssuerFactory = new FxIssuerFactory(address(fxGenArt721));
        fxMetadata = new FxMetadata(ETHFS_FILE_STORAGE, SCRIPTY_STORAGE_V2, SCRIPTY_BUILDER_V2);
    }

    function configureSettings() public {
        fxGenArtProxy = fxIssuerFactory.createProject(
            msg.sender,
            primaryReceiver,
            projectInfo,
            mintInfo,
            royaltyReceivers,
            basisPoints
        );
        FxGenArt721(fxGenArtProxy).setMetadata(address(fxMetadata));
    }
}
