// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FarcasterFrame/FarcasterFrameTest.t.sol";

import {Ownable} from "solady/src/auth/Ownable.sol";

contract FrameOwnerTest is FarcasterFrameTest {
    address internal newAdmin;

    function setUp() public override {
        newAdmin = address(20);
        super.setUp();
        vm.startPrank(admin);
    }

    function test_pause() public {
        farcasterFrame.pause();

        assertTrue(farcasterFrame.paused());
    }

    function test_RevertsWhen_NotOwner_pause() public {
        vm.stopPrank();
        vm.expectRevert();
        farcasterFrame.pause();

        assertTrue(!farcasterFrame.paused());
    }

    function test_unpause() public {
        farcasterFrame.pause();

        farcasterFrame.unpause();

        assertTrue(!farcasterFrame.paused());
    }

    function test_RevertsWhen_NotOwner_unpause() public {
        farcasterFrame.pause();

        vm.stopPrank();
        vm.expectRevert();
        farcasterFrame.unpause();

        assertTrue(farcasterFrame.paused());
    }

    function test_setAdmin() public {
        farcasterFrame.setAdmin(newAdmin);
        assertEq(farcasterFrame.admin(), newAdmin);
    }

    function test_RevertsWhen_notOwner_setAdmin() public {
        vm.stopPrank();
        vm.expectRevert();
        farcasterFrame.setAdmin(newAdmin);
    }
}
