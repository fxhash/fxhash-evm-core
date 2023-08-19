// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {FxRoleRegistryTest} from "test/unit/FxRoleRegistry/FxRoleRegistryTest.sol";

contract SetRoleAdmin is FxRoleRegistryTest {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_SetRoleAdmin() public {
        assertTrue(true);
    }
}
