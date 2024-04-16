// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FarcasterFrame/FarcasterFrameTest.t.sol";

contract Ownable is FarcasterFrameTest {
    function test_Pause() public {
        vm.prank(admin);
        farcasterFrame.pause();
        assertTrue(farcasterFrame.paused());
    }

    function test_RevertsWhen_NotOwner_Pause() public {
        vm.expectRevert();
        farcasterFrame.pause();
        assertFalse(farcasterFrame.paused());
    }

    function test_Unpause() public {
        vm.startPrank(admin);
        farcasterFrame.pause();
        farcasterFrame.unpause();
        vm.stopPrank();
        assertFalse(farcasterFrame.paused());
    }

    function test_RevertsWhen_NotOwner_Unpause() public {
        vm.prank(admin);
        farcasterFrame.pause();
        vm.expectRevert();
        farcasterFrame.unpause();
        assertTrue(farcasterFrame.paused());
    }

    function test_SetController() public {
        vm.prank(admin);
        farcasterFrame.setController(alice);
        assertEq(farcasterFrame.controller(), alice);
    }

    function test_RevertsWhen_NotOwner_SetController() public {
        vm.expectRevert();
        farcasterFrame.setController(alice);
    }
}
