// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/extensions/FeeManager/FeeManagerTest.t.sol";

contract SetDefaultFees is FeeManagerTest {
    uint120 internal newPlatformFee;
    uint64 internal newMintPercentage;
    uint64 internal newSplitPercentage;

    function setUp() public virtual override {
        super.setUp();
        newPlatformFee = .01 ether;
        newMintPercentage = 1000;
        newSplitPercentage = 5000;
    }

    function test_SetDefaultFees() public {
        (platformFee, mintPercentage, splitPercentage) = feeManager.getFees(address(this));
        assertEq(platformFee, PLATFORM_FEE);
        assertEq(mintPercentage, MINT_PERCENTAGE);
        assertEq(splitPercentage, SPLIT_PERCENTAGE);

        vm.prank(admin);
        feeManager.setDefaultFees(newPlatformFee, newMintPercentage, newSplitPercentage);
        (platformFee, mintPercentage, splitPercentage) = feeManager.getFees(address(this));

        assertEq(platformFee, newPlatformFee);
        assertEq(mintPercentage, newMintPercentage);
        assertEq(splitPercentage, newSplitPercentage);
    }

    function test_RevertsWhen_InvalidMintPercentage() public {
        vm.prank(admin);
        vm.expectRevert(INVALID_PERCENTAGE_ERROR);
        feeManager.setDefaultFees(newPlatformFee, uint64(SCALE_FACTOR + 1), newSplitPercentage);
    }

    function test_RevertsWhen_InvalidSplitPercentage() public {
        vm.prank(admin);
        vm.expectRevert(INVALID_PERCENTAGE_ERROR);
        feeManager.setDefaultFees(newPlatformFee, newMintPercentage, uint64(SCALE_FACTOR + 1));
    }
}
