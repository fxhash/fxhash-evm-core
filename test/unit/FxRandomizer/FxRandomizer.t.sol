// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {FxRandomizer} from "src/FxRandomizer.sol";
import {IFxSeedConsumer} from "src/interfaces/IFxSeedConsumer.sol";

contract FxRandomizerTest is BaseTest {
    FxRandomizer internal randomizer;
    bytes32 internal seed;
    uint256 internal tokenId;

    function setUp() public override {
        randomizer = new FxRandomizer();
        tokenId = 123;
    }
}
