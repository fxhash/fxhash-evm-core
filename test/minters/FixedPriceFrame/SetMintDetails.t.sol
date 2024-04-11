// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FixedPriceFrame/FixedPriceFrameTest.t.sol";

contract SetMintDetails is FixedPriceFrameTest {
    function test_SetMintDetails() public {
        fixedPriceFrame.setMintDetails(reserveInfo, mintDetails);
        (startTime, endTime, allocation) = fixedPriceFrame.reserves(address(token), 0);

        assertEq(RESERVE_START_TIME, startTime);
        assertEq(RESERVE_END_TIME, endTime);
        assertEq(MINTER_ALLOCATION, allocation);
    }
}
