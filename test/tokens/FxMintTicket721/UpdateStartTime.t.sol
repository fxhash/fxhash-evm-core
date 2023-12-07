// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";

contract UpdateStartTime is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, PRICE);
        _setTaxInfo();
    }

    function test_UpdateStartTime() public {
        TicketLib.updateStartTime(bob, fxMintTicketProxy, tokenId);
        _setTaxInfo();
        assertEq(taxationStartTime, block.timestamp);
        assertEq(foreclosureTime, block.timestamp + ONE_DAY);
        assertEq(currentPrice, PRICE);
        assertEq(depositAmount, 0);
    }

    function test_DepositAndSetPrice_ThenUpdateStartTime() public {
        newPrice = uint80(PRICE * 2);
        depositAmount = uint80(DEPOSIT_AMOUNT * 2);
        TicketLib.depositAndSetPrice(bob, fxMintTicketProxy, tokenId, newPrice, depositAmount);
        TicketLib.updateStartTime(bob, fxMintTicketProxy, tokenId);
        _setTaxInfo();
        assertEq(taxationStartTime, block.timestamp);
        assertEq(foreclosureTime, block.timestamp + (ONE_DAY * 2));
        assertEq(currentPrice, newPrice);
        assertEq(depositAmount, depositAmount);
    }

    function test_RevertsWhen_InvalidOwner() public {
        vm.expectRevert(NOT_AUTHORIZED_ERROR);
        TicketLib.updateStartTime(alice, fxMintTicketProxy, tokenId);
    }

    function test_RevertsWhen_GracePeriodInactive() public {
        vm.warp(taxationStartTime + 1);
        vm.expectRevert(GRACE_PERIOD_INACTIVE_ERROR);
        TicketLib.updateStartTime(bob, fxMintTicketProxy, tokenId);
    }

    function test_RevertsWhen_InsufficientDeposit() public {
        vm.warp(block.timestamp + 1);
        vm.expectRevert(INSUFFICIENT_DEPOSIT_ERROR);
        TicketLib.updateStartTime(bob, fxMintTicketProxy, tokenId);
    }
}
