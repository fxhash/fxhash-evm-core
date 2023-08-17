// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {BaseTest} from "test/BaseTest.t.sol";
import {calculateExponentialDecay} from "src/utils/ExponentialDecayMath.sol";

contract ExponentialDecayMathTest is BaseTest {
    int256 internal initialPrice;
    int256 internal percentDecay;
    int256 internal timeSinceStart;

    function setUp() public virtual override {}
}
