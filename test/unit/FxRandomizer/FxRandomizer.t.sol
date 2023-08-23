// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {FxRandomizer} from "src/FxRandomizer.sol";
import {IFxSeedConsumer} from "src/interfaces/IFxSeedConsumer.sol";

contract FxRandomizerTest is BaseTest {
    FxRandomizer internal randomizer;

    function setUp() public override {
        randomizer = new FxRandomizer();
    }
}
