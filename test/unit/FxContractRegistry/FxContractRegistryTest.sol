// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {FxContractRegistry} from "src/registries/FxContractRegistry.sol";
import {IFxContractRegistry} from "src/interfaces/IFxContractRegistry.sol";

contract FxContractRegistryTest is BaseTest {
    FxContractRegistry internal registry;

    function setUp() public virtual override {
        super.setUp();
        registry = new FxContractRegistry();
    }
}
