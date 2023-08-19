// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {BaseTest} from "test/BaseTest.t.sol";
import {FxContractRegistry} from "src/registries/FxContractRegistry.sol";

contract FxContractRegistryTest is BaseTest {
    FxContractRegistry public registry;

    function setUp() public virtual override {
        registry = new FxContractRegistry();
    }
}
