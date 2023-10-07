// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";

contract SetPrice is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        _mint(alice, bob, amount, PRICE);
        _deposit(bob, tokenId, DEPOSIT_AMOUNT);
        _setTaxInfo();
    }

    function testSetPrice() public {
        _setPrice(bob, tokenId, newPrice);
        _setTaxInfo();
        assertEq(foreclosureTime, block.timestamp + (ONE_DAY * 4));
        assertEq(currentPrice, newPrice);
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    function testSetPrice_RevertsWhen_NotAuthorized() public {
        vm.expectRevert(NOT_AUTHORIZED_TICKET_ERROR);
        _setPrice(alice, tokenId, newPrice);
    }

    function testSetPrice_RevertsWhen_Foreclosure() public {
        vm.warp(foreclosureTime);
        vm.expectRevert(FORECLOSURE_ERROR);
        _setPrice(bob, tokenId, newPrice);
    }

    function testSetPrice_RevertsWhen_InvalidPrice() public {
        vm.expectRevert(INVALID_PRICE_ERROR);
        _setPrice(bob, tokenId, uint80(MINIMUM_PRICE - 1));
    }
}
