// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FarcasterFrame/FarcasterFrameTest.t.sol";

contract SetMintDetails is FarcasterFrameTest {
    function test_SetMintDetails1() public {
        farcasterFrame.setMintDetails(reserveInfo, mintDetails);
        (startTime, endTime, allocation) = farcasterFrame.reserves(fxGenArtProxy, reserveId);

        assertEq(startTime, RESERVE_START_TIME);
        assertEq(endTime, RESERVE_END_TIME);
        assertEq(allocation, MINTER_ALLOCATION);
        assertEq(farcasterFrame.prices(fxGenArtProxy, reserveId), PRICE);
        assertEq(farcasterFrame.maxAmounts(fxGenArtProxy), maxAmount);
    }

    function test_RevertsWhen_InvalidAllocation() public {
        vm.expectRevert(INVALID_ALLOCATION_ERROR);
        farcasterFrame.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, 0),
            abi.encode(PRICE, maxAmount)
        );
    }
}
