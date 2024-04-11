// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FixedPriceFrame/FixedPriceFrameTest.t.sol";

contract SetMintDetails is FixedPriceFrameTest {
    function test_SetMintDetails() public {
        maxAmount = 1;
        reserveInfo = ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION);
        mintDetails = abi.encode(PRICE, maxAmount);

        fixedPriceFrame.setMintDetails(reserveInfo, mintDetails);
        (startTime, endTime, allocation) = fixedPriceFrame.reserves(address(this), 0);

        assertEq(RESERVE_START_TIME, startTime);
        assertEq(RESERVE_END_TIME, endTime);
        assertEq(MINTER_ALLOCATION, allocation);
    }
}
