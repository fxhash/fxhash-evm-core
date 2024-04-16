// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FixedPrice/FixedPriceTest.t.sol";

contract FixedPriceOwnerTest is FixedPriceTest {
    function setUp() public override {
        super.setUp();
        vm.startPrank(admin);
    }

    function test_pause() public {
        fixedPrice.pause();

        assertTrue(fixedPrice.paused());
    }

    function test_RevertsWhen_NotOwner_pause() public {
        vm.stopPrank();
        vm.expectRevert();
        fixedPrice.pause();

        assertTrue(!fixedPrice.paused());
    }

    function test_unpause() public {
        fixedPrice.pause();

        fixedPrice.unpause();

        assertTrue(!fixedPrice.paused());
    }

    function test_RevertsWhen_NotOwner_unpause() public {
        fixedPrice.pause();

        vm.stopPrank();
        vm.expectRevert();
        fixedPrice.unpause();

        assertTrue(fixedPrice.paused());
    }
}
