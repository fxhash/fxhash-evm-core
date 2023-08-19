// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {BaseTest} from "test/BaseTest.t.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";

contract FxRoleRegistryTest is BaseTest {
    FxRoleRegistry public registry;

    function setUp() public virtual override {
        registry = new FxRoleRegistry();
    }
}
