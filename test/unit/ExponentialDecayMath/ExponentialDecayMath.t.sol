// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "test/BaseTest.t.sol";
import {calculateExponentialDecay} from "src/utils/ExponentialDecayMath.sol";
import {
    fromDaysWadUnsafe, toDaysWadUnsafe, toWadUnsafe
} from "solmate/src/utils/SignedWadMath.sol";

contract ExponentialDecayMathTest is BaseTest {
    int256 internal percentDecay;
    uint256 internal initialPrice;
    uint256 internal timeSinceStart;

    function setUp() public virtual override {
        super.setUp();
    }
}
