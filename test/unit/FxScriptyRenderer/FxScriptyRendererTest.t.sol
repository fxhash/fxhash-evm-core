// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

contract FxScriptyRendererTest is BaseTest {
    function setUp() public override {
        super.setUp();
        _configureScripty();
        _configureMetdata();
        tokenId = 1;
    }
}
