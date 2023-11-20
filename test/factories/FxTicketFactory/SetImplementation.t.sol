// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/factories/FxTicketFactory/FxTicketFactoryTest.t.sol";

contract SetImplementation is FxTicketFactoryTest {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_SetImplementation() public {
        vm.prank(admin);
        fxTicketFactory.setImplementation(address(fxMintTicket721));
        assertEq(fxTicketFactory.implementation(), address(fxMintTicket721));
    }
}
