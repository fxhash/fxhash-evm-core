// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MockMintPass} from "test/mocks/MockMintPass.sol";
import {BaseTest} from "test/BaseTest.t.sol";

contract MintPassTest is BaseTest {
    MockMintPass internal mintPass;

    function setUp() public override {
        mintPass = new MockMintPass(address(this));
    }
}
