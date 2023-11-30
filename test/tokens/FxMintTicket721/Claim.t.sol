// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";

contract Claim is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, PRICE);
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, DEPOSIT_AMOUNT);
        _setTaxInfo();
    }

    function test_Claim_ListingPrice() public {
        vm.warp(taxationStartTime + 1);
        TicketLib.claim(alice, fxMintTicketProxy, tokenId, PRICE, newPrice, PRICE + DEPOSIT_AMOUNT);
        _setTaxInfo();
        assertEq(FxMintTicket721(fxMintTicketProxy).ownerOf(tokenId), alice);
        assertEq(foreclosureTime, block.timestamp + (ONE_DAY * 2));
        assertEq(currentPrice, newPrice);
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    function test_Claim_AuctionPrice() public {
        vm.warp(foreclosureTime + TEN_MINUTES);
        _setAuctionPrice();
        TicketLib.claim(alice, fxMintTicketProxy, tokenId, PRICE, newPrice, auctionPrice + DEPOSIT_AMOUNT);
        _setTaxInfo();
        assertEq(FxMintTicket721(fxMintTicketProxy).ownerOf(tokenId), alice);
        assertEq(foreclosureTime, block.timestamp + (ONE_DAY * 2));
        assertEq(currentPrice, newPrice);
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    function test_RevertsWhen_GracePeriodActive() public {
        vm.expectRevert(GRACE_PERIOD_ACTIVE_ERROR);
        TicketLib.claim(alice, fxMintTicketProxy, tokenId, PRICE, newPrice, PRICE + DEPOSIT_AMOUNT);
    }

    function test_RevertsWhen_PriceExceeded() public {
        vm.warp(taxationStartTime + 1);
        vm.expectRevert(PRICE_EXCEEDED_ERROR);
        TicketLib.claim(alice, fxMintTicketProxy, tokenId, PRICE - 1, newPrice, PRICE + DEPOSIT_AMOUNT);
    }

    function test_RevertsWhen_InvalidPrice() public {
        vm.warp(taxationStartTime + 1);
        vm.expectRevert(INVALID_PRICE_ERROR);
        TicketLib.claim(alice, fxMintTicketProxy, tokenId, PRICE, uint80(MINIMUM_PRICE - 1), PRICE + DEPOSIT_AMOUNT);
    }

    function test_RevertsWhen_InsufficientPayment() public {
        vm.warp(taxationStartTime + 1);
        vm.expectRevert(INSUFFICIENT_PAYMENT_ERROR);
        TicketLib.claim(alice, fxMintTicketProxy, tokenId, PRICE, newPrice, PRICE + (DEPOSIT_AMOUNT / 2) - 1);
    }
}
