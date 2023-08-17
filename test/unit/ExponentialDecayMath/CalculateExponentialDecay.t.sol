// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {
    ExponentialDecayMathTest,
    calculateExponentialDecay
} from "test/unit/ExponentialDecayMath/ExponentialDecayMath.t.sol";
import {
    toDaysWadUnsafe, toWadUnsafe, fromDaysWadUnsafe
} from "solmate/src/utils/SignedWadMath.sol";
import {console} from "forge-std/Test.sol";

contract CalculateExponentialDecay is ExponentialDecayMathTest {
    function setUp() public override {
        timeSinceStart = toDaysWadUnsafe(1);
        initialPrice = 69.42e18; // initial price scaled by 1e18.
        percentDecay = 0.31e18; // Price decay percent per Unit time scaled by 1e18.
    }

    function test_calculateExponentialDecay() public {
        uint256 result = calculateExponentialDecay(initialPrice, percentDecay, timeSinceStart);
        console.log(result);
        assertLt(result, uint256(initialPrice), "Price didnt decrease");
    }
}
