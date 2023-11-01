// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/factories/FxIssuerFactory/FxIssuerFactoryTest.t.sol";

contract SetImplementation is FxIssuerFactoryTest {
    function setUp() public virtual override {
        super.setUp();
    }

    function testSetImplementation() public {
        vm.prank(fxIssuerFactory.owner());
        fxIssuerFactory.setImplementation(address(fxGenArt721));
        assertEq(fxIssuerFactory.implementation(), address(fxGenArt721));
    }
}
