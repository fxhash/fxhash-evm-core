// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/unit/FixedPrice/FixedPrice.t.sol";

contract SetMintDetails is FixedPriceTest {
    function test_setMintDetails() public {
        sale.setMintDetails(ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, RESERVE_MINTER_ALLOCATION), abi.encode(price));
        assertEq(sale.prices(address(this), 0), price, "price incorrectly set");
        (uint64 startTime_, uint64 endTime_, uint160 supply_) = sale.reserves(address(this), 0);
        assertEq(sale.prices(address(this), 0), price, "price incorrectly set");
        assertEq(RESERVE_START_TIME, startTime_, "startTime incorrectly set");
        assertEq(RESERVE_END_TIME, endTime_, "endTime incorrectly set");
        assertEq(RESERVE_MINTER_ALLOCATION, supply_, "supply incorrectly set");
    }

    function test_RevertsIf_StartTimeGtEndTime() public {
        uint64 endTime = RESERVE_START_TIME - 1;
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.InvalidTimes.selector));
        sale.setMintDetails(ReserveInfo(RESERVE_START_TIME, uint64(endTime), RESERVE_MINTER_ALLOCATION), abi.encode(price));
    }

    function test_RevertsIf_Allocation0() public {
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.InvalidAllocation.selector));
        sale.setMintDetails(ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, 0), abi.encode(price));
    }

    function test_RevertsIf_Price0() public {
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.InvalidPrice.selector));
        sale.setMintDetails(ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, RESERVE_MINTER_ALLOCATION), abi.encode(0));
    }
}
