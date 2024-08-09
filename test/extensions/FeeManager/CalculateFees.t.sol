// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/extensions/FeeManager/FeeManagerTest.t.sol";

contract CalculateFees is FeeManagerTest {
    uint64 internal percentage;
    uint256 internal platform;
    uint256 internal mintFee;
    uint256 internal splitAmount;

    function setUp() public virtual override {
        super.setUp();
        price = 1 ether;
        amount = 10;
        percentage = 5000;
    }

    function test_CalculateFees() public {
        (platform, mintFee, splitAmount) = feeManager.calculateFees(address(this), price, amount);
        assertEq(platform, .005 ether);
        assertEq(mintFee, .05 ether);
        assertEq(splitAmount, 0);

        vm.prank(admin);
        feeManager.setDefaultFees(PLATFORM_FEE, MINT_PERCENTAGE, percentage);
        (platform, mintFee, splitAmount) = feeManager.calculateFees(address(this), price, amount);
        assertEq(platform, .005 ether);
        assertEq(mintFee, .05 ether);
        assertEq(splitAmount, .0025 ether);

        price = 2 ether;
        amount = 5;
        (platform, mintFee, splitAmount) = feeManager.calculateFees(address(this), price, amount);
        assertEq(platform, .0025 ether);
        assertEq(mintFee, .1 ether);
        assertEq(splitAmount, .00125 ether);
    }
}
