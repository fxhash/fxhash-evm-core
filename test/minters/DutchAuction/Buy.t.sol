// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/minters/DutchAuction/DutchAuctionTest.t.sol";

contract Buy is DutchAuctionTest {
    function setUp() public virtual override {
        super.setUp();
        price = dutchAuction.getPrice(fxGenArtProxy, reserveId);
    }

    function test_Buy() public {
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 1);
    }

    function test_RevertsWhen_InvalidPayment() public {
        vm.expectRevert(INVALID_PAYMENT_ERROR);
        dutchAuction.buy{value: price - 1}(fxGenArtProxy, reserveId, quantity, alice);
    }

    function test_RevertsWhen_NotStarted() public {
        vm.warp(RESERVE_START_TIME - 1);
        vm.expectRevert(NOT_STARTED_ERROR);
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
    }

    function test_RevertsWhen_Ended() public {
        vm.warp(uint256(RESERVE_END_TIME) + 1);
        vm.expectRevert(ENDED_ERROR);
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
    }

    function test_RevertsWhen_InvalidToken() public {
        vm.expectRevert(INVALID_TOKEN_ERROR);
        dutchAuction.buy{value: price}(address(0), reserveId, 1, alice);
    }

    function test_RevertsWhen_AddressZero() public {
        vm.expectRevert(ADDRESS_ZERO_ERROR);
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, address(0));
    }

    function test_RevertsWhen_InvalidAmount() public {
        quantity = 0;
        vm.expectRevert(INVALID_AMOUNT_ERROR);
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
    }

    function test_RevertsWhen_SoldOut() public {
        quantity = 1;
        dutchAuction.buy{value: price * MINTER_ALLOCATION}(fxGenArtProxy, reserveId, MINTER_ALLOCATION, alice);
        vm.expectRevert(INVALID_AMOUNT_ERROR);
        dutchAuction.buy{value: price * quantity}(fxGenArtProxy, reserveId, quantity, alice);
    }
}
