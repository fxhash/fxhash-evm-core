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
import {Test} from "forge-std/Test.sol";

import "script/utils/Constants.sol";
import "src/utils/Constants.sol";
import "test/utils/Constants.sol";

contract BaseTest is Test {
    // Contracts
    FxContractRegistry public fxContractRegistry;
    FxIssuerFactory public fxIssuerFactory;
    FxGenArt721 public fxGenArt721;
    FxRoleRegistry public fxRoleRegistry;
    FxTokenRenderer public fxTokenRenderer;

    // Users
    address public admin;
    address public moderator;
    address public creator;
    address public alice;
    address public bob;
    address public eve;
    address public susan;

    // Structs
    IssuerInfo public isserInfo;
    ProjectInfo public projectInfo;
    MintInfo[] public mintInfo;
    ReserveInfo[] public reserveInfo;
    GenArtInfo public genArtInfo;

    // State
    address public fxGenArtProxy;
    address public owner;
    address public primaryReceiver;
    address payable[] public royaltyReceivers;
    uint96[] public basisPoints;
    uint96 public projectId;

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
        primaryReceiver = creator;
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
