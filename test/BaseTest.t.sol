// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {FxContractRegistry} from "src/registries/FxContractRegistry.sol";
import {
    FxGenArt721,
    GenArtInfo,
    IssuerInfo,
    MintInfo,
    ProjectInfo,
    ReserveInfo
} from "src/FxGenArt721.sol";
import {FxIssuerFactory} from "src/factories/FxIssuerFactory.sol";
import {FxTokenRenderer} from "src/FxTokenRenderer.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";
import {Test} from "forge-std/Test.sol";

import "script/utils/Constants.sol";
import "src/utils/Constants.sol";
import "test/utils/Constants.sol";

contract BaseTest is Test {
    // Contracts
    FxContractRegistry internal fxContractRegistry;
    FxIssuerFactory internal fxIssuerFactory;
    FxGenArt721 internal fxGenArt721;
    FxRoleRegistry internal fxRoleRegistry;
    FxTokenRenderer internal fxTokenRenderer;

    // Users
    address internal admin;
    address internal moderator;
    address internal creator;
    address internal alice;
    address internal bob;
    address internal eve;
    address internal susan;

    // Structs
    IssuerInfo internal isserInfo;
    ProjectInfo internal projectInfo;
    MintInfo[] internal mintInfo;
    ReserveInfo[] internal reserveInfo;
    GenArtInfo internal genArtInfo;

    // State
    address internal fxGenArtProxy;
    address internal owner;
    address internal primaryReceiver;
    address payable[] internal royaltyReceivers;
    uint96[] internal basisPoints;
    uint96 internal projectId;

    // Modifiers
    modifier prank(address _caller) {
        vm.startPrank(_caller);
        _;
        vm.stopPrank();
    }

    function setUp() public virtual {
        createAccounts();
        deployContracts();
    }

    function createAccounts() public virtual {
        admin = _createUser("admin");
        moderator = _createUser("moderator");
        creator = _createUser("creator");
        alice = _createUser("alice");
        bob = _createUser("bob");
        eve = _createUser("eve");
        susan = _createUser("susan");
    }

    function deployContracts() public virtual {
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

        vm.label(address(this), "BaseTest");
        vm.label(address(fxContractRegistry), "FxContractRegistry");
        vm.label(address(fxRoleRegistry), "FxRoleRegistry");
        vm.label(address(fxGenArt721), "FxGenArt721");
        vm.label(address(fxIssuerFactory), "FxIssuerFactory");
        vm.label(address(fxTokenRenderer), "FxTokenRenderer");
    }

    function _createUser(string memory _name) internal returns (address user) {
        user = address(uint160(uint256(keccak256(abi.encodePacked(_name)))));
        vm.deal(user, INITIAL_BALANCE);
        vm.label(user, _name);
    }
}
