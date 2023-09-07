// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/unit/FixedPrice/FixedPrice.t.sol";

contract SetMintDetails is FixedPriceTest {
    function test_setMintDetails() public {
        uint256 price = 10;
        uint128 allocation = 100;
        uint64 start = uint64(block.timestamp + 10);
        uint64 end = type(uint64).max;
        sale.setMintDetails(ReserveInfo(start, end, allocation), abi.encode(price));
        assertEq(sale.prices(address(this), 0), price, "price incorrectly set");
        (uint64 startTime, uint64 endTime, uint160 allocation_) = sale.reserves(address(this), 0);
        assertEq(sale.prices(address(this), 0), price, "price incorrectly set");
        assertEq(startTime, start, "startTime incorrectly set");
        assertEq(endTime, end, "endTime incorrectly set");
        assertEq(allocation_, allocation, "allocation incorrectly set");
    }

    function test_RevertsIf_StartTimeGtEndTime() public {
        endTime = startTime - 1;
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.InvalidTimes.selector));
        sale.setMintDetails(ReserveInfo(startTime, endTime, supply), abi.encode(price));
    }

    function test_RevertsIf_Allocation0() public {
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.InvalidAllocation.selector));
        sale.setMintDetails(ReserveInfo(startTime, endTime, 0), abi.encode(price));
    }

    function test_RevertsIf_Price0() public {
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.InvalidPrice.selector));
        sale.setMintDetails(ReserveInfo(startTime, endTime, supply), abi.encode(0));
    }
}
