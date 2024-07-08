// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/extensions/FeeManager/FeeManagerTest.t.sol";

contract Withdraw is FeeManagerTest {
    uint256 internal balance;

    function setUp() public virtual override {
        super.setUp();
        vm.deal(address(feeManager), 1 ether);
    }

    function test_Withdraw() public {
        vm.prank(admin);
        feeManager.withdraw(address(this));
        balance = address(this).balance;
        assertEq(balance, INITIAL_BALANCE + 1 ether);
    }
}
