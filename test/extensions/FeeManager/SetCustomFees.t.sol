// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/extensions/FeeManager/FeeManagerTest.t.sol";

contract SetCustomFees is FeeManagerTest {
    uint120 internal newPlatformFee;
    uint64 internal newMintPercentage;
    uint64 internal newSplitPercentage;

    function setUp() public virtual override {
        super.setUp();
        newPlatformFee = .01 ether;
        newMintPercentage = 1000;
        newSplitPercentage = 5000;
    }

    function test_SetCustomFees() public {
        (enabled, platformFee, mintPercentage, splitPercentage) = feeManager.customFees(address(this));
        assertEq(enabled, false);
        assertEq(platformFee, 0);
        assertEq(mintPercentage, 0);
        assertEq(splitPercentage, 0);

        vm.prank(admin);
        feeManager.setCustomFees(address(this), true, newPlatformFee, newMintPercentage, newSplitPercentage);
        (enabled, platformFee, mintPercentage, splitPercentage) = feeManager.customFees(address(this));

        assertEq(enabled, true);
        assertEq(platformFee, newPlatformFee);
        assertEq(mintPercentage, newMintPercentage);
        assertEq(splitPercentage, newSplitPercentage);
    }

    function test_RevertsWhen_InvalidMintPercentage() public {
        vm.prank(admin);
        vm.expectRevert(INVALID_PERCENTAGE_ERROR);
        feeManager.setCustomFees(address(this), true, newPlatformFee, uint64(SCALE_FACTOR + 1), newSplitPercentage);
    }

    function test_RevertsWhen_InvalidSplitPercentage() public {
        vm.prank(admin);
        vm.expectRevert(INVALID_PERCENTAGE_ERROR);
        feeManager.setCustomFees(address(this), true, newPlatformFee, newMintPercentage, uint64(SCALE_FACTOR + 1));
    }
}
