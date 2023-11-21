// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/factories/FxIssuerFactory/FxIssuerFactoryTest.t.sol";

contract SetImplementation is FxIssuerFactoryTest {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_SetImplementation() public {
        vm.prank(admin);
        fxIssuerFactory.setImplementation(address(fxGenArt721));
        assertEq(fxIssuerFactory.implementation(), address(fxGenArt721));
    }
}
