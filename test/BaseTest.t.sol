// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ContractRegistry} from "contracts/registries/ContractRegistry.sol";
import {FxGenArt721, IssuerInfo, GenArtInfo, MintInfo, ProjectInfo, ReserveInfo} from "contracts/FxGenArt721.sol";
import {FxIssuerFactory} from "contracts/FxIssuerFactory.sol";
import {FxRenderer} from "contracts/FxRenderer.sol";
import {RoleRegistry} from "contracts/registries/RoleRegistry.sol";
import {Test} from "forge-std/Test.sol";

import "contracts/utils/Constants.sol";
import "script/utils/Constants.sol";
import "test/utils/Constants.sol";

contract BaseTest is Test {
    // Contracts
    ContractRegistry public contractRegistry;
    FxIssuerFactory public fxIssuerFactory;
    FxGenArt721 public fxGenArt721;
    FxRenderer public fxRenderer;
    RoleRegistry public roleRegistry;

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
    address public primaryReceiver;
    address payable[] public royaltyReceivers;
    uint96[] public basisPoints;

    // Modifiers
    modifier prank(address _caller) {
        vm.startPrank(_caller);
        _;
        vm.stopPrank();
    }

    function setUp() public virtual {
        createAccounts();
        deployContracts();
        configureSettings();
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
        contractRegistry = new ContractRegistry();
        roleRegistry = new RoleRegistry();
        fxGenArt721 = new FxGenArt721(address(contractRegistry), address(roleRegistry));
        fxIssuerFactory = new FxIssuerFactory(address(fxGenArt721));
        fxRenderer = new FxRenderer(ETHFS_FILE_STORAGE, SCRIPTY_STORAGE_V2, SCRIPTY_BUILDER_V2);

        vm.label(address(this), "BaseTest");
        vm.label(address(contractRegistry), "ContractRegistry");
        vm.label(address(roleRegistry), "RoleRegistry");
        vm.label(address(fxGenArt721), "FxGenArt721");
        vm.label(address(fxIssuerFactory), "FxIssuerFactory");
        vm.label(address(fxRenderer), "FxRenderer");
    }

    function configureSettings() public virtual {
        fxGenArtProxy = fxIssuerFactory.createProject(
            msg.sender,
            primaryReceiver,
            projectInfo,
            mintInfo,
            royaltyReceivers,
            basisPoints
        );
        FxGenArt721(fxGenArtProxy).setRenderer(address(fxRenderer));

        vm.label(address(fxGenArtProxy), "FxGenArtProxy");
    }

    function _createUser(string memory _name) internal returns (address user) {
        user = address(uint160(uint256(keccak256(abi.encodePacked(_name)))));
        vm.deal(user, INITIAL_BALANCE);
        vm.label(user, _name);
    }
}
