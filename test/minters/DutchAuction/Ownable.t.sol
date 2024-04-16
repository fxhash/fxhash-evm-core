// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/DutchAuction/DutchAuctionTest.t.sol";

contract Ownable is DutchAuctionTest {
    function test_Pause() public {
        vm.prank(admin);
        dutchAuction.pause();
        assertTrue(dutchAuction.paused());
    }

    function test_RevertsWhen_NotOwner_Pause() public {
        vm.expectRevert();
        dutchAuction.pause();
        assertFalse(dutchAuction.paused());
    }

    function test_Unpause() public {
        vm.startPrank(admin);
        dutchAuction.pause();
        dutchAuction.unpause();
        vm.stopPrank();
        assertFalse(dutchAuction.paused());
    }

    function test_RevertsWhen_NotOwner_Unpause() public {
        vm.prank(admin);
        dutchAuction.pause();
        vm.expectRevert();
        dutchAuction.unpause();
        assertTrue(dutchAuction.paused());
    }
}
