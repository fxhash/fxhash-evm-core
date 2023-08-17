// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {wadExp, wadLn, wadMul, unsafeWadMul} from "solmate/src/utils/SignedWadMath.sol";

/// @notice Calculates the remaining price after an amount of exponential decay.
/// @dev decayConstant must be non-negative
/// @param initialPrice The starting price, scaled by 1e18.
/// @param perTimeUnitDecay The percent price decays per unit of time, scaled by 1e18.
/// @param timeSinceStart Time passed since the initial price began decaying, scaled by 1e18.
/// @return The price remaining after some amount of decay, scaled by 1e18.
function calculateExponentialDecay(
    int256 initialPrice,
    int256 perTimeUnitDecay,
    int256 timeSinceStart
) pure returns (uint256) {
    int256 decayConstant = wadLn(1e18 - perTimeUnitDecay);
    return uint256(wadMul(initialPrice, wadExp(unsafeWadMul(decayConstant, timeSinceStart))));
}
