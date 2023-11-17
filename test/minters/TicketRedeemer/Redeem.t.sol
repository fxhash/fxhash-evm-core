// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/minters/TicketRedeemer/TicketRedeemerTest.t.sol";

contract Redeem is TicketRedeemerTest {
    function setUp() public override {
        super.setUp();
        vm.prank(minter);
        ticketRedeemer.setMintDetails(reserveInfo, mintDetails);
    }

    function test_Redeem() public {
        ticketRedeemer.redeem(address(ticket), tokenId, fxParams);
    }

    function test_RevertsWhen_NotAuthorized() public {
        vm.prank(alice);
        vm.expectRevert(NOT_AUTHORIZED_ERROR);
        ticketRedeemer.redeem(address(ticket), tokenId, fxParams);
    }

    function test_RevertsWhen_InvalidToken() public {
        ticket = new MockTicket();
        vm.expectRevert(INVALID_TOKEN_ERROR);
        ticketRedeemer.redeem(address(ticket), tokenId, fxParams);
    }
}
