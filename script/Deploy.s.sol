// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {FxContractRegistry} from "src/registries/FxContractRegistry.sol";
import {
    FxGenArt721,
    IssuerInfo,
    MetadataInfo,
    MintInfo,
    ProjectInfo,
    ReserveInfo
} from "src/FxGenArt721.sol";
import {FxIssuerFactory, ConfigInfo} from "src/factories/FxIssuerFactory.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";
import {FxSplitsFactory} from "src/factories/FxSplitsFactory.sol";
import {FxTokenRenderer} from "src/FxTokenRenderer.sol";
import {Script} from "forge-std/Script.sol";

import "script/utils/Constants.sol";
import "src/utils/Constants.sol";

contract Deploy is Script {
    // Contracts
    FxContractRegistry internal fxContractRegistry;
    FxIssuerFactory internal fxIssuerFactory;
    FxGenArt721 internal fxGenArt721;
    FxRoleRegistry internal fxRoleRegistry;
    FxSplitsFactory internal fxSplitsFactory;
    FxTokenRenderer internal fxTokenRenderer;

    // Accounts
    address internal admin;
    address internal creator;
    address internal minter;
    address internal tokenMod;
    address internal userMod;

    // Structs
    ConfigInfo internal configInfo;
    IssuerInfo internal isserInfo;
    MetadataInfo internal metadataInfo;
    MintInfo[] internal mintInfo;
    ProjectInfo internal projectInfo;
    ReserveInfo internal reserveInfo;

    // Project
    address internal fxGenArtProxy;
    address internal primaryReceiver;

    // Royalties
    address payable[] internal royaltyReceivers;
    uint96[] internal basisPoints;

    // Splits
    address[] internal accounts;
    uint32[] internal allocations;

    function setUp() public virtual {
        _createAccounts();
    }

    function run() public virtual {
        vm.startBroadcast();
        _deployContracts();
        _createSplit();
        _configureSettings();
        vm.stopBroadcast();
    }

    function _createAccounts() internal {
        admin = msg.sender;
        creator = address(uint160(uint256(keccak256(abi.encodePacked("creator")))));
        minter = address(uint160(uint256(keccak256(abi.encodePacked("minter")))));
        tokenMod = address(uint160(uint256(keccak256(abi.encodePacked("tokenMod")))));
        userMod = address(uint160(uint256(keccak256(abi.encodePacked("userMod")))));
    }

    function _deployContracts() internal {
        fxContractRegistry = new FxContractRegistry();
        fxRoleRegistry = new FxRoleRegistry();
        fxGenArt721 = new FxGenArt721(
            address(fxContractRegistry),
            address(fxRoleRegistry)
        );
        fxIssuerFactory = new FxIssuerFactory(address(fxGenArt721), configInfo);
        fxSplitsFactory = new FxSplitsFactory();
        fxTokenRenderer = new FxTokenRenderer(
            ETHFS_FILE_STORAGE,
            SCRIPTY_STORAGE_V2,
            SCRIPTY_BUILDER_V2
        );
    }

    function _createSplit() internal {
        accounts.push(admin);
        accounts.push(creator);
        allocations.push(SPLITS_ADMIN_ALLOCATION);
        allocations.push(SPLITS_CREATOR_ALLOCATION);
        primaryReceiver = fxSplitsFactory.createSplit(accounts, allocations);
    }

    function _configureSettings() internal {
        fxGenArtProxy = fxIssuerFactory.createProject(
            creator,
            primaryReceiver,
            projectInfo,
            metadataInfo,
            mintInfo,
            royaltyReceivers,
            basisPoints
        );
        FxGenArt721(fxGenArtProxy).setRenderer(address(fxTokenRenderer));
    }
}
