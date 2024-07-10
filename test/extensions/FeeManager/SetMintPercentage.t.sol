// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/extensions/FeeManager/FeeManagerTest.t.sol";

contract SetMintPercentage is FeeManagerTest {
    uint64 internal newPercentage;

    function setUp() public virtual override {
        super.setUp();
        newPercentage = 100;
    }

    function test_SetMintPercentage() public {
        mintPercentage = feeManager.getMintPercentage(address(0));
        assertEq(mintPercentage, MINT_PERCENTAGE);

        mintPercentage = feeManager.getMintPercentage(address(this));
        assertEq(mintPercentage, MINT_PERCENTAGE);

        vm.startPrank(admin);
        feeManager.setCustomFees(address(this), true);
        feeManager.setMintPercentage(address(this), newPercentage);
        vm.stopPrank();
        mintPercentage = feeManager.getMintPercentage(address(this));
        assertEq(mintPercentage, newPercentage);

        mintPercentage = feeManager.getMintPercentage(address(0));
        assertEq(mintPercentage, MINT_PERCENTAGE);
    }

    function test_RevertsWhen_InvalidPercentage() public {
        vm.prank(admin);
        vm.expectRevert(INVALID_PERCENTAGE_ERROR);
        feeManager.setMintPercentage(address(this), uint64(SCALE_FACTOR + 1));
    }
}
