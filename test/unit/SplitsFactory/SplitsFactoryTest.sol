// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

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
        _initializeState();
    }
}
