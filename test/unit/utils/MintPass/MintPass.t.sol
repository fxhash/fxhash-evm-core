// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MintPass} from "src/utils/MintPass.sol";
import {BaseTest} from "test/BaseTest.t.sol";

contract MintPassTest is BaseTest {
    MintPass internal mintPass;

    function setUp() public override {
        mintPass = new MintPass(address(this));
    }
}
