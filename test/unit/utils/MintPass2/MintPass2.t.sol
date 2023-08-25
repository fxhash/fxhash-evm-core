// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MintPass} from "src/utils/MintPass-EIP712.sol";
import {BaseTest} from "test/BaseTest.t.sol";

contract MintPass712Test is BaseTest {
    MintPass internal mintPass;

    function setUp() public override {
        mintPass = new MintPass(address(this));
    }
}
