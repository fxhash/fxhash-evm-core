// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/extensions/FeeManager/FeeManagerTest.t.sol";

contract SetPlatformFee is FeeManagerTest {
    uint128 internal newFee;

    function setUp() public virtual override {
        super.setUp();
        newFee = .01 ether;
    }

    function test_SetPlatformFee() public {
        platformFee = feeManager.getPlatformFee(address(0));
        assertEq(platformFee, PLATFORM_FEE);

        platformFee = feeManager.getPlatformFee(address(this));
        assertEq(platformFee, PLATFORM_FEE);

        vm.prank(admin);
        feeManager.setPlatformFee(address(this), newFee);
        platformFee = feeManager.getPlatformFee(address(this));
        assertEq(platformFee, newFee);

        platformFee = feeManager.getPlatformFee(address(0));
        assertEq(platformFee, PLATFORM_FEE);
    }
}
