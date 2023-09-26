// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/unit/DutchAuction/DutchAuctionTest.t.sol";

contract SetMintDetails is DutchAuctionTest {
    DutchAuction.DAInfo internal daInfo ; 
    function setUp() public override {
        super.setUp();
        daInfo = DutchAuction.DAInfo(prices, stepLength, refund);
        vm.warp(0);
    }

    function test_setMintDetails() public {
        dutchAuction.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, RESERVE_MINTER_ALLOCATION),
            abi.encode(daInfo)
        );
        vm.warp(RESERVE_START_TIME);
        (uint64 startTime_, uint64 endTime_, uint128 supply_) = dutchAuction.reserves(address(this));
        (uint256 step, uint256 price_) = dutchAuction.getPrice(address(this));
        assertEq(price_, daInfo.prices[0], "price incorrectly set");
        assertEq(RESERVE_START_TIME, startTime_, "startTime incorrectly set");
        assertEq(RESERVE_END_TIME, endTime_, "endTime incorrectly set");
        assertEq(RESERVE_MINTER_ALLOCATION, supply_, "supply incorrectly set");
    }

    function test_RevertsIf_StartTimeGtEndTime() public {
        uint64 endTime = RESERVE_START_TIME - 1;
        vm.expectRevert(INVALID_TIMES_ERROR);
        dutchAuction.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, uint64(endTime), RESERVE_MINTER_ALLOCATION),
            abi.encode(daInfo)
        );
    }

    function test_RevertsIf_Allocation0() public {
        vm.expectRevert(INVALID_ALLOCATION_ERROR);
        dutchAuction.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, 0), abi.encode(daInfo)
        );
    }

    function test_RevertsIf_InvalidStepLength() public {
        daInfo.stepLength = 0;
        vm.expectRevert();
        dutchAuction.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, RESERVE_MINTER_ALLOCATION),
            abi.encode(daInfo)
        );
    }

    function test_RevertsIf_PricesOutOfOrder() public {
        (daInfo.prices[0], daInfo.prices[1]) = (daInfo.prices[1], daInfo.prices[0]);
        vm.expectRevert(PRICES_OUT_OF_ORDER_ERROR);
        dutchAuction.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, RESERVE_MINTER_ALLOCATION),
            abi.encode(daInfo)
        );
    }
}
