// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/ExponentialDecayMath/ExponentialDecayMathTest.t.sol";

contract CalculateExponentialDecay is ExponentialDecayMathTest {
    function setUp() public override {
        initialPrice = INITIAL_PRICE;
        timeSinceStart = TIME_SINCE_START;
        percentDecay = PRICE_DECAY;
    }

    function test_calculateExponentialDecay() public {
        uint256 result = calculateExponentialDecay(INITIAL_PRICE, TIME_SINCE_START, PRICE_DECAY);
        assertLt(result, uint256(initialPrice - initialPrice / 100), "Price didnt decrease");
    }
}
