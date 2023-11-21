// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/factories/FxTicketFactory/FxTicketFactoryTest.t.sol";

contract GetTicketAddress is FxTicketFactoryTest {
    function test_GetTicketAddress() public {
        address deterministicAddr = fxTicketFactory.getTicketAddress(address(this));
        _createTicket();
        assertEq(fxMintTicketProxy, deterministicAddr);
    }
}
