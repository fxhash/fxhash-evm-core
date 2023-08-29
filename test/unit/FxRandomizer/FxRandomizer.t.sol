// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {IFxSeedConsumer} from "src/interfaces/IFxSeedConsumer.sol";

contract FxRandomizerTest is BaseTest {
    function setUp() public override {
        super.setUp();
        tokenId = 1;
    }
}
