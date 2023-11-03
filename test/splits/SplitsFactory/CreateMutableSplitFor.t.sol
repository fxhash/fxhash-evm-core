// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/splits/SplitsFactory/SplitsFactoryTest.sol";

contract CreateMutableSplit is SplitsFactoryTest {
    function setUp() public virtual override {
        super.setUp();
        accounts.push(bob);
        accounts.push(alice);
        allocations.push(uint32(600_000));
        allocations.push(uint32(400_000));
    }

    function test_createMutableSplitFor() public {
        splitsFactory.createMutableSplitFor(admin, accounts, allocations);
    }
}
