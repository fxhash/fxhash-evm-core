// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {FxRandomizer} from "src/FxRandomizer.sol";
import {BaseTest} from "test/BaseTest.t.sol";

contract FxRandomizerTest is BaseTest {
    FxRandomizer internal randomizer;

    function setUp() public override {
        randomizer = new FxRandomizer();
    }
}
