// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/DutchAuction/DutchAuctionTest.t.sol";

contract SetMintDetails is DutchAuctionTest {
    AuctionInfo internal daInfo;

    function setUp() public override {
        super.setUp();
        daInfo = AuctionInfo(refund, stepLength, prices);
        vm.warp(RESERVE_START_TIME - 1);
    }

    function test_RevertsWhen_StepLengthAndPricesArrayInvalid() public {
        bool refunded;
        uint248 stepLength = 6;
        uint256 pricesLength = 9940;
        uint64 startTime = 1700221226;
        uint64 endTime = 1700290802;
        vm.warp(0);
        delete prices;
        prices = new uint256[](pricesLength);
        for (uint256 i; i < pricesLength; i++) {
            prices[i] = pricesLength - i;
        }
        daInfo = AuctionInfo(refunded, stepLength, prices);
        vm.expectRevert(INVALID_STEP_ERROR);
        dutchAuction.setMintDetails(
            ReserveInfo(startTime, endTime, MINTER_ALLOCATION),
            abi.encode(daInfo, merkleRoot, signerAddr)
        );
    }

    function test_setMintDetails() public {
        dutchAuction.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(daInfo, merkleRoot, signerAddr)
        );
        vm.warp(RESERVE_START_TIME);
        (uint64 startTime_, uint64 endTime_, uint128 supply_) = dutchAuction.reserves(address(this), 0);
        uint256 price_ = dutchAuction.getPrice(address(this), 0);

        uint256 duration = RESERVE_END_TIME - RESERVE_START_TIME;
        uint256 remainder = duration % daInfo.stepLength;

        assertTrue(remainder == 0, "duration not multiple of stepLength");
        assertEq(price_, daInfo.prices[0], "price incorrectly set");
        assertEq(RESERVE_START_TIME, startTime_, "startTime incorrectly set");
        assertEq(RESERVE_END_TIME, endTime_, "endTime incorrectly set");
        assertEq(MINTER_ALLOCATION, supply_, "supply incorrectly set");
    }

    function test_RevertsIf_Allocation0() public {
        vm.expectRevert(INVALID_ALLOCATION_ERROR);
        dutchAuction.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, 0),
            abi.encode(daInfo, merkleRoot, signerAddr)
        );
    }

    function test_RevertsIf_InvalidStepLength() public {
        daInfo.stepLength = 0;
        vm.expectRevert();
        dutchAuction.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(daInfo, merkleRoot, signerAddr)
        );
    }

    function test_RevertsIf_DurationNotMultipleOfStepLength() public {
        uint256 duration = RESERVE_END_TIME - RESERVE_START_TIME;
        daInfo.stepLength--;
        uint256 remainder = duration % daInfo.stepLength;
        vm.expectRevert(INVALID_STEP_ERROR);
        dutchAuction.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(daInfo, merkleRoot, signerAddr)
        );
        assertTrue(remainder != 0, "duration was not even multiple of stepLength");
    }

    function test_RevertsIf_PricesOutOfOrder() public {
        (daInfo.prices[0], daInfo.prices[1]) = (daInfo.prices[1], daInfo.prices[0]);
        vm.expectRevert(PRICES_OUT_OF_ORDER_ERROR);
        dutchAuction.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(daInfo, merkleRoot, signerAddr)
        );
    }

    function test_RevertsWhen_DeregisteredReserve() public {
        dutchAuction.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(daInfo, merkleRoot, signerAddr)
        );
        dutchAuction.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(daInfo, merkleRoot, signerAddr)
        );
        vm.warp(block.timestamp + 1);

        dutchAuction.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(daInfo, merkleRoot, signerAddr)
        );

        vm.expectRevert(INVALID_RESERVE_ERROR);
        dutchAuction.buy(address(this), 0, 1, address(this), address(this));

        vm.expectRevert(INVALID_RESERVE_ERROR);
        dutchAuction.buy(address(this), 1, 1, address(this), address(this));

        dutchAuction.buy{value: daInfo.prices[0]}(address(this), 2, 1, address(this), address(this));

        vm.expectRevert(INVALID_RESERVE_ERROR);
        dutchAuction.buy(address(this), 3, 1, address(this), address(this));
    }

    function mint(address _to, uint256 _amount, uint256 _payment) external {}
}
