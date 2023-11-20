// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";

contract TransferFrom is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, PRICE);
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, DEPOSIT_AMOUNT);
        _setTaxInfo();
    }

    function test_RevertsWhen_ForeclosureActive() public {
        vm.warp(foreclosureTime);
        vm.expectRevert(FORECLOSURE_ERROR);
        TicketLib.transferFrom(bob, fxMintTicketProxy, bob, alice, tokenId);
    }

    function test_RevertsWhen_ForeclosureInactive() public {
        TicketLib.setApprovalForAll(bob, fxMintTicketProxy, alice, true);
        vm.expectRevert(NOT_AUTHORIZED_TICKET_ERROR);
        TicketLib.transferFrom(alice, fxMintTicketProxy, bob, alice, tokenId);
    }
}
