// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/factories/FxTicketFactory/FxTicketFactoryTest.t.sol";

contract SetImplementation is FxTicketFactoryTest {
    function test_SetImplementation() public {
        vm.prank(fxIssuerFactory.owner());
        fxTicketFactory.setImplementation(address(fxMintTicket721));
        assertEq(fxTicketFactory.implementation(), address(fxMintTicket721));
    }
}
