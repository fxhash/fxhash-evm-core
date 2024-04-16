// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/TicketRedeemer/TicketRedeemerTest.t.sol";

contract TicketRedeemerOwnerTest is TicketRedeemerTest {
    function setUp() public override {
        super.setUp();
        vm.startPrank(admin);
    }

    function test_pause() public {
        ticketRedeemer.pause();

        assertTrue(ticketRedeemer.paused());
    }

    function test_RevertsWhen_NotOwner_pause() public {
        vm.stopPrank();
        vm.expectRevert();
        ticketRedeemer.pause();

        assertTrue(!ticketRedeemer.paused());
    }

    function test_unpause() public {
        ticketRedeemer.pause();

        ticketRedeemer.unpause();

        assertTrue(!ticketRedeemer.paused());
    }

    function test_RevertsWhen_NotOwner_unpause() public {
        ticketRedeemer.pause();

        vm.stopPrank();
        vm.expectRevert();
        ticketRedeemer.unpause();

        assertTrue(ticketRedeemer.paused());
    }
}
