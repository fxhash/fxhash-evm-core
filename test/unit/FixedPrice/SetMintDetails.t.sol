// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FixedPrice/FixedPriceTest.t.sol";

contract SetMintDetails is FixedPriceTest {
    function test_setMintDetails() public {
        fixedPrice.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(price)
        );
        (startTime, endTime, supply) = fixedPrice.reserves(address(this), 0);
        assertEq(fixedPrice.prices(address(this), 0), price, "price incorrectly set");
        assertEq(RESERVE_START_TIME, startTime, "startTime incorrectly set");
        assertEq(RESERVE_END_TIME, endTime, "endTime incorrectly set");
        assertEq(MINTER_ALLOCATION, supply, "supply incorrectly set");
    }

    function test_RevertsIf_StartTimeGtEndTime() public {
        endTime = RESERVE_START_TIME - 1;
        vm.expectRevert(INVALID_TIMES_ERROR);
        fixedPrice.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, uint64(endTime), MINTER_ALLOCATION),
            abi.encode(price)
        );
    }

    function test_RevertsIf_Allocation0() public {
        vm.expectRevert(INVALID_ALLOCATION_ERROR);
        fixedPrice.setMintDetails(ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, 0), abi.encode(price));
    }

    function test_RevertsIf_Price0() public {
        vm.expectRevert(INVALID_PRICE_ERROR);
        fixedPrice.setMintDetails(ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION), abi.encode(0));
    }
}
