// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/extensions/SplitsController/SplitsControllerTest.t.sol";

contract TransferAllocation is SplitsControllerTest {
    address internal transferTo = address(9);

    function test_TransferAllocation() public {
        vm.prank(alice);
        controller.transferAllocation(transferTo, split, accounts, allocations);
    }

    function test_WhenFxHash_TransferFxHashAllocation() public {
        vm.prank(fxHash);
        controller.transferAllocation(transferTo, split, accounts, allocations);
    }

    function test_When_Creator_TransferAllocation() public {
        vm.prank(alice);
        controller.transferAllocation(transferTo, split, accounts, allocations);
        // need to move creator status
    }

    function test_When_SplitCreator_TransferAllocationFrom() public {
        vm.prank(alice);
        controller.transferAllocationFrom(bob, transferTo, split, accounts, allocations);
    }

    function test_RevertsWhen_NotSplitsCreator_TransferAllocationFrom() public {
        vm.expectRevert();
        controller.transferAllocationFrom(bob, transferTo, split, accounts, allocations);
    }

    function test_When_ToNotInAccountsArray_TransferAllocationToExisting() public {
        transferTo = susan;
        vm.prank(alice);
        controller.transferAllocation(transferTo, split, accounts, allocations);
    }

    function test_When_ToInAccountsArray_TransferAllocation() public {
        transferTo = bob;
        vm.prank(alice);
        controller.transferAllocation(transferTo, split, accounts, allocations);
    }

    function test_RevertsWhen_TwoAccounts() public {
        vm.startPrank(alice);
        controller.transferAllocationFrom(bob, alice, split, accounts, allocations);
        delete accounts;
        accounts.push(alice);
        accounts.push(eve);
        accounts.push(fxHash);

        delete allocations;
        allocations.push(allocationAmount * 2);
        allocations.push(allocationAmount);
        allocations.push(allocationAmount);
        controller.transferAllocationFrom(eve, alice, split, accounts, allocations);

        delete accounts;
        accounts.push(alice);
        accounts.push(fxHash);
        delete allocations;
        allocations.push(allocationAmount * 3);
        allocations.push(allocationAmount);
        vm.expectRevert();
        controller.transferAllocation(fxHash, split, accounts, allocations);
        vm.stopPrank();
    }

    function test_RevertsWhen_AccountsAndAllocationsDontComputeToSplitHash() public {
        accounts.pop();
        allocations.pop();
        vm.prank(alice);
        vm.expectRevert();
        controller.transferAllocation(transferTo, split, accounts, allocations);
    }

    function test_RevertsWhen_NotFxHash_TransferAllocationFrom() public {
        vm.prank(alice);
        vm.expectRevert();
        controller.transferAllocationFrom(fxHash, transferTo, split, accounts, allocations);
    }
}
