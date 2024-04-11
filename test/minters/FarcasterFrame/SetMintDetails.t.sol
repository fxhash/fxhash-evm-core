// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FarcasterFrame/FarcasterFrameTest.t.sol";

contract SetMintDetails is FarcasterFrameTest {
    function test_SetMintDetails() public {
        maxAmount = 1;
        reserveInfo = ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION);
        mintDetails = abi.encode(PRICE, maxAmount);

        farcasterFrame.setMintDetails(reserveInfo, mintDetails);
        (startTime, endTime, allocation) = farcasterFrame.reserves(address(this), 0);

        assertEq(RESERVE_START_TIME, startTime);
        assertEq(RESERVE_END_TIME, endTime);
        assertEq(MINTER_ALLOCATION, allocation);
    }
}
