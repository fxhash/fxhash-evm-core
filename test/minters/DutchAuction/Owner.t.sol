// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/DutchAuction/DutchAuctionTest.t.sol";

contract DutchAuctionOwnerTest is DutchAuctionTest {
    function setUp() public override {
        super.setUp();
        vm.startPrank(admin);
    }

    function test_pause() public {
        dutchAuction.pause();

        assertTrue(dutchAuction.paused());
    }

    function test_RevertsWhen_NotOwner_pause() public {
        vm.stopPrank();
        vm.expectRevert();
        dutchAuction.pause();

        assertTrue(!dutchAuction.paused());
    }

    function test_unpause() public {
        dutchAuction.pause();

        dutchAuction.unpause();

        assertTrue(!dutchAuction.paused());
    }

    function test_RevertsWhen_NotOwner_unpause() public {
        dutchAuction.pause();

        vm.stopPrank();
        vm.expectRevert();
        dutchAuction.unpause();

        assertTrue(dutchAuction.paused());
    }
}
