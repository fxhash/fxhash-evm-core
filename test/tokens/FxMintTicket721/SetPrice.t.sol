// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";

contract SetPrice is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, PRICE);
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, DEPOSIT_AMOUNT);
        _setTaxInfo();
    }

    function test_SetPrice() public {
        TicketLib.setPrice(bob, fxMintTicketProxy, tokenId, newPrice);
        _setTaxInfo();
        assertEq(foreclosureTime, block.timestamp + (ONE_DAY * 4));
        assertEq(currentPrice, newPrice);
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    function test_RevertsWhen_NotAuthorized() public {
        vm.expectRevert(NOT_AUTHORIZED_TICKET_ERROR);
        TicketLib.setPrice(alice, fxMintTicketProxy, tokenId, newPrice);
    }

    function test_RevertsWhen_Foreclosure() public {
        vm.warp(foreclosureTime);
        vm.expectRevert(FORECLOSURE_ERROR);
        TicketLib.setPrice(bob, fxMintTicketProxy, tokenId, newPrice);
    }

    function test_RevertsWhen_InvalidPrice() public {
        vm.expectRevert(INVALID_PRICE_ERROR);
        TicketLib.setPrice(bob, fxMintTicketProxy, tokenId, uint80(MINIMUM_PRICE - 1));
    }
}
