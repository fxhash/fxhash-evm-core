// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {FxContractRegistry} from "src/registries/FxContractRegistry.sol";
import {FxGenArt721} from "src/FxGenArt721.sol";
import {FxIssuerFactory} from "src/factories/FxIssuerFactory.sol";
import {FxSplitsFactory} from "src/factories/FxSplitsFactory.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";
import {FxTokenRenderer} from "src/FxTokenRenderer.sol";
import {
    GenArtInfo,
    IssuerInfo,
    MetadataInfo,
    MintInfo,
    ProjectInfo,
    ReserveInfo
} from "src/interfaces/IFxGenArt721.sol";
import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";
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
    FxSplitsFactory internal splitsFactory;
    FxTokenRenderer internal fxTokenRenderer;

    // Accounts
    address internal admin;
    address internal creator;
    address internal minter;
    address internal tokenMod;
    address internal userMod;
    address internal alice;
    address internal bob;
    address internal eve;
    address internal susan;

    // Structs
    IssuerInfo internal issuerInfo;
    GenArtInfo internal genArtInfo;
    MetadataInfo internal metadataInfo;
    MintInfo[] internal mintInfo;
    ProjectInfo internal projectInfo;
    ReserveInfo internal reserveInfo;

    // Project
    address internal fxGenArtProxy;
    address internal owner;
    address internal primaryReceiver;
    uint96 internal projectId;
    string internal contractURI;

    // Royalties
    address payable[] internal royaltyReceivers;
    uint96[] internal basisPoints;

    // Splits
    address[] internal accounts;
    uint32[] internal allocations;

    // Modifiers
    modifier prank(address _caller) {
        vm.startPrank(_caller);
        _;
        vm.stopPrank();
    }

    function setUp() public virtual {
        createAccounts();
        deployContracts(admin);
    }

    function createAccounts() public virtual {
        admin = _createUser("admin");
        creator = _createUser("creator");
        minter = _createUser("minter");
        tokenMod = _createUser("tokenMod");
        userMod = _createUser("userMod");
        alice = _createUser("alice");
        bob = _createUser("bob");
        eve = _createUser("eve");
        susan = _createUser("susan");
    }

    function deployContracts(address _admin) public virtual prank(_admin) {
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
        vm.label(address(fxGenArt721), "FxGenArt721");
        vm.label(address(fxIssuerFactory), "FxIssuerFactory");
        vm.label(address(fxRoleRegistry), "FxRoleRegistry");
        vm.label(address(fxTokenRenderer), "FxTokenRenderer");
    }

    function _createUser(string memory _name) internal returns (address user) {
        user = address(uint160(uint256(keccak256(abi.encodePacked(_name)))));
        vm.deal(user, INITIAL_BALANCE);
        vm.label(user, _name);
    }

    function _mock0xSplits() internal {
        bytes memory splitMainBytecode = abi.encodePacked(SPLITS_MAIN_CREATION_CODE, abi.encode());
        address deployedAddress_;
        vm.prank(SPLITS_DEPLOYER);
        vm.setNonce(SPLITS_DEPLOYER, SPLITS_DEPLOYER_NONCE);
        assembly {
            deployedAddress_ := create(0, add(splitMainBytecode, 32), mload(splitMainBytecode))
        }
    }
}
