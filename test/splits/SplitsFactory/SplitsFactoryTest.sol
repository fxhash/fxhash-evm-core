// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

contract SplitsFactoryTest is BaseTest {
    // Errors
    error InvalidSplit__TooFewAccounts(uint256 accountsLength);
    error InvalidSplit__AccountsAndAllocationsMismatch(uint256 accountsLength, uint256 allocationsLength);
    error InvalidSplit__InvalidAllocationsSum(uint32 allocationsSum);
    error InvalidSplit__AccountsOutOfOrder(uint256 index);
    error InvalidSplit__AllocationMustBePositive(uint256 index);
    error InvalidSplit__InvalidDistributorFee(uint32 distributorFee);

    function setUp() public virtual override {
        super.setUp();
        splitsController = new MockSplitsController(SPLITS_MAIN, address(splitsFactory), admin);
        vm.prank(splitsFactory.owner());
        splitsFactory.setController(address(splitsController));
        _initializeState();
    }
}
