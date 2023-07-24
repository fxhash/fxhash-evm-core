// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {IFxHashFactory} from "contracts/interfaces/IFxHashFactory.sol";
import {IGenTkFactory} from "contracts/interfaces/IGenTkFactory.sol";
import {IIssuerFactory} from "contracts/interfaces/IIssuerFactory.sol";

import {FxHashFactory} from "contracts/factories/FxHashFactory.sol";
import {GenTkFactory} from "contracts/factories/GenTkFactory.sol";
import {IssuerFactory} from "contracts/factories/IssuerFactory.sol";

import {Deploy} from "script/Deploy.s.sol";
import {LibRoyalty} from "contracts/libs/LibRoyalty.sol";

contract FxHashFactoryTest is Test, Deploy {
    event IssuerCreated(address indexed _owner, address _configManager, address indexed issuer);
    event GenTkCreated(
        address indexed _owner,
        address indexed _issuer,
        address _configManager,
        address indexed genTk
    );
    event FxHashProjectCreated(
        address indexed _owner,
        address indexed _issuer,
        address indexed genTk,
        address _configManager
    );
}

contract CreateProject is FxHashFactoryTest {
    LibRoyalty.RoyaltyData public royalty;

    function setUp() public virtual override {
        createAccounts();
        Deploy.run();
    }

    function test_createProject() public {
        vm.expectEmit(true, false, false, false, address(issuerFactory));
        emit IssuerCreated(alice, address(configurationManager), address(0));
        vm.expectEmit(true, false, false, false, address(genTkFactory));
        emit GenTkCreated(alice, address(0), address(configurationManager), address(0));
        vm.expectEmit(true, false, false, false, address(fxHashFactory));
        emit FxHashProjectCreated(alice, address(0), address(0), address(configurationManager));
        (address issuer, address gentk) = fxHashFactory.createProject(royalty, alice);
        assertNotEq(issuer, address(0));
        assertNotEq(gentk, address(0));
        assertEq(issuer.code.length > 0, true);
        assertEq(gentk.code.length > 0, true);
    }
}
