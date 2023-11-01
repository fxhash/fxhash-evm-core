// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/factories/FxTicketFactory/FxTicketFactoryTest.t.sol";

contract SetImplementation is FxTicketFactoryTest {
    function setUp() public virtual override {
        super.setUp();
    }

    function testSetImplementation() public {
        vm.prank(fxIssuerFactory.owner());
        fxIssuerFactory.setImplementation(address(fxMintTicket721));
        assertEq(fxIssuerFactory.implementation(), address(fxMintTicket721));
    }
}
