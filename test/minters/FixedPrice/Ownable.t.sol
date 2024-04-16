// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FixedPrice/FixedPriceTest.t.sol";

contract Ownable is FixedPriceTest {
    function test_Pause() public {
        vm.prank(admin);
        fixedPrice.pause();
        assertTrue(fixedPrice.paused());
    }

    function test_RevertsWhen_NotOwner_Pause() public {
        vm.expectRevert();
        fixedPrice.pause();
        assertFalse(fixedPrice.paused());
    }

    function test_Unpause() public {
        vm.startPrank(admin);
        fixedPrice.pause();
        fixedPrice.unpause();
        vm.stopPrank();
        assertFalse(fixedPrice.paused());
    }

    function test_RevertsWhen_NotOwner_Unpause() public {
        vm.prank(admin);
        fixedPrice.pause();
        vm.expectRevert();
        fixedPrice.unpause();
        assertTrue(fixedPrice.paused());
    }
}
