// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/FxMintTicket721/FxMintTicket721Test.t.sol";

contract Claim is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        _mint(alice, bob, amount, PRICE);
        _deposit(bob, tokenId, DEPOSIT_AMOUNT);
        _setTaxInfo();
    }

    function testClaim_ListingPrice() public {
        vm.warp(gracePeriod + 1);
        _claim(alice, tokenId, newPrice, PRICE + DEPOSIT_AMOUNT);
        _setTaxInfo();
        assertEq(FxMintTicket721(fxMintTicketProxy).ownerOf(tokenId), alice);
        assertEq(foreclosureTime, block.timestamp + (ONE_DAY * 2));
        assertEq(currentPrice, newPrice);
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    function testClaim_AuctionPrice() public {
        vm.warp(foreclosureTime + TEN_MINUTES);
        _setAuctionPrice();
        _claim(alice, tokenId, newPrice, auctionPrice + DEPOSIT_AMOUNT);
        _setTaxInfo();
        assertEq(FxMintTicket721(fxMintTicketProxy).ownerOf(tokenId), alice);
        assertEq(foreclosureTime, block.timestamp + (ONE_DAY * 2));
        assertEq(currentPrice, newPrice);
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    function testClaim_RevertsWhen_GracePeriodActive() public {
        vm.expectRevert(GRACE_PERIOD_ACTIVE_ERROR);
        _claim(alice, tokenId, newPrice, PRICE + DEPOSIT_AMOUNT);
    }

    function testClaim_RevertsWhen_InsufficientPayment() public {
        vm.warp(gracePeriod + 1);
        vm.expectRevert(INSUFFICIENT_PAYMENT_ERROR);
        _claim(alice, tokenId, newPrice, PRICE + (DEPOSIT_AMOUNT / 2) - 1);
    }
}
