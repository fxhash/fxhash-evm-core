// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxSplitsFactory/FxSplitsFactoryTest.sol";

contract CreateSplit is FxSplitsFactoryTest {
    function setUp() public virtual override {
        super.setUp();
        accounts.push(bob);
        accounts.push(alice);
        allocations.push(uint32(600_000));
        allocations.push(uint32(400_000));
    }

    function test_createMutableSplit() public {
        fxSplitsFactory.createMutableSplit(accounts, allocations);
    }

    function test_Withdraw() public {
        address split = fxSplitsFactory.createMutableSplit(accounts, allocations);
        vm.deal(split, 1 ether);
        ISplitsMain(SPLITS_MAIN).distributeETH(split, accounts, allocations, 0, address(0));
        ISplitsMain(SPLITS_MAIN).withdraw(alice, 0.4 ether, new address[](0));
        ISplitsMain(SPLITS_MAIN).withdraw(bob, 0.6 ether, new address[](0));
        /// on first withdraw, 1 wei is withheld for gas savings
        assertGt(alice.balance, 0.3999999 ether);
        assertGt(bob.balance, 0.5999999 ether);
    }

    function test_RevertsWhen_LengthMismatch() public {
        accounts.pop();

        vm.expectRevert();
        fxSplitsFactory.createMutableSplit(accounts, allocations);
    }

    function test_RevertsWhen_AllocationsGt100() public {
        accounts.push(address(420));
        allocations.push(1);

        vm.expectRevert();
        fxSplitsFactory.createMutableSplit(accounts, allocations);
    }

    function test_RevertsWhen_AllocationsLt100() public {
        allocations[0]--;

        vm.expectRevert();
        fxSplitsFactory.createMutableSplit(accounts, allocations);
    }

    function test_RevertsWhen_DuplicateAccountInAccounts() public {
        accounts.push(alice);
        allocations.push(1);
        allocations[0]--;

        vm.expectRevert();
        fxSplitsFactory.createMutableSplit(accounts, allocations);
    }

    function test_RevertsWhen_AccountsNotSorted() public {
        (accounts[0], accounts[1]) = (accounts[1], accounts[0]);

        vm.expectRevert();
        fxSplitsFactory.createMutableSplit(accounts, allocations);
    }
}