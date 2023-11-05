// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/minters/TicketRedeemer/TicketRedeemerTest.t.sol";

contract Redeem is TicketRedeemerTest {
    function setUp() public override {
        super.setUp();
        vm.prank(address(token));
        ticketRedeemer.setMintDetails(reserveInfo, abi.encode(address(ticket)));
    }

    function test_Redeem() public {
        ticketRedeemer.redeem(address(ticket), 0, "");
    }

    function test_RevertsWhen_NotOwner() public {
        vm.prank(address(420));
        vm.expectRevert(abi.encodeWithSelector(ITicketRedeemer.NotAuthorized.selector));
        ticketRedeemer.redeem(address(ticket), 0, "");
    }

    function test_RevertsWhen_TicketNotRegistered() public {
        // create a new ticket but don't register it
        ticket = new MockTicket();
        vm.expectRevert(abi.encodeWithSelector(ITicketRedeemer.InvalidToken.selector));
        ticketRedeemer.redeem(address(ticket), 0, "");
    }
}
