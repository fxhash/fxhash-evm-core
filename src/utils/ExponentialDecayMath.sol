// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {
    wadExp,
    wadLn,
    wadMul,
    unsafeWadMul,
    toDaysWadUnsafe,
    toWadUnsafe
} from "solmate/src/utils/SignedWadMath.sol";

int256 constant WAD = 1e18;
/// @notice Calculates the remaining price after an amount of exponential decay.
/// @dev decayConstant must be non-negative
/// @param initialPrice The starting price.
/// @param perDayPercentDecay The percent price decays per unit of time, scaled by 1e18.
/// @param timeSinceStart Time passed since the initial price began decaying.
/// @return The price remaining after some amount of decay, scaled by 1e18.

function calculateExponentialDecay(
    uint256 initialPrice,
    int256 perDayPercentDecay,
    uint256 timeSinceStart
) pure returns (uint256) {
    int256 decayConstant = wadLn(WAD - perDayPercentDecay);
    int256 wadDays = toDaysWadUnsafe(timeSinceStart);
    int256 wadPrice = toWadUnsafe(initialPrice);
    return uint256(wadMul(wadPrice, wadExp(unsafeWadMul(decayConstant, wadDays))) / WAD);
}
