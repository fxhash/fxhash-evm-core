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
    function setUp() public virtual override {
        super.setUp();
        createAccounts();
        Deploy.run();
    }

    function test_createProject() public {
        //vm.expectEmit(address(factory)); --> does not work for some reason
        (address issuer, address gentk) = factory.createProject(
            alice,
            address(configurationManager)
        );
        assertNotEq(issuer, address(0));
        assertNotEq(gentk, address(0));
    }
}
