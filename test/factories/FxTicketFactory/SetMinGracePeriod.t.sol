// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/factories/FxTicketFactory/FxTicketFactoryTest.t.sol";

contract SetImplementation is FxTicketFactoryTest {
    function test_SetImplementation() public {
        vm.prank(fxIssuerFactory.owner());
        fxTicketFactory.setMinGracePeriod(0);
        assertEq(fxTicketFactory.minGracePeriod(), 0);
    }
}
