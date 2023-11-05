// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/splits/SplitsFactory/SplitsFactoryTest.sol";

contract CreateMutableSplit is SplitsFactoryTest {
    function setUp() public virtual override {
        super.setUp();
        accounts.push(bob);
        accounts.push(alice);
        allocations.push(CREATOR_ALLOCATION);
        allocations.push(ADMIN_ALLOCATION);
    }

    function test_createMutableSplitFor() public {
        splitsFactory.createMutableSplitFor(admin, accounts, allocations);
    }
}
