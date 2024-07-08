// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/extensions/FeeManager/FeeManagerTest.t.sol";

contract SetSplitPercentage is FeeManagerTest {
    uint64 internal newPercentage;

    function setUp() public virtual override {
        super.setUp();
        newPercentage = 100;
    }

    function test_SetSplitPercentage() public {
        splitPercentage = feeManager.getSplitPercentage(address(0));
        assertEq(splitPercentage, SPLIT_PERCENTAGE);

        splitPercentage = feeManager.getSplitPercentage(address(this));
        assertEq(splitPercentage, SPLIT_PERCENTAGE);

        vm.prank(admin);
        feeManager.setSplitPercentage(address(this), newPercentage);
        splitPercentage = feeManager.getSplitPercentage(address(this));
        assertEq(splitPercentage, newPercentage);

        splitPercentage = feeManager.getSplitPercentage(address(0));
        assertEq(splitPercentage, SPLIT_PERCENTAGE);
    }

    function test_RevertsWhen_InvalidPercentage() public {
        vm.prank(admin);
        vm.expectRevert(INVALID_PERCENTAGE_ERROR);
        feeManager.setSplitPercentage(address(this), uint64(SCALE_FACTOR + 1));
    }
}
