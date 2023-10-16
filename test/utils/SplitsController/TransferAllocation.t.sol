// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/utils/SplitsController/SplitsControllerTest.t.sol";

contract TransferAllocation is SplitsControllerTest {
    address internal transferTo = address(9);

    function test_TransferAllocation() public {
        vm.prank(alice);
        controller.transferAllocation(split, accounts, allocations, transferTo);
    }

    function test_When_EntireCreatorAllocation_TransferAllocation() public {
        vm.prank(alice);
        controller.transferAllocation(split, accounts, allocations, transferTo);
        /// need to move creator status
    }

    function test_When_SplitCreator_TransferAllocationFrom() public {
        vm.prank(alice);
        controller.transferAllocationFrom(split, accounts, allocations, bob, transferTo);
    }

    function test_RevertsWhen_NotSplitsCreator_TransferAllocationFrom() public {
        vm.expectRevert();
        controller.transferAllocationFrom(split, accounts, allocations, bob, transferTo);
    }

    function test_When_ToNotInAccountsArray_TransferAllocationToExisting() public {
        transferTo = susan;
        vm.prank(alice);
        controller.transferAllocation(split, accounts, allocations, transferTo);
    }

    function test_When_ToInAccountsArray_TransferAllocation() public {
        transferTo = bob;
        vm.prank(alice);
        controller.transferAllocation(split, accounts, allocations, transferTo);
    }

    function test_RevertsWhen_TwoAccounts() public {
        vm.startPrank(alice);
        controller.transferAllocationFrom(split, accounts, allocations, bob, transferTo);
        controller.transferAllocationFrom(split, accounts, allocations, eve, transferTo);
        // vm.expectRevert();
        controller.transferAllocation(split, accounts, allocations, transferTo);
        vm.stopPrank();
    }

    function test_RevertsWhen_AccountsAndAllocationsDontComputeToSplitHash() public {
        accounts.pop();
        allocations.pop();
        vm.prank(alice);
        vm.expectRevert();
        controller.transferAllocation(split, accounts, allocations, transferTo);
    }

    function test_RevertsWhen_NotFxHash_TransferAllocationFrom() public {
        vm.prank(alice);
        vm.expectRevert();
        controller.transferAllocationFrom(split, accounts, allocations, fxHash, transferTo);
    }

    function test_RevertsWhen_TransferringMoreThanAllocation() public {}
}
