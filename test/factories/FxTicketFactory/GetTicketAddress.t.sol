// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/factories/FxTicketFactory/FxTicketFactoryTest.t.sol";

contract GetTicketAddress is FxTicketFactoryTest {
    function test_GetTicketAddress() public {
        address deterministicAddr = fxTicketFactory.getTicketAddress(address(this));
        fxMintTicketProxy = fxTicketFactory.createTicket(
            abi.encode(
                creator,
                fxGenArtProxy,
                address(ticketRedeemer),
                address(ipfsRenderer),
                uint48(ONE_DAY),
                mintInfo
            )
        );
        assertEq(fxMintTicketProxy, deterministicAddr);
    }
}
