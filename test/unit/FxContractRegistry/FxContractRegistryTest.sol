// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

contract FxContractRegistryTest is BaseTest {
    // Errors
    bytes4 INPUT_EMPTY_ERROR = IFxContractRegistry.InputEmpty.selector;
    bytes4 LENGTH_MISMATCH_ERROR = IFxContractRegistry.LengthMismatch.selector;

    function setUp() public virtual override {
        super.setUp();
    }
}
