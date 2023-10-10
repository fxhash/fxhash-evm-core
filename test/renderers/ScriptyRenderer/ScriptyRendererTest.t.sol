// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

contract ScriptyRendererTest is BaseTest {
    function setUp() public override {
        super.setUp();
        _configureState(AMOUNT, PRICE, QUANTITY, TOKEN_ID);
        _configureScripty();
        _configureMetdata(BASE_URI, IMAGE_URI, animation);
    }
}
