// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {wadExp, wadLn, wadMul, unsafeWadMul} from "solmate/src/utils/SignedWadMath.sol";

/// @notice Calculate the price of a token according to a decaying price schedule.
/// @dev decayConstant must be non-negative
/// @param initialPrice The target price for a token, scaled by 1e18.
/// @param perTimeUnitDecay The percent price decays per unit of time, scaled by 1e18.
/// @param timeSinceStart Time passed since the DA began, scaled by 1e18.
/// @return The price of a token according to DA, scaled by 1e18.
function calculateExponentialDecay(
    int256 initialPrice,
    int256 perTimeUnitDecay,
    int256 timeSinceStart
) pure returns (uint256) {
    int256 decayConstant = wadLn(1e18 - perTimeUnitDecay);
    return uint256(wadMul(initialPrice, wadExp(unsafeWadMul(decayConstant, timeSinceStart))));
}
