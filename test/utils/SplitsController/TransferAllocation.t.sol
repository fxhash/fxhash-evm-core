// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/utils/SplitsController/SplitsControllerTest.t.sol";

contract TransferAllocation is SplitsControllerTest {
    address internal transferTo = address(8);

    function test_TransferAllocation() public {
        vm.prank(alice);
        controller.transferAllocation(split, accounts, allocations, transferTo);
    }

    function test_WhenEntireCreatorAllocation_TransferAllocation() public {}

    function test_TransferAllocationFrom() public {}

    function test_When_ToNotInAccountsArray_TransferAllocationToExisting() public {}

    function test_When_ToInAccountsArray_TransferAllocation() public {}

    function test_RevertsWhen_TwoAccounts() public {}

    function test_RevertsWhen_AccountsAndAllocationsDontComputeToSplitHash() public {}

    function test_RevertsWhen_TransferringMoreThanAllocation() public {}
}
