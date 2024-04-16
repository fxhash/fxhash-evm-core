// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FixedPriceParams/FixedPriceParamsTest.t.sol";

contract Ownable is FixedPriceParamsTest {
    function test_Pause() public {
        vm.prank(admin);
        fixedPriceParams.pause();
        assertTrue(fixedPriceParams.paused());
    }

    function test_RevertsWhen_NotOwner_Pause() public {
        vm.expectRevert();
        fixedPriceParams.pause();
        assertFalse(fixedPriceParams.paused());
    }

    function test_Unpause() public {
        vm.startPrank(admin);
        fixedPriceParams.pause();
        fixedPriceParams.unpause();
        vm.stopPrank();
        assertFalse(fixedPriceParams.paused());
    }

    function test_RevertsWhen_NotOwner_Unpause() public {
        vm.prank(admin);
        fixedPriceParams.pause();
        vm.expectRevert();
        fixedPriceParams.unpause();
        assertTrue(fixedPriceParams.paused());
    }
}
