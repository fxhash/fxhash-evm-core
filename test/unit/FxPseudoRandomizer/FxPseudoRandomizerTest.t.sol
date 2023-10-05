// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

contract FxPseudoRandomizerTest is BaseTest {
    function setUp() public override {
        super.setUp();
        _initializeState();
    }

    function _initializeState() internal override {
        super._initializeState();
        tokenId = 1;
    }
}
