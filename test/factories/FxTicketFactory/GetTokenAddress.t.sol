// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/factories/FxTicketFactory/FxTicketFactoryTest.t.sol";

contract GetTokenAddress is FxTicketFactoryTest {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_GetTokenAddress() public {
        uint256 nonce = fxTicketFactory.nonces(address(this));

        fxMintTicketProxy = fxTicketFactory.createTicket(
            creator,
            fxGenArtProxy,
            address(ticketRedeemer),
            address(ipfsRenderer),
            uint48(ONE_DAY),
            BASE_URI,
            mintInfo
        );
        assertEq(fxMintTicketProxy, fxTicketFactory.getTokenAddress(address(this), nonce));
    }
}
