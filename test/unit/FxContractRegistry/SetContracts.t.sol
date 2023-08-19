// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {FxContractRegistryTest} from "test/unit/FxContractRegistry/FxContractRegistryTest.sol";

contract SetContracts is FxContractRegistryTest {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_True() public {
        assertTrue(true);
    }
}
