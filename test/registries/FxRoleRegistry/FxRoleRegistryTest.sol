// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

contract FxRoleRegistryTest is BaseTest {
    function setUp() public virtual override {
        super.setUp();
        _initializeState();
    }
}
