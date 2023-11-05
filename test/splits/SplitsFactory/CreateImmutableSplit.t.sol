// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/splits/SplitsFactory/SplitsFactoryTest.sol";

contract CreateSplit is SplitsFactoryTest {
    function setUp() public virtual override {
        super.setUp();
        accounts.push(bob);
        accounts.push(alice);
        allocations.push(CREATOR_SPLITS_ALLOCATION);
        allocations.push(ADMIN_SPLITS_ALLOCATION);
    }

    function test_createImmutableSplit() public {
        splitsFactory.createImmutableSplit(accounts, allocations);
    }

    function test_RevertsWhen_CreateSplitTwice() public {
        splitsFactory.createImmutableSplit(accounts, allocations);
        vm.expectRevert(abi.encodeWithSelector(ISplitsFactory.SplitsExists.selector));
        splitsFactory.createImmutableSplit(accounts, allocations);
    }

    function test_FirstWithdraw() public {
        address libPredicted = ISplitsMain(SPLITS_MAIN).predictImmutableSplitAddress(accounts, allocations, 0);
        vm.deal(libPredicted, 1 ether);
        splitsFactory.createImmutableSplit(accounts, allocations);
        ISplitsMain(SPLITS_MAIN).distributeETH(libPredicted, accounts, allocations, 0, address(0));
        ISplitsMain(SPLITS_MAIN).withdraw(alice, 0.1 ether, new address[](0));
        ISplitsMain(SPLITS_MAIN).withdraw(bob, 0.9 ether, new address[](0));
        assertGt(alice.balance, 0.0999999 ether);
        assertGt(bob.balance, 0.8999999 ether);
    }

    function test_2ndWithdraw() public {
        test_FirstWithdraw();
        address computedAddress = ISplitsMain(SPLITS_MAIN).predictImmutableSplitAddress(accounts, allocations, 0);
        vm.deal(computedAddress, 1 ether);
        ISplitsMain(SPLITS_MAIN).distributeETH(computedAddress, accounts, allocations, 0, address(0));
        uint256 cachedBalance2 = alice.balance;
        uint256 cachedBalance3 = bob.balance;
        ISplitsMain(SPLITS_MAIN).withdraw(alice, 0.1 ether, new address[](0));
        ISplitsMain(SPLITS_MAIN).withdraw(bob, 0.9 ether, new address[](0));
        assertEq(alice.balance - cachedBalance2, 0.1 ether);
        assertEq(bob.balance - cachedBalance3, 0.9 ether);
    }

    function test_RevertsWhen_LengthMismatch() public {
        accounts.pop();
        vm.expectRevert();
        splitsFactory.createImmutableSplit(accounts, allocations);
    }

    function test_RevertsWhen_AllocationsGt100() public {
        accounts.push(address(420));
        allocations.push(1);
        vm.expectRevert();
        splitsFactory.createImmutableSplit(accounts, allocations);
    }

    function test_RevertsWhen_AllocationsLt100() public {
        allocations[0]--;
        vm.expectRevert();
        splitsFactory.createImmutableSplit(accounts, allocations);
    }

    function test_RevertsWhen_DuplicateAccountInAccounts() public {
        accounts.push(alice);
        allocations.push(1);
        allocations[0]--;
        vm.expectRevert();
        splitsFactory.createImmutableSplit(accounts, allocations);
    }

    function test_RevertsWhen_AccountsNotSorted() public {
        (accounts[0], accounts[1]) = (accounts[1], accounts[0]);

        vm.expectRevert();
        splitsFactory.createImmutableSplit(accounts, allocations);
    }
}
