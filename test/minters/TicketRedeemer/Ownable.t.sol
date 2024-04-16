// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/TicketRedeemer/TicketRedeemerTest.t.sol";

contract Ownable is TicketRedeemerTest {
    function test_Pause() public {
        vm.prank(admin);
        ticketRedeemer.pause();
        assertTrue(ticketRedeemer.paused());
    }

    function test_RevertsWhen_NotOwner_Pause() public {
        vm.expectRevert();
        ticketRedeemer.pause();
        assertFalse(ticketRedeemer.paused());
    }

    function test_Unpause() public {
        vm.startPrank(admin);
        ticketRedeemer.pause();
        ticketRedeemer.unpause();
        vm.stopPrank();
        assertFalse(ticketRedeemer.paused());
    }

    function test_RevertsWhen_NotOwner_Unpause() public {
        vm.prank(admin);
        ticketRedeemer.pause();
        vm.expectRevert();
        ticketRedeemer.unpause();
        assertTrue(ticketRedeemer.paused());
    }
}
