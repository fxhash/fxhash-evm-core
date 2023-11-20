// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/factories/SplitsFactory/SplitsFactoryTest.sol";

contract CreateVirtualSplit is SplitsFactoryTest {
    function setUp() public override {
        super.setUp();
        accounts.push(bob);
        accounts.push(alice);
        allocations.push(CREATOR_ALLOCATION);
        allocations.push(ADMIN_ALLOCATION);
    }

    function test_createsVirtualSplit() public {
        splitsFactory.emitVirtualSplit(accounts, allocations);
    }

    function test_RevertsWhen_LengthMismatch() public {
        accounts.pop();

        vm.expectRevert();
        splitsFactory.emitVirtualSplit(accounts, allocations);
    }

    function test_RevertsWhen_AllocationsGt100() public {
        accounts.push(address(420));
        allocations.push(1);

        vm.expectRevert();
        splitsFactory.emitVirtualSplit(accounts, allocations);
    }

    function test_RevertsWhen_AllocationsLt100() public {
        allocations[0]--;

        vm.expectRevert();
        splitsFactory.emitVirtualSplit(accounts, allocations);
    }

    function test_RevertsWhen_DuplicateAccountInAccounts() public {
        accounts.push(alice);
        allocations.push(1);
        allocations[0]--;

        vm.expectRevert();
        splitsFactory.emitVirtualSplit(accounts, allocations);
    }

    function test_RevertsWhen_AccountsNotSorted() public {
        (accounts[0], accounts[1]) = (accounts[1], accounts[0]);

        vm.expectRevert();
        splitsFactory.emitVirtualSplit(accounts, allocations);
    }
}
