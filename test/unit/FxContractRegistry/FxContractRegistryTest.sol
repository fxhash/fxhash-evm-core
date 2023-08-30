// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseTest} from "test/BaseTest.t.sol";
import {FxContractRegistry} from "src/registries/FxContractRegistry.sol";

contract FxContractRegistryTest is BaseTest {
    FxContractRegistry public registry;

    function setUp() public virtual override {
        super.setUp();
        registry = new FxContractRegistry();
    }
}
