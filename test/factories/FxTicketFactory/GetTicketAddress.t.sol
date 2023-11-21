// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/factories/FxTicketFactory/FxTicketFactoryTest.t.sol";

contract GetTicketAddress is FxTicketFactoryTest {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_GetTicketAddress() public {
        address deterministicAddr = fxTicketFactory.getTicketAddress(address(this));
        fxMintTicketProxy = fxTicketFactory.createTicket(
            creator,
            fxGenArtProxy,
            address(ticketRedeemer),
            address(ipfsRenderer),
            uint48(ONE_DAY),
            mintInfo
        );
        assertEq(fxMintTicketProxy, deterministicAddr);
    }
}
