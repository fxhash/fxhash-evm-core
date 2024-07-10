// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/extensions/FeeManager/FeeManagerTest.t.sol";

contract SetPlatformFee is FeeManagerTest {
    uint128 internal newFee;

    function setUp() public virtual override {
        super.setUp();
        newFee = .01 ether;
    }

    function test_SetCustomFees() public {
        platformFee = feeManager.getPlatformFee(address(this));
        assertEq(platformFee, PLATFORM_FEE);

        vm.startPrank(admin);
        feeManager.setCustomFees(address(this), true);
        feeManager.setPlatformFee(address(this), newFee);
        vm.stopPrank();

        customFee = feeManager.customFees(address(this));
        platformFee = feeManager.getPlatformFee(address(this));
        mintPercentage = feeManager.getMintPercentage(address(this));
        splitPercentage = feeManager.getSplitPercentage(address(this));

        assertEq(customFee, true);
        assertEq(platformFee, newFee);
        assertEq(mintPercentage, 0);
        assertEq(splitPercentage, 0);
    }
}
