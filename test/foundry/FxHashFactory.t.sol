// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {FxHashFactory} from "contracts/factories/FxHashFactory.sol";
import {Deploy} from "script/Deploy.s.sol";

contract FxHashFactoryTest is Test, Deploy {
    FxHashFactory public factory;

    function setUp() public virtual override {
        factory = new FxHashFactory();
    }
}

contract CreateProject is FxHashFactoryTest {
    event IssuerCreated(address indexed _owner, address _configManager, address indexed issuer);
    event GenTkCreated(
        address indexed _owner,
        address indexed _issuer,
        address _configManager,
        address indexed genTk
    );

    function setUp() public virtual override {
        super.setUp();
        createAccounts();
        Deploy.run();
    }

    function test_createProject() public {
        vm.expectEmit(true, false, true, false, address(factory));
        emit IssuerCreated(alice, address(configurationManager), address(0));
        emit GenTkCreated(alice, address(0), address(configurationManager), address(0));
        (address issuer, address gentk) = factory.createProject(
            alice,
            address(configurationManager)
        );
        assertNotEq(issuer, address(0));
        assertNotEq(gentk, address(0));
        assertEq(issuer.code.length > 0, true);
        assertEq(gentk.code.length > 0, true);
    }
}
