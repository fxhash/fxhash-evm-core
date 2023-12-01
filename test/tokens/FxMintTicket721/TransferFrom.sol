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

    function test_ForeclosureInactive() public {
        TicketLib.transferFrom(bob, fxMintTicketProxy, bob, alice, tokenId);
    }

    function test_ForeclosureInactive_TicketContract() public {
        TicketLib.transferFrom(fxMintTicketProxy, fxMintTicketProxy, bob, alice, tokenId);
    }

    function test_ForeclosureInactive_TicketRedeemer() public {
        address ticketRedeemer = IFxMintTicket721(fxMintTicketProxy).redeemer();
        TicketLib.setApprovalForAll(bob, fxMintTicketProxy, ticketRedeemer, true);
        TicketLib.transferFrom(address(ticketRedeemer), fxMintTicketProxy, bob, alice, tokenId);
    }

    function test_When_ForeclosureActive_TicketContract() public {
        vm.warp(foreclosureTime);
        TicketLib.transferFrom(fxMintTicketProxy, fxMintTicketProxy, bob, alice, tokenId);
    }

    function test_RevertsWhen_ForeclosureActive_Owner() public {
        vm.warp(foreclosureTime);
        vm.expectRevert(FORECLOSURE_ERROR);
        TicketLib.transferFrom(bob, fxMintTicketProxy, bob, alice, tokenId);
    }

    function test_RevertsWhen_ForeclosureActive_TicketRedeemer() public {
        address ticketRedeemer = IFxMintTicket721(fxMintTicketProxy).redeemer();
        TicketLib.setApprovalForAll(bob, fxMintTicketProxy, ticketRedeemer, true);
        vm.warp(foreclosureTime);
        vm.expectRevert(FORECLOSURE_ERROR);
        TicketLib.transferFrom(address(ticketRedeemer), fxMintTicketProxy, bob, alice, tokenId);
    }

    function test_RevertsWhen_ForeclosureInactiveAndNotOwner() public {
        TicketLib.setApprovalForAll(bob, fxMintTicketProxy, alice, true);
        vm.expectRevert(NOT_AUTHORIZED_TICKET_ERROR);
        TicketLib.transferFrom(alice, fxMintTicketProxy, bob, alice, tokenId);
    }
}
