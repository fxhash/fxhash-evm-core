// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {IFxSeedConsumer} from "src/interfaces/IFxSeedConsumer.sol";

contract FxRandomizerTest is BaseTest {
    bytes32 internal seed;
    uint256 internal tokenId;

    function setUp() public override {
        tokenId = 123;
    }
}
