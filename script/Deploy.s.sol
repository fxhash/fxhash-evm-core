// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ContractRegistry} from "contracts/registries/ContractRegistry.sol";
import {FxGenArt721, IssuerInfo, MintInfo, ProjectInfo, ReserveInfo} from "contracts/tokens/FxGenArt721.sol";
import {FxIssuerFactory} from "contracts/factories/FxIssuerFactory.sol";
import {FxMetadata} from "contracts/metadata/FxMetadata.sol";
import {RoleRegistry} from "contracts/registries/RoleRegistry.sol";
import {Script} from "forge-std/Script.sol";

import "contracts/utils/Constants.sol";

contract Deploy is Script {
    // Contracts
    ContractRegistry public contractRegistry;
    FxIssuerFactory public fxIssuerFactory;
    FxGenArt721 public fxGenArt721;
    FxMetadata public fxMetadata;
    RoleRegistry public roleRegistry;

    // Storage
    address public fxGenArtProxy;
    address public primaryReceiver;
    ProjectInfo public projectInfo;
    MintInfo[] public mintInfo;
    address payable[] public royaltyReceivers;
    uint96[] public basisPoints;

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
        contractRegistry = new ContractRegistry();
        roleRegistry = new RoleRegistry();
        fxGenArt721 = new FxGenArt721(address(contractRegistry), address(roleRegistry));
        fxIssuerFactory = new FxIssuerFactory(address(fxGenArt721));
        fxMetadata = new FxMetadata(ETHFS_FILE_STORAGE, SCRIPTY_STORAGE_V2, SCRIPTY_BUILDER_V2);
    }

    function configure() public {
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
