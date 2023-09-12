// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ONE_WAD} from "src/utils/Constants.sol";
import {
    toDaysWadUnsafe,
    toWadUnsafe,
    unsafeWadMul,
    wadExp,
    wadLn,
    wadMul
} from "solmate/src/utils/SignedWadMath.sol";

function fromWad(int256 _wadValue) pure returns (uint256) {
    return uint256(_wadValue / ONE_WAD);
}

/**
 * @notice Calculates the remaining amount based on a rate of exponential decay and duration
 * @dev Price decay constant must be non-negative
 * @param _startingPrice The starting price
 * @param _timeElapsed Time passed since the initial price began decaying
 * @param _wadDecayRate The percent price decays per unit of time (1 day), scaled by 1e18
 * @return The price remaining at the amount of time elapsed
 */
function calculateExponentialDecay(
    uint256 _startingPrice,
    uint256 _timeElapsed,
    int256 _wadDecayRate
) pure returns (uint256) {
    int256 wadDecayConstant = wadLn(ONE_WAD - _wadDecayRate);
    int256 wadDaysElapsed = toDaysWadUnsafe(_timeElapsed);
    int256 wadStartingPrice = toWadUnsafe(_startingPrice);
    return fromWad(wadMul(wadStartingPrice, wadExp(unsafeWadMul(wadDecayConstant, wadDaysElapsed))));
}
