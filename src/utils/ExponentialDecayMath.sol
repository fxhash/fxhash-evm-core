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

/// @dev Base unit for doing wad math
int256 constant ONE_WAD = 1e18;

/**
 * @notice Calculates the remaining amount based on a rate of exponential decay and duration.
 * @dev decayConstant must be non-negative
 * @param startingPrice The starting price.
 * @param timeElapsed Time passed since the initial price began decaying.
 * @param wadDecayRate The percent price decays per unit of time (1 day), scaled by 1e18.
 * @return The price remaining at the amount of time elapsed.
 */
function calculateExponentialDecay(uint256 startingPrice, uint256 timeElapsed, int256 wadDecayRate)
    pure
    returns (uint256)
{
    int256 wadDecayConstant = wadLn(ONE_WAD - wadDecayRate);
    int256 wadDays = toDaysWadUnsafe(timeElapsed);
    int256 wadPrice = toWadUnsafe(startingPrice);
    return uint256(wadMul(wadPrice, wadExp(unsafeWadMul(wadDecayConstant, wadDays))) / ONE_WAD);
}
